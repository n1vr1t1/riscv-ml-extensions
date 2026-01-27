library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extention_pc is
    Port (clk : in std_logic;
    	rst: in std_logic;
    	flush : in std_logic; -- active high
    	pc : in STD_LOGIC_VECTOR (11 downto 0);
        extended_pc : out STD_LOGIC_VECTOR (31 downto 0));
end sign_extention_pc;

architecture Behavioral of sign_extention_pc is
begin
process ( clk, rst ) begin 
	if rst = '0' then 
	   extended_pc <= ( others => '0' );
	elsif rising_edge( clk ) then
        if flush = '1' then -- flush the output signal
            extended_pc <= ( others => '0' );
		else -- operate as normal
			extended_pc(11 downto 0) <= pc;
			extended_pc(31 downto 12) <= ( others => '0' );
		end if;
	end if;
end process;
end Behavioral;