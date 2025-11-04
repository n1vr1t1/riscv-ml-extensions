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
    function flt_to_real(x : std_logic_vector(31 downto 0)) return real is
        variable sign      : real;
        variable exponent  : integer;
        variable frac      : real;
        variable div : real;
        variable result    : real;
    begin
        exponent := to_integer(unsigned(x(30 downto 23)));
        frac := 1.0;
        div := 0.5;
        
        if exponent = 0 or exponent = 255 then
            result := 0.0;
            return result;
        end if;
        
        for i in 0 to 22 loop
            if x(22 - i) = '1' then
                frac := frac + div;
            end if;
            div := div / 2.0;
        end loop;
        
        if x(31) = '1' then
            sign := -1.0;
        else
            sign := 1.0;
        end if;
        
        result := sign * frac * (2.0 ** real(exponent - 127));
        
        frac := 0.0;
        return result;
    end function;

    -- Correct real to IEEE 754 conversion (normal numbers only)
    function real_to_flt(x : real) return std_logic_vector is
        variable result   : std_logic_vector(31 downto 0) := (others => '0');
        variable exp     : integer;
        variable mant    : real;
        variable mant_int : integer;
    begin
        if x < 0.0 then
            result(31) := '1';
            mant := -x;
        else
            result(31) := '0';
            mant := x;
        end if;
        
        if mant = 0.0 then
            result(30 downto 0) := (others => '0');
        else
        
            while mant < 1.0 loop
              exp  := exp - 1;
              mant := mant * 2.0;
            end loop;
            while mant > 2.0 loop
              exp  := exp + 1;
              mant := mant / 2.0;
            end loop;
    
            mant := mant - 1.0;
            mant_int := integer(mant * real(2 ** (23)));  -- implicit round-to-nearest
            result(22 downto 0) := std_logic_vector(to_unsigned(mant_int, 23));
    
            exp := exp + 127;
            result(30 downto 23) := std_logic_vector(to_unsigned(exp, 8));
        end if;

        return result;
    end function;
begin

process (ml, fp, opcode, operand_1, operand_2) 
    variable op1_fp, op2_fp, op3_fp, mul_fp : real;
    variable multiply_result : STD_LOGIC_VECTOR( 63 downto 0 ) := ( others => '0' );
begin
    if ml = '1' then
        if fp = '0' then -- integers
            op1_fp := 0.0;
            op2_fp  := 0.0;
            op3_fp  := 0.0;
            mul_fp := 0.0;
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
         op1_fp := flt_to_real(operand_1);
         op2_fp  := flt_to_real(operand_2);
         op3_fp  := flt_to_real(operand_3);
         mul_fp := op1_fp * op2_fp;
         multiply_result := (others => '0');
            if opcode = '0' then -- mac
                output <= real_to_flt(mul_fp + op3_fp);
            else -- leaky relu
                if op1_fp >= 0.0 then
                    output <=  operand_1;
                else
                    output <= real_to_flt(mul_fp);
                end if;
            end if; 
        end if;
    else
        output <= (others => '0');
    end if;
end process;


end Behavioral;
