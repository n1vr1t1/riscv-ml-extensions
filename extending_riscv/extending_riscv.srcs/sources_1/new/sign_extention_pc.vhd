library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extention_pc is
    Port (clk : in std_logic;
    	rst: in std_logic;
    	en : in std_logic; --used for flushing, active high
    	pc : in STD_LOGIC_VECTOR (11 downto 0);
        extended_pc : out STD_LOGIC_VECTOR (31 downto 0));
end sign_extention_pc;

architecture Behavioral of sign_extention_pc is
begin
process ( clk, rst ) begin 
	if rst = '0' then 
	   extended_pc <= ( others => '0' );
	elsif rising_edge( clk ) then
	   case en is
	   when '1' => 
	       extended_pc(11 downto 0) <= pc;
           extended_pc(31 downto 12) <= ( others => '0' );
	   when others => 
	       extended_pc <= ( others => '0' );
	   end case;
--		if en = '1' then 
--			extended_pc(11 downto 0) <= pc;
--			extended_pc(31 downto 12) <= ( others => '0' );
--		else extended_pc <= ( others => '0' ); --flushes the output signal
--		end if;
	end if;
end process;
end Behavioral;