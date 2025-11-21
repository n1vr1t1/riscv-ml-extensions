----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 31.10.2025 11:20:04
-- Design Name: 
-- Module Name: top_test_tb - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_test_tb is
--  Port ( );
end top_test_tb;

architecture Behavioral of top_test_tb is
component top is
  Port (clk : in STD_LOGIC;
        rst: in STD_LOGIC);
end component;

signal rst : std_logic;
signal clk : std_logic;

begin

dut : top
Port map(clk => clk,
        rst => rst);
clk_process: process begin
    clk<='0';
    wait for 1 ns;
    clk<='1';
    wait for 1 ns;
end process;
rst_process: process begin
    wait for 0.2 ns;
    rst<='0';
    wait for 1.5 ns;
    rst<='1';
    wait;
end process;
--actual_process: process begin
--    flush <= '0';
--    write_enable_from_wb <= '0';
--    a2_select <= '0';
--    b2_select <= '0';
--    c_select <= '0';
--    memory_value <= (others => '0');
--    wait for 2.5 ns;
--    instruction <= "11111111111111111111111111111111";
--    wait for 2 ns;
--    flush <= '1';
--    wait for 2 ns;
--    flush <= '0';
--    instruction <= "00000000010100100000000110110011"; --add
--    wait for 2 ns;
--    instruction <= "01000000010100100000000110110011";  --sub
--    destination_value_from_wb <= "00000000010100100000000110110011";
--    destination_address_from_wb <= "00100";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000010010100100000000110110011";  -- mul
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00101";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000010100000110100001000110011";  -- div
--    destination_value_from_wb <= "00000010010100100000000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000010100100110000110110011";  --or
--    destination_value_from_wb <= "00000010100000110100001000110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000101001011111011000110011";  --and
--    destination_value_from_wb <= "00000000010100100110000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000101001011100011000110011";  --xor 
--    destination_value_from_wb <= "00000000101001011111011000110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000110100000101011000110000011";  -- ld x3, 104(x5) 
--    destination_value_from_wb <= "00000000101001011100011000110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000110100000101010000110000111";  --flw f3, 104(x5) 
--    destination_value_from_wb <= "00000110100000101011000110000011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "11111110010001000010111000100011";  --sw x4, -4(x8) 
--    destination_value_from_wb <= x"40e80000"; -- 7.25
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "01111110010001000010111110100111";  --fsw f4, 2047(x8) 
--    destination_value_from_wb <= "11111110010001000010111000100011";
--    destination_address_from_wb <= "00100";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "01111111111100001000001110010011"; --addi
--    destination_value_from_wb <= "01111110010001000010111110100111";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "01111111111111111111010100110111";  -- lui x10, 524287
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00111";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000001000000001010010010011";  -- slli x9, x0, 2
--    destination_value_from_wb <= "01111111111111111111000000000000";
--    destination_address_from_wb <= "01010";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000001000000101010010010011"; -- srli
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "11001";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "01111010000100000000100111101111";  --  jal x19, 4000
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "01001";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "01110110011101001101011001100011";  -- bge x9, x7, 1900
--    destination_value_from_wb <= "00000000000000100000000110110011";
--    destination_address_from_wb <= "10011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "01110110011101001011011001100011";  -- bgt
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "01110110011101001100011001100011";  -- ble
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "01110110011101001010011001100011";  -- blt x9, x7, 1900
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "01110110011101001000011001100011";  -- be x9, x7, 1900
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "01110110011101001001011001100011";  -- bne x9, x7, 1900
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "00000000100101000000011101010111";  -- mac 
--    destination_value_from_wb <= "00000000000000000000000000000000";
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '0';
--    wait for 2 ns;
--    instruction <= "00000111111101000010011100110011";  -- cge
--    destination_value_from_wb <= x"3e200000"; -- 0.15625
--    destination_address_from_wb <= "00110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000011111101000010011100110011";  -- cgt
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "01110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000100101000010011100110011";  -- clt x14, x8, x9
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "01110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000101111101000010011100110011"; -- cle
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "01110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00001001111101000010011100110011"; -- ce
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "01110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000100101000001011101010111";  -- leaky relu
--    destination_value_from_wb <= x"00000000";
--    destination_address_from_wb <= "01110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000001101101010001001100110011";  -- sll
--    destination_value_from_wb <= x"3eb00000"; -- 0.34375
--    destination_address_from_wb <= "00011";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000001101101010101001100110011"; -- srl x6, x10, x27
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00000000010100100111000011010011";  --  fadd
--    destination_value_from_wb <= "01000000010100100000000110110011";
--    destination_address_from_wb <= "00110";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00001000010100100111000011010011";  -- fsub
--    destination_value_from_wb <= x"3f000000";
--    destination_address_from_wb <= "00001";
--    write_enable_from_wb <= '1';
--    wait for 2 ns;
--    instruction <= "00010000010100100111000011010011"; -- fmul.s f1, f4, f5
--    destination_value_from_wb <= x"be400000" ;
--    destination_address_from_wb <= "00001";
--    write_enable_from_wb <= '1';
--    wait;
--    end process;

end Behavioral;