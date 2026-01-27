
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity program_counter is
     Port( pc : in STD_LOGIC_VECTOR (11 downto 0); -- noraml pc value
        branch_pc : in STD_LOGIC_VECTOR (11 downto 0); -- instruction to which the pc needs to jump to
        branch_condition : in std_logic; -- indicates if the system needs to jump to another instruction
     	clk: in std_logic;
    	pc_out : out STD_LOGIC_VECTOR (11 downto 0);
        rst: in std_logic);
end program_counter;

architecture Behavioral of program_counter is
begin
process ( rst , clk ) begin
    if rst = '0' then
	   pc_out <= ( others => '0' );
	elsif rising_edge( clk ) then
	   if branch_condition = '1' then 
	   		pc_out <= branch_pc;
	   	else 
	   	   pc_out <= pc;
	   	end if;
	end if;
end process;
end Behavioral;