-- filepath: c:\Users\Nivriti\Desktop\University\Thesis\riscv-ml-extensions\extending_riscv\extending_riscv.srcs\sim_1\new\alu_tb.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is
    -- Component Declaration
    component alu is
        Port( opcode : in STD_LOGIC_VECTOR( 3 downto 0);
              operand_1 : in STD_LOGIC_VECTOR( 31 downto 0);
              operand_2 : in STD_LOGIC_VECTOR( 31 downto 0);
              operand_3 : in STD_LOGIC_VECTOR( 31 downto 0);
              is_float : in STD_LOGIC;
              is_ml : in STD_LOGIC;
              en : in STD_LOGIC;
              alu_output : out STD_LOGIC_VECTOR( 31 downto 0) );
    end component;

-- Signals
signal opcode      : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
signal operand_1    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal operand_2    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal operand_3    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal is_float    : STD_LOGIC := '0';
signal is_ml       : STD_LOGIC := '0';
signal en          : STD_LOGIC := '1';
signal alu_output  : STD_LOGIC_VECTOR(31 downto 0);

begin
    -- Instantiate UUT
    uut: alu 
        port map (
            opcode => opcode,
            operand_1 => operand_1,
            operand_2 => operand_2,
            operand_3 => operand_3,
            is_float => is_float,
            is_ml => is_ml,
            en => en,
            alu_output => alu_output
        );

    stim_proc: process
    begin
        -- Testing out interger operations
        en <= '1'; is_float <= '0'; is_ml <= '0';
        opcode <= "0000"; -- add
        operand_1 <= "00000000000011110001001001010100";
        operand_2 <= "10111100011101100001010110110010";

        wait for 100 ns;
        opcode <= "0001"; -- sub

        wait for 100 ns;
        operand_1 <= "00101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";

        wait for 100 ns;
        opcode <= "0010"; -- mul
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        opcode <= "0110"; -- or

        wait for 100 ns;
        operand_1 <= "10101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";

        wait for 100 ns;
        opcode <= "0111"; -- and

        wait for 100 ns;
        operand_1 <= "10101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";

        wait for 100 ns;
        opcode <= "1000"; -- xor

        wait for 100 ns;
        operand_1 <= "00101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";

        wait for 100 ns;
        opcode <= "1001";  -- div

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        
        wait for 100 ns;
        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        
        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        
        wait for 100 ns;
        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        opcode <= "0011"; -- slt

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000001010"; -- 10

        wait for 100 ns;
        opcode <= "0100"; -- sle

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "11111111111111111111111111111011"; -- -5

        wait for 100 ns;
        opcode <= "1011" ; -- sgt

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000001010"; -- 10
        
        wait for 100 ns;
        opcode <= "1010"; -- sge

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        
        wait for 100 ns;
        opcode <= "0101";  -- se

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000001010"; -- 10
        
        wait for 100 ns;
        opcode <= "1100"; -- lui
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "01111110111011110110000000000000";

        wait for 100 ns;
        opcode <= "1101"; -- sll
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        operand_2 <= "00000000000000000000000000001010"; -- 10
        
        wait for 100 ns;
        opcode <= "1110"; -- srl
        operand_1 <= "00000000000011100000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;
        opcode <= "1111"; -- invalid opcode

        -- Testing ml operations
        is_ml <= '1';
        opcode <= "0001"; -- macc
        operand_1 <= x"00000003";  -- 3
        operand_2 <= x"00000004";  -- 4
        operand_3 <= x"00000002";  -- 2
        wait for 100 ns;
        -- output <= 14

        opcode <= "0010"; -- leaky relu
        operand_1 <= x"FFFFFFFE";  -- -2 (signed)
        operand_2 <= x"00000003";  -- slope multiplier
        operand_3 <= x"00000000";
        wait for 100 ns;
        -- output <= -6

        is_float <= '1';
        opcode <= "0001"; -- fixed macc
        operand_1 <=  x"3F800000";     -- 1.0
        operand_2 <= x"40000000";     -- 2.0
        operand_3 <=  x"3F000000";     -- 0.5
        wait for 100 ns;
        -- output <= 2.5

        opcode <= "0010"; -- fixed leaky relu
        operand_1 <= x"40000000";     -- > 0, should pass through
        operand_2 <=  x"3F000000";     -- leak multiplier not used
        wait for 100 ns;
        -- output <= 2.0

        operand_1 <= x"BF800000";
        operand_2 <=  x"3F000000";     -- leak slope
        wait for 100 ns;
        -- output <= -0.5

        operand_1 <= x"BF800000"; -- -1.0
        operand_2 <= x"3DCCCCCD"; -- alpha (approx 0.1)
        wait for 100 ns;

        opcode <= "0000"; -- Invalid operation
        operand_1 <= x"00000002"; 
        operand_2 <= x"00000003"; 
        operand_3 <= x"00000004"; -- (2*3) + 4 = 10
        wait for 100 ns;

        -- Testing Fixed Point
        is_ml <= '0'; is_float <= '1';
        -- add 
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;

        operand_1 <= x"3FC00000"; -- 1.5
        operand_2 <= x"00000000"; -- 0.0
        wait for 100 ns;

        operand_1 <= x"40600000"; -- 3.5
        operand_2 <= x"40100000"; -- 2.25
        wait for 100 ns;

        opcode <= "0001";  -- sub
        operand_1 <= x"41100000"; -- 10.0
        operand_2 <= x"40800000"; -- 4.0
        wait for 100 ns;

        opcode <= "0010"; -- mul
        wait for 100 ns;

        operand_1 <= x"3FC00000"; -- 1.5
        operand_2 <= x"C0000000"; -- -2.0
        wait for 100 ns;

        opcode <= "0011"; -- lt/min
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;

        operand_1 <= x"40B00000"; -- 5.5 
        wait for 100 ns;

        opcode <= "0100"; -- gt/max
        wait for 100 ns;

        operand_1 <= x"3F800000"; -- 1.0
        wait for 100 ns;

        opcode <= "0101"; -- lte
        wait for 100 ns;

        operand_1 <= x"40B00000"; -- 5.5 
        wait for 100 ns;

        operand_1 <= x"40400000"; -- 3.0
        operand_2 <= x"40400000"; -- 3.0
        wait for 100 ns;

        opcode <= "0110"; --  eq
        operand_1 <= x"40B00000"; -- 5.5 
        operand_2 <= x"40B00000"; -- 5.5
        wait for 100 ns;

        opcode <= "0111"; -- int to float
        operand_1 <= x"0000002A"; -- 42
        operand_2 <= x"00000000";
        wait for 100 ns;

        opcode <= "1000"; -- float to int
        operand_1 <= x"C0E80000"; -- -7.25
        operand_2 <= x"00000000";
        wait for 100 ns;


        opcode <= "0000"; -- add
        operand_1 <= x"00000000"; -- 0.0
        operand_2 <= x"00000000"; -- 0.0
        -- result = x"00000000"
        wait for 100 ns;

        opcode <= "0001"; -- sub
        -- result = x"80000000"
        wait for 100 ns;

        opcode <= "0010"; -- mul
        -- result = x"00000000"
        wait for 100 ns;

        opcode <= "0000"; -- add
        operand_1 <= x"7f7fffff"; -- max normal
        operand_2 <= x"7f7fffff"; -- max normal
        -- result = x"7f800000" -- +Inf
        wait for 100 ns;

        opcode <= "0000"; -- add
        operand_1 <= x"ff7fffff"; -- min negative normal
        operand_2 <= x"ff7fffff"; -- min negative normal
        -- result = x"ff800000" -- -Inf (overflow)
        wait for 100 ns;

        opcode <= "0010"; -- mul
        operand_1 <= x"7f7fffff"; -- max normal
        operand_2 <= x"40000000"; -- 2.0
        -- result = x"7f800000" -- +Inf (overflow)
        wait for 100 ns;

        opcode <= "0000"; -- add
        operand_1 <= x"7f800000"; -- +Inf
        operand_2 <= x"ff800000"; -- -Inf
        -- result = x"00000000" -- (should be NaN, but is_floatU sets to 0.0)
        wait for 100 ns;

        opcode <= "0001"; -- sub
        operand_1 <= x"80000000"; -- -0.0
        operand_2 <= x"00000000"; -- +0.0
        -- result = x"80000000" -- -0.0

        -- Disabled ALU
        en <= '0';
        wait for 100 ns;
        
        wait;
    end process;

end Behavioral;