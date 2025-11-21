----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.10.2025 10:41:25
-- Design Name: 
-- Module Name: mlu_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mlu_tb is
--  Port ( );
end mlu_tb;

architecture Behavioral of mlu_tb is

component mlu is
  Port (ml : in std_logic;
        fp : in std_logic;
        opcode : in std_logic;
        operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_3 : in STD_LOGIC_VECTOR (31 downto 0);
        output : out STD_LOGIC_VECTOR (31 downto 0));
end component;
signal ml : std_logic;
signal fp : std_logic;
signal opcode : std_logic;
signal operand_1 : STD_LOGIC_VECTOR (31 downto 0);
signal operand_2 : STD_LOGIC_VECTOR (31 downto 0);
signal operand_3 : STD_LOGIC_VECTOR (31 downto 0);
signal output : STD_LOGIC_VECTOR (31 downto 0);
begin

    uut: mlu
        port map (ml => ml,
            fp => fp,
            opcode => opcode,
            operand_1 => operand_1,
            operand_2 => operand_2,
            operand_3 => operand_3,
            output => output);
    process begin
        ml <= '1';
        fp <= '0';
        opcode <= '0';
        operand_1 <= x"00000003";  -- 3
        operand_2 <= x"00000004";  -- 4
        operand_3 <= x"00000002";  -- 2
        wait for 10 ns;
        -- output <= 14

        opcode <= '1';
        operand_1 <= x"FFFFFFFE";  -- -2 (signed)
        operand_2 <= x"00000003";  -- slope multiplier
        operand_3 <= x"00000000";
        wait for 10 ns;
        -- output <= -6

        fp <= '1';
        opcode <= '0';
        operand_1 <=  x"3F800000";     -- 1.0
        operand_2 <= x"40000000";     -- 2.0
        operand_3 <=  x"3F000000";     -- 0.5
        wait for 10 ns;
        -- output <= 2.5

        opcode <= '1';
        operand_1 <= x"40000000";     -- > 0, should pass through
        operand_2 <=  x"3F000000";     -- leak multiplier not used
        wait for 10 ns;
        -- output <= (2.0)

        operand_1 <= x"BF800000";
        operand_2 <=  x"3F000000";     -- leak slope
        wait for 10 ns;
        -- output <= -0.5

        ml <= '0';
        wait;
    end process;

end Behavioral;
