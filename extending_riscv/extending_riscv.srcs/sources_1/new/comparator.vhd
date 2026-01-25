---------------------------------------
-- Notes:
-- Floating point comparisons are not part of any standard so it has not been implemented
---------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator is
    Port( value_1 : in STD_LOGIC_VECTOR (31 downto 0);
        value_2 : in STD_LOGIC_VECTOR (31 downto 0);
        cond_opcode : in STD_LOGIC_VECTOR (2 downto 0);
        branch_condition : out STD_LOGIC );
end comparator;

architecture Behavioral of comparator is
begin
process (value_1 , value_2 , cond_opcode) begin
	case cond_opcode is
		when "110" => branch_condition <=  '1'; -- jump and link
		when "000" => -- branch if equal
			if value_1 = value_2 then
				branch_condition <=  '1';
			else
				branch_condition <=  '0';
			end if;
		when "001" => -- branch if not equal
			if value_1 =  value_2 then
				branch_condition <=  '0';
			else
				branch_condition <=  '1';
			end if;
    	when "010" => -- branch if less than
			if value_1 < value_2 then
				branch_condition <=  '1';
			else
				branch_condition <=  '0';
			end if;
    	when "011" => -- branch if greater than
			if value_1 >= value_2 then
				branch_condition <=  '1';
			else
				branch_condition <=  '0';
			end if;
    	when "100" then  -- branch if less than or equal
			if value_1 <= value_2 then
				branch_condition <=  '1';
			else 
			branch_condition <=  '0';
			end if;
    	when "101" then -- branch if greater than or equal
			if value_1 >= value_2 then
				branch_condition <=  '1';
			else
				branch_condition <=  '0';
			end if;
		when others => branch_condition <=  '0';
    end case;
end process;
end Behavioral;