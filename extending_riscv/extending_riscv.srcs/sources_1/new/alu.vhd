library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port( rst: in std_logic;
          clk : in std_logic;
          opcode : in STD_LOGIC_VECTOR( 3 downto 0);
          operand_1 : in STD_LOGIC_VECTOR( 31 downto 0);
          operand_2 : in STD_LOGIC_VECTOR( 31 downto 0);
          operand_3 : in STD_LOGIC_VECTOR( 31 downto 0);
          is_float : in STD_LOGIC; -- indicates if the operation is a floating point
          is_ml : in STD_LOGIC; -- indicates if the operation is a machine learning operation
          en : in STD_LOGIC; -- enable signal to disable the alu when not in use
          alu_output : out STD_LOGIC_VECTOR( 31 downto 0 ));
end alu;

architecture Behavioral of alu is
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
process (rst, clk) 
variable multiply_result: STD_LOGIC_VECTOR(63 downto 0) := ( others => '0' ); --check if it can be shortened to 32 bits
    variable op1_fp, op2_fp, op3_fp : signed(55 downto 0); -- for floating point operations
    variable mul_fp : signed(111 downto 0); -- to store the result of floating point multiplication
begin
    if rst = '1' then
        alu_output <= (others => '0');
    elsif rising_edge(clk) then
        if en = '0' then -- disables the alu (used by the extra alu for vector operations)
            alu_output <= (others => '0');
        else
            if is_float = '1' then
                op1_fp := flt_to_fixed(operand_1);
                op2_fp  := flt_to_fixed(operand_2);
                op3_fp  := flt_to_fixed(operand_3);
                mul_fp := signed(op1_fp) * signed(op2_fp);
                multiply_result := (others => '0');
                if is_ml = '1' then -- ml operations with floating point operands
                    if opcode(0) = '1' then -- fmacc
                        alu_output <= fixed_to_flt(signed( shift_right( mul_fp, 23 )( 55 downto 0 )) + op3_fp);
                    elsif opcode(1) = '1' then -- float leaky relu
                        if op1_fp >= 0 then
                            alu_output <= operand_1;
                        else
                            alu_output <= fixed_to_flt( signed( shift_right( mul_fp, 23 )( 55 downto 0 )));
                        end if;
                    else 
                        alu_output <= (others => '0'); -- assuming that the operation is invalid
                    end if;
                else -- normal floating point operation
                    case opcode is
                        when "0000" => -- add
                            alu_output <= fixed_to_flt(op1_fp + op2_fp);
                        when "0001" => -- sub
                            alu_output <= fixed_to_flt(op1_fp - op2_fp);
                        when "0010" => -- mul
                            mul_fp := signed( op1_fp ) * signed( op2_fp );
                            alu_output <= fixed_to_flt(signed( shift_right( mul_fp, 23 )(55 downto 0) ));
                        when "0011" => -- set if less than / min
                            if op1_fp < op2_fp then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "0100" => -- set if greater than / max
                            if op1_fp > op2_fp then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "0101" => -- set if less than or equal
                            if op1_fp <= op2_fp then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "0110" => -- set if equal
                            if op1_fp = op2_fp then
                                alu_output(31 downto 1) <= (others => '0');
                                alu_output(0) <= '1';
                            else
                                alu_output <= (others => '0');
                            end if;
                        when "0111" => -- int to float
                            alu_output <= fixed_to_flt(shift_left(resize(signed(operand_1), 56), 23));
                        when "1000" => -- float to int
                            -- truncate toward zero implemented differently based on sign
                            if op1_fp < 0 then
                                alu_output <= std_logic_vector(resize(-shift_right(-op1_fp, 23), 32));
                            else
                                alu_output <= std_logic_vector(resize(shift_right(op1_fp, 23), 32));
                            end if;
                        when "1001" => -- set if greater than or equal
                            if op1_fp >= op2_fp then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when others =>
                            alu_output <= (others => '0');
                    end case;
                end if;
            else -- integer operations
                multiply_result := std_logic_vector(signed(operand_1) * signed(operand_2)); -- r1 * r2
                op1_fp := (others => '0');
                op2_fp  := (others => '0');
                op3_fp  := (others => '0');
                mul_fp := (others => '0');
                if is_ml = '1' then -- ml operations with integers
                    if opcode(0) = '1' then -- macc
                        alu_output <= std_logic_vector(signed(multiply_result(31 downto 0)) + signed(operand_3)); -- r1 * r2 + r3
                    elsif opcode(1) = '1' then -- leaky relu
                        if operand_1(31) = '0' then -- check r1 > 0 using sign bit
                            alu_output <= operand_1; -- rd = r1
                        else 
                            alu_output <= multiply_result(31 downto 0); -- rd = r1 * r2
                        end if;
                    else -- invalid op
                        alu_output <= (others => '0');
                    end if;
                else -- normal operations
                    case opcode is
                        when "0000" => -- add
                            alu_output <= std_logic_vector(unsigned(operand_1) + unsigned(operand_2)); 
                        when "0001" => -- sub
                            alu_output <= std_logic_vector(unsigned(operand_1) - unsigned(operand_2)); 
                        when "0010" => -- mul
                            alu_output <= multiply_result(31 downto 0); 
                        when "0011" => -- set less than
                            if signed(operand_1) < signed(operand_2) then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "0100" => -- set if less than or equal
                            if signed(operand_1) <= signed(operand_2) then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "0101" => -- set if equal
                            if operand_1 = operand_2 then
                                alu_output <= "00000000000000000000000000000001";
                            else
                                alu_output <=(others => '0');
                            end if;
                        when "0110" => -- or
                            alu_output <= std_logic_vector(unsigned(operand_1) or unsigned(operand_2));
                        when "0111" => -- and
                            alu_output <= std_logic_vector(unsigned(operand_1) and unsigned(operand_2));
                        when "1000" => -- xor
                            alu_output <= std_logic_vector(unsigned(operand_1) xor unsigned(operand_2));
                        when "1001" => -- div
                            if operand_2 = "00000000000000000000000000000000" then 
                                alu_output <= (others => '0');
                            else 
                                alu_output <= std_logic_vector(to_signed(to_integer(signed(operand_1) / signed(operand_2)),32));
                            end if;
                                when "1010" => -- set if greater than or equal
                            if signed(operand_1) >= signed(operand_2) then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "1011" => -- set if greater than
                            if signed(operand_1) > signed(operand_2) then
                                alu_output <= operand_1;
                            else
                                alu_output <= operand_2;
                            end if;
                        when "1100" => -- lui
                            alu_output <= operand_2;
                        when "1101" => -- sll
                            alu_output <= std_logic_vector(shift_left(unsigned(operand_1), to_integer(unsigned(operand_2))));
                        when "1110" => -- shift logical right
                            alu_output <= std_logic_vector(shift_right(unsigned(operand_1), to_integer(unsigned(operand_2))));
                        when others =>
                            alu_output <=(others=>'0');
                    end case;
                end if;
            end if;
        end if;
    end if;
end process;
end Behavioral;