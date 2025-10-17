
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity comparator is
    Port (value_1 : in STD_LOGIC_VECTOR (31 downto 0);
           value_2 : in STD_LOGIC_VECTOR (31 downto 0);
           cond_opcode : in STD_LOGIC_VECTOR (2 downto 0);
           branch_condition : out STD_LOGIC);
end comparator;

architecture Behavioral of comparator is
begin
process (value_1 , value_2 , cond_opcode) begin
    if cond_opcode = "110" then --jump and link
	   branch_condition <=  '1';
    elsif cond_opcode = "000" then  --equal
       	if value_1 = value_2 then
           	branch_condition <=  '1';
       	else
           	branch_condition <=  '0';
       	end if;
    elsif cond_opcode = "001" then --not equal
       	if value_1 =  value_2 then
           	branch_condition <=  '0';
       	else
           	branch_condition <=  '1';
       	end if;
    elsif cond_opcode = "010" then --less than
       	if value_1 < value_2 then
			branch_condition <=  '1';
		else
			branch_condition <=  '0';
		end if;
    elsif cond_opcode = "011" then --greater than
       	if value_1 >= value_2 then
			branch_condition <=  '1';
		else
			branch_condition <=  '0';
		end if;
    elsif cond_opcode = "100" then   --less than or equal
		if value_1 <= value_2 then
			branch_condition <=  '1';
		else 
		  branch_condition <=  '0';
		end if;
    elsif cond_opcode = "101" then --greater than or equal
       	if value_1 >= value_2 then
			branch_condition <=  '1';
		else
			branch_condition <=  '0';
		end if;
    else
        branch_condition <=  '0';
    end if;
end process;
end Behavioral;