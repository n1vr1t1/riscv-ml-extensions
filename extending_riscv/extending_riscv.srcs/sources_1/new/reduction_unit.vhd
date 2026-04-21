library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reduction_unit is
 Port (rst : in std_logic;
       clk : in std_logic;
       operand_1 : in std_logic_vector(31 downto 0); -- vs1[0]
       operand_2 : in std_logic_vector(31 downto 0); -- vs2[0]
       operand_3 : in std_logic_vector(31 downto 0); -- vs2[1]
       operand_4 : in std_logic_vector(31 downto 0); -- vs2[2]
       operand_5 : in std_logic_vector(31 downto 0); -- vs2[3]
       opcode : in std_logic_vector(2 downto 0);
       fp_en : in std_logic;
       en : in std_logic;
       result : out std_logic_vector(31 downto 0)); -- vd[0]
end reduction_unit;

architecture Behavioral of reduction_unit is
    -- copied from alu.vhd
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
            -- out of range (overflow/underflow) -> zero 
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
    process(rst, clk)
    variable temp_result_int : std_logic_vector(31 downto 0);
    variable op1_fp, op2_fp, op3_fp, op4_fp, op5_fp, temp_flt : signed(55 downto 0);
    
    begin
        if rst = '0' then
            result <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                if fp_en = '1' then
                    op1_fp := flt_to_fixed(operand_1);
                    op2_fp := flt_to_fixed(operand_2);
                    op3_fp := flt_to_fixed(operand_3);
                    op4_fp := flt_to_fixed(operand_4);
                    op5_fp := flt_to_fixed(operand_5);
                    temp_result_int := (others => '0');
                    case opcode(1 downto 0) is
                        when "00" => -- VFREDUSUM.VS and VFREDOSUM.VS (both are treated the same for this implementation)
                            temp_flt := op1_fp + op2_fp + op3_fp + op4_fp + op5_fp;
                            result <= fixed_to_flt(temp_flt);
                        when "01" => -- VFREDMIN.VS
                            temp_flt := op1_fp;
                            if op2_fp < temp_flt then
                                temp_flt := op2_fp;
                            end if;
                            if op3_fp < temp_flt then
                                temp_flt := op3_fp;
                            end if;
                            if op4_fp < temp_flt then
                                temp_flt := op4_fp;
                            end if;
                            if op5_fp < temp_flt then
                                temp_flt := op5_fp;
                            end if;
                            result <= fixed_to_flt(temp_flt);
                        when "10" => -- VFREDMAX.VS
                            temp_flt := op1_fp;
                            if op2_fp > temp_flt then
                                temp_flt := op2_fp;
                            end if;
                            if op3_fp > temp_flt then
                                temp_flt := op3_fp;
                            end if;
                            if op4_fp > temp_flt then
                                temp_flt := op4_fp;
                            end if;
                            if op5_fp > temp_flt then
                                temp_flt := op5_fp;
                            end if;
                            result <= fixed_to_flt(temp_flt);
                        when others =>
                            result <= (others => '0'); -- Default case for unsupported FP opcodes
                    end case;
                else
                    op1_fp := (others => '0');
                    op2_fp := (others => '0');
                    op3_fp := (others => '0');
                    op4_fp := (others => '0');
                    op5_fp := (others => '0');
                    temp_flt := (others => '0');
                    case opcode is
                        when "000" => -- VREDSUM.VS
                            result <= std_logic_vector(unsigned(operand_1) + unsigned(operand_2) + unsigned(operand_3) + unsigned(operand_4) + unsigned(operand_5));
                        when "001" => -- VREDAND.VS
                            result <= operand_1 and operand_2 and operand_3 and operand_4 and operand_5;
                        when "010" => -- VREDOR.VS
                            result <= operand_1 or operand_2 or operand_3 or operand_4 or operand_5;
                        when "011" => -- VREDXOR.VS
                            result <= operand_1 xor operand_2 xor operand_3 xor operand_4 xor operand_5;
                        when "100" => -- VREDMIN.VS
                            temp_result_int := operand_1;
                            if unsigned(operand_2) < unsigned(temp_result_int) then
                                temp_result_int := operand_2;
                            end if;
                            if unsigned(operand_3) < unsigned(temp_result_int) then
                                temp_result_int := operand_3;
                            end if;
                            if unsigned(operand_4) < unsigned(temp_result_int) then
                                temp_result_int := operand_4;
                            end if;
                            if unsigned(operand_5) < unsigned(temp_result_int) then
                                temp_result_int := operand_5;
                            end if;
                            result <= temp_result_int;
                        when "101" => -- VREDMAX.VS
                            temp_result_int := operand_1;
                            if unsigned(operand_2) > unsigned(temp_result_int) then
                                temp_result_int := operand_2;
                            end if;
                            if unsigned(operand_3) > unsigned(temp_result_int) then
                                temp_result_int := operand_3;
                            end if;
                            if unsigned(operand_4) > unsigned(temp_result_int) then
                                temp_result_int := operand_4;
                            end if;
                            if unsigned(operand_5) > unsigned(temp_result_int) then
                                temp_result_int := operand_5;
                            end if;
                            result <= temp_result_int;
                        when others =>
                            result <= (others => '0'); -- Default case for unsupported opcodes
                    end case;
                end if;
            else
                result <= (others => '0'); -- Output zero when not enabled
            end if;
        end if;
    end process;
end Behavioral;
