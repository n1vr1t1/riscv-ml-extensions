library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_test is
  Port (clk : in STD_LOGIC;
        rst: in STD_LOGIC--; -- active low
--        switches: in std_logic_vector(15 downto 0); -- 16 swicthes
--		CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
--		AN : out std_logic_vector(3 downto 0)
		);
end top_test;

architecture Behavioral of top_test is

component top is
  Port (clk : in STD_LOGIC;
        rst: in STD_LOGIC --; --active low
--        switches: in std_logic_vector(15 downto 0); -- 16 swicthes
--		CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
--		AN : out std_logic_vector(3 downto 0)
);
end component;

begin

dut : top 
    Port map(clk => clk,
        rst => rst --,
--        switches => switches,
--		CA => CA, 
--		CB => CB, 
--		CC => CC,
--		CD => CD,
--		CE => CE,
--		CF => CF,
--		CG => CG, 
--		DP => DP,
--		AN => AN
);
end Behavioral;
