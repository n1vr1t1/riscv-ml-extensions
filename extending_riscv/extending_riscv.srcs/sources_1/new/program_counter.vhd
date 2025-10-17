
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
--registered and can implement stall and flush(loads a nop)
entity program_counter is
     Port (pc : in STD_LOGIC_VECTOR (11 downto 0);
     	clk: in std_logic;
    	pc_out : out STD_LOGIC_VECTOR (11 downto 0);
        rst: in std_logic);
end program_counter;

architecture Behavioral of program_counter is
begin
process ( rst , clk ) begin 
		if rst = '0' then
				pc_out <= (others=>'0');-- have to check the zero is not propagating else change to "000000000100
		elsif rising_edge( clk ) then
				pc_out <= pc;
		end if;
end process;
end Behavioral;