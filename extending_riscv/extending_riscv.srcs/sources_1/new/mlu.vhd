library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

entity mlu is
  Port (ml : in std_logic;
        fp : in std_logic;
        opcode : in std_logic;
        operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_3 : in STD_LOGIC_VECTOR (31 downto 0);
        output : out STD_LOGIC_VECTOR (31 downto 0));
end mlu;

architecture Behavioral of mlu is
    function flt_to_fixed(x : std_logic_vector(31 downto 0)) 
    return signed is
        variable s   : std_logic;
        variable e   : integer;
        variable m   : unsigned(23 downto 0);
        variable tmp : signed(55 downto 0);
    begin
        
        s := x(31);
        e  := to_integer(unsigned(x(30 downto 23)));
        if e = 0 or e = 255 then
            m := (others => '0');
        else
            m := '1' & unsigned(x(22 downto 0));
        end if;
        e := e - 127;
        
        tmp := signed(resize(m, 56));
        if e > 31 or e < -31 then
            tmp := (others => '0');
        elsif e >= 0 then
            tmp := shift_left(tmp, e);
        else
            tmp := shift_right(tmp, -e);
        end if;
        if s = '1' then
            tmp := -tmp;
        end if;
        return tmp;
    end function;

    function fixed_to_flt(fx : signed(55 downto 0)) return std_logic_vector is
        variable res  : std_logic_vector(31 downto 0) := (others => '0');
        variable signb: std_logic := '0';
        variable abs_val : unsigned(fx'length-1 downto 0);
        variable pos  : integer := -1;
        variable mant : unsigned(23 downto 0);
        variable exp  : integer;
        variable i    : integer;
    begin 
        if fx < 0 then
            signb := '1';
            abs_val := unsigned(-fx);
        else
            signb := '0';
            abs_val := unsigned(fx); 
        end if;
        for i in abs_val'length-1 downto 0 loop
            if abs_val(i) = '1' and pos = -1 then
                pos := i;
            end if;
        end loop;
        if pos = -1 then
            mant := (others => '0');
        -- position pos corresponds to value = abs_val * 2^(-23) * 2^pos ???
        -- We want mant (24 bits) such that mant * 2^exp = value * 2^23
        -- Given fixed representation, mant = abs_val >> (pos - 23) (or shifted left if pos < 23)
        elsif pos >= 23 then
            mant := resize( abs_val( pos downto pos-23 ), 24 );
        else
            mant := resize( shift_left(abs_val, 23 - pos)(23 downto 0), 24 );
        end if;
        exp := pos - 23 + 127;
        if exp <= 0 or exp >= 255 or fx = 0 then
            res := (others => '0');
        else
            res(31) := signb;
            res(30 downto 23) := std_logic_vector(to_unsigned(exp, 8));
            res(22 downto 0) := std_logic_vector(mant(22 downto 0));
        end if;
        return res;
    end function;
begin

process (ml, fp, opcode, operand_1, operand_2, operand_3) 
    variable op1_fp, op2_fp, op3_fp : signed(55 downto 0);
    variable mul_fp : signed(111 downto 0);
    variable multiply_result : STD_LOGIC_VECTOR( 63 downto 0 ) := ( others => '0' );
begin
    if ml = '1' then
        if fp = '0' then -- integers
            op1_fp := (others => '0');
            op2_fp  := (others => '0');
            op3_fp  := (others => '0');
            mul_fp := (others => '0');
            multiply_result := std_logic_vector(unsigned(operand_1) * unsigned(operand_2));
            if opcode = '0' then --mac
                output <= std_logic_vector(unsigned(multiply_result(31 downto 0)) + unsigned(operand_3));
            else -- leaky relu
                if operand_1(31) = '0' then -- rd = r1
                    output <= operand_1;
                else
                    output <= multiply_result(31 downto 0); -- rd = r1 * r2
                end if;
            end if;
         else -- float
         op1_fp := flt_to_fixed(operand_1);
         op2_fp  := flt_to_fixed(operand_2);
         op3_fp  := flt_to_fixed(operand_3);
         mul_fp := signed(op1_fp) * signed(op2_fp);
         multiply_result := (others => '0');
            if opcode = '0' then -- mac
                output <= fixed_to_flt(signed( shift_right( mul_fp, 23 )( 55 downto 0 )) + op3_fp);
            else -- leaky relu
                if op1_fp >= 0 then
                    output <= operand_1;
                else
                    output <= fixed_to_flt( signed( shift_right( mul_fp, 23 )( 55 downto 0 )));
                end if;
            end if; 
        end if;
    else
        output <= (others => '0');
    end if;
end process;


end Behavioral;
