library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    Port (alu_opcode : in STD_LOGIC_VECTOR (3 downto 0);
          operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
          operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
          alu_output : out STD_LOGIC_VECTOR (31 downto 0));
end alu;

architecture Behavioral of alu is
signal multiply_result: STD_LOGIC_VECTOR(63 downto 0) := ( others => '0' ); --check if it can be shortened to 32 bits
begin
 process (operand_1, operand_2, alu_opcode, multiply_result) begin
    multiply_result <= std_logic_vector(unsigned(operand_1) * unsigned(operand_2));
    case alu_opcode is
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
            alu_output <= std_logic_vector(to_signed(to_integer(signed(operand_1) / signed(operand_2)),32));
        when "0111" => -- and
            alu_output <= std_logic_vector(unsigned(operand_1) and unsigned(operand_2));
        when "1000" => -- xor
            alu_output <= std_logic_vector(unsigned(operand_1) xor unsigned(operand_2));
        when "1001" => -- div
            alu_output <= std_logic_vector(unsigned(operand_1) or unsigned(operand_2));
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
--    if alu_opcode = "0000" then --add
--        alu_output <= std_logic_vector(unsigned(operand_1) + unsigned(operand_2)); 
--    elsif alu_opcode = "0001"  then --sub
--      	 alu_output <= std_logic_vector(unsigned(operand_1) - unsigned(operand_2)); 
--    elsif alu_opcode = "0010" then --multiplication
--       	 alu_output <= multiply_result(31 downto 0); 
--    elsif alu_opcode = "0011" then  --or
--       	alu_output <= std_logic_vector(unsigned(operand_1) or unsigned(operand_2));
--    elsif alu_opcode = "0100" then --and
--       	alu_output <= std_logic_vector(unsigned(operand_1) and unsigned(operand_2));
--    elsif alu_opcode = "0101" then --xor
--       	 alu_output <= std_logic_vector(unsigned(operand_1) xor unsigned(operand_2));
--    elsif alu_opcode = "0110" then  -- div
--        alu_output <= std_logic_vector(to_signed(to_integer(signed(operand_1) / signed(operand_2)),32));
---- 		alu_output <= std_logic_vector(numeric_std(operand_1) / std_logic_vector(numeric_std(operand_2);
--    elsif alu_opcode = "0111" then -- slt
--        if signed(operand_1) < signed(operand_2) then
--            alu_output <= operand_1;
--        else
--            alu_output <= operand_2;
--        end if;
--	elsif alu_opcode = "1000" then -- sle
--        if signed(operand_1) <= signed(operand_2) then
--            alu_output <= operand_1;
--        else
--            alu_output <= operand_2;
--        end if;
--    elsif alu_opcode = "1001"  then -- sgt
--      	if signed(operand_1) > signed(operand_2) then
--            alu_output <= operand_1;
--        else
--            alu_output <= operand_2;
--        end if;
--    elsif alu_opcode = "1010" then -- sge
--       	if signed(operand_1) >= signed(operand_2) then
--            alu_output <= operand_1;
--        else
--            alu_output <= operand_2;
--        end if;
--    elsif alu_opcode = "1011" then  -- se
--        if signed(operand_1) = signed(operand_2) then
--            alu_output <= "00000000000000000000000000000001";
--        else
--            alu_output <=(others => '0');
--        end if;
--    elsif alu_opcode = "1100" then -- lui
--       	alu_output <= operand_2;
--    elsif alu_opcode = "1101" then -- sll
--        alu_output <= std_logic_vector(shift_left(unsigned(operand_1), to_integer(unsigned(operand_2))));
--    elsif alu_opcode = "1110" then  ---shift right
--        alu_output <= std_logic_vector(shift_right(unsigned(operand_1), to_integer(unsigned(operand_2))));
--		-- alu_output <= shift_right(to_integer(signed(operand_1)), to_integer(unsigned(operand_2(4 downto 0))));
--    else 
--       	alu_output <=(others=>'0');
--    end if;
 end process;
end Behavioral;