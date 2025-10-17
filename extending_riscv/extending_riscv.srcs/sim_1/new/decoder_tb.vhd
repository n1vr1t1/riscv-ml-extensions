
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decoder_tb is
end decoder_tb;

architecture Behavioral of decoder_tb is

component instruction_decode is
    Port (clk : in STD_LOGIC;
      rst : in STD_LOGIC;
      flush : in STD_LOGIC;
      pc_in : in STD_LOGIC_VECTOR (31 downto 0);
      instruction : in STD_LOGIC_VECTOR (31 downto 0);
      destination_value_from_wb : in STD_LOGIC_VECTOR (31 downto 0);
      destination_address_from_wb : in STD_LOGIC_VECTOR(4 DOWNTO 0);
      write_enable_from_wb : in STD_LOGIC;
      pc_out : out STD_LOGIC_VECTOR (31 downto 0);
      immediate : out STD_LOGIC_VECTOR (31 downto 0);
      op_class : out STD_LOGIC_VECTOR (4 downto 0);
      alu_opcode : out STD_LOGIC_VECTOR (3 downto 0); 
      a_select : out STD_LOGIC; 
      b_select : out STD_LOGIC;
      conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0); 
      r1 : out std_logic_vector(4 downto 0);
      r2 : out std_logic_vector(4 downto 0);
      s_value_1 : out STD_LOGIC_VECTOR (31 downto 0); 
      s_value_2 : out STD_LOGIC_VECTOR (31 downto 0);
      s_value_3 : out STD_LOGIC_VECTOR (31 downto 0);
      destination_address : out STD_LOGIC_VECTOR(4 DOWNTO 0);
      is_float : out std_logic;
      is_ml : out std_logic;
      ml_opcode : out std_logic);
end component;
signal rst : std_logic;
signal clk : std_logic;
signal flush : std_logic; --active low
signal instruction : std_logic_vector(31 downto 0);
signal op_class : STD_LOGIC_VECTOR (4 downto 0);
signal alu_opcode : STD_LOGIC_VECTOR (3 downto 0);
signal a_select : STD_LOGIC;
signal b_select : STD_LOGIC;
signal conditional_opcode : STD_LOGIC_VECTOR (2 downto 0);
signal is_float : std_logic;
signal is_ml : std_logic;
signal ml_opcode : std_logic;
signal pc_in : STD_LOGIC_VECTOR (31 downto 0);
signal destination_value_from_wb : STD_LOGIC_VECTOR (31 downto 0);
signal destination_address_from_wb : STD_LOGIC_VECTOR(4 DOWNTO 0);
signal write_enable_from_wb : STD_LOGIC; 
signal pc_out : STD_LOGIC_VECTOR (31 downto 0);
signal immediate : STD_LOGIC_VECTOR (31 downto 0);
signal r1 : std_logic_vector(4 downto 0);
signal r2 : std_logic_vector(4 downto 0);
signal s_value_1 : STD_LOGIC_VECTOR (31 downto 0); 
signal s_value_2 : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3 : STD_LOGIC_VECTOR (31 downto 0);
signal destination_address : STD_LOGIC_VECTOR(4 DOWNTO 0);
begin

dut :  instruction_decode
Port map(clk => clk,
            rst=>rst,
--            stall => stall,
          	instruction => instruction,
          	op_class => op_class,
          	alu_opcode => alu_opcode,
          	a_select => a_select,
          	b_select => b_select,
          	conditional_opcode => conditional_opcode,
            is_float => is_float,
            is_ml => is_ml,
            ml_opcode => ml_opcode,
            pc_in => pc_in,
            destination_value_from_wb => destination_value_from_wb,
            destination_address_from_wb => destination_address_from_wb,
            write_enable_from_wb => write_enable_from_wb,
            pc_out => pc_out,
            immediate => immediate,
            r1 => r1,
            r2 => r2,
            s_value_1 => s_value_1,
            s_value_2 =>s_value_2 ,
            s_value_3 => s_value_3,
            destination_address => destination_address,
          	flush => flush );
          	
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
actual_process: process begin
    flush <= '0';
    wait for 2.5 ns;
    instruction <= "11111111111111111111111111111111";
    wait for 2 ns;
    flush <= '1';
    wait for 2 ns;
    flush <= '0';
--    instruction <= "00000000010100100000000110110011"; --add
--    wait for 2 ns;
--    instruction <= "01000000010100100000000110110011";  --sub
--    wait for 2 ns;
--    instruction <= "00000010010100100000000110110011";  -- mul
--    wait for 2 ns;
--    instruction <= "00000010100000110100001000110011";  -- div
--    wait for 2 ns;
--    instruction <= "00000000010100100110000110110011";  --or
--    wait for 2 ns;
--    instruction <= "00000000101001011111011000110011";  --and
--    wait for 2 ns;
--    instruction <= "00000000101001011100011000110011";  --xor 
--    wait for 2 ns;
--    instruction <= "00000110100000101011000110000011";  -- ld x3, 104(x5) 
--    wait for 2 ns;
--    instruction <= "00000110100000101010000110000111";  --flw f3, 104(x5) 
--    wait for 2 ns;
--    instruction <= "11111110010001000010111000100011";  --sw x4, -4(x8) 
--    wait for 2 ns;
--    instruction <= "01111110010001000010111110100111";  --fsw f4, 2047(x8) 
--    wait for 2 ns;
--    instruction <= "01111111111100001000001110010011"; --addi
--    wait for 2 ns;
    instruction <= "01111111111111111111010100110111";  -- lui x10, 524287
--    wait for 2 ns;
--    instruction <= "00000000001000000001010010010011";  -- slli x9, x0, 2
--    wait for 2 ns;
--    instruction <= "00000000001000000101010010010011"; -- srli
--    wait for 2 ns;
--    instruction <= "01111010000100000000100111101111";  --  jal x19, 4000
    wait for 2 ns;
    instruction <= "01110110011101001101011001100011";  -- bge x9, x7, 1900
    wait for 2 ns;
    instruction <= "01110110011101001011011001100011";  -- bgt
    wait for 2 ns;
    instruction <= "01110110011101001100011001100011";  -- ble
    wait for 2 ns;
    instruction <= "01110110011101001010011001100011";  -- blt x9, x7, 1900
    wait for 2 ns;
    instruction <= "01110110011101001000011001100011";  -- be x9, x7, 1900
    wait for 2 ns;
    instruction <= "01110110011101001001011001100011";  -- bne x9, x7, 1900 
    wait for 2 ns;
    instruction <= "00000000100101000000011101010111";  -- mac 
    wait for 2 ns;
    instruction <= "00000111111101000010011100110011";  -- cge
    wait for 2 ns;
    instruction <= "00000011111101000010011100110011";  -- cgt
    wait for 2 ns;
    instruction <= "00000000100101000010011100110011";  -- clt x14, x8, x9
    wait for 2 ns;
    instruction <= "00000101111101000010011100110011"; -- cle
    wait for 2 ns;
    instruction <= "00001001111101000010011100110011"; -- ce
    wait for 2 ns;
    instruction <= "00000000100101000001011101010111";  -- leaky relu
    wait for 2 ns;
    instruction <= "00000001101101010001001100110011";  -- sll
    wait for 2 ns;
    instruction <= "00000001101101010101001100110011"; -- srl x6, x10, x27
    wait for 2 ns;
    instruction <= "00000000010100100111000011010011";  --  fadd
    wait for 2 ns;
    instruction <= "00001000010100100111000011010011";  -- fsub
    wait for 2 ns;
    instruction <= "00010000010100100111000011010011"; -- fmul.s f1, f4, f5
    wait;
    end process;


end Behavioral;
