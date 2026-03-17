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

        assert alu_output = x"BD852828" report "int add failed" severity error;
        
        opcode <= "0001"; -- sub
        wait for 100 ns;

        assert alu_output = x"4388FCA2" report "int sub failed" severity error;
        
        operand_1 <= "00101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";
        wait for 100 ns;

        assert alu_output = x"F1FDCD4D" report "int sub failed" severity error;
        
        opcode <= "0010"; -- mul
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;
        
        assert alu_output = x"00000032" report "int mul failed" severity error;
        opcode <= "0110"; -- or
        wait for 100 ns;

        assert alu_output = x"0000000F" report "int or failed" severity error;
        
        operand_1 <= "10101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";
        wait for 100 ns;

        assert alu_output = x"BE77F7FF" report "int or case 2 failed" severity error;
        
        opcode <= "0111"; -- and
        wait for 100 ns;

        assert alu_output = x"2C7202B2" report "int and failed" severity error;

        operand_1 <= "10101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";
        wait for 100 ns;

        assert alu_output = x"2C7202B2" report "int and case 2 failed" severity error;

        opcode <= "1000"; -- xor
        wait for 100 ns;

        assert alu_output = x"8205F54D" report "int xor failed" severity error;

        operand_1 <= "00101110011100111110001011111111";
        operand_2 <= "00111100011101100001010110110010";
        wait for 100 ns;

        assert alu_output = x"1205F74D" report "int xor case 2 failed" severity error;

        opcode <= "1001";  -- div
        wait for 100 ns;
    
        assert alu_output = x"00000000" report "int div stale operand failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;

        assert alu_output = x"00000002" report "int div 10/5 failed" severity error;

        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        wait for 100 ns;

        assert alu_output = x"00000002" report "int div -10/-5 failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        wait for 100 ns;

        assert alu_output = x"FFFFFFFE" report "int div 10/-5 failed" severity error;

        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;

        assert alu_output = x"FFFFFFFE" report "int div -10/5 failed" severity error;

        opcode <= "0011"; -- slt
        wait for 100 ns;

        assert alu_output = x"FFFFFFF6" report "int slt initial failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;

        assert alu_output = x"00000005" report "int slt 10,5 failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000001010"; -- 10
        wait for 100 ns;

        assert alu_output = x"0000000A" report "int slt 10,10 failed" severity error;

        opcode <= "0100"; -- sle
        wait for 100 ns;

        assert alu_output = x"0000000A" report "int sle initial failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;

        assert alu_output = x"00000005" report "int sle 10,5 failed" severity error;

        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        wait for 100 ns;

        assert alu_output = x"FFFFFFF6" report "int sle -10,-5 failed" severity error;

        opcode <= "1011" ; -- sgt

        wait for 100 ns;

        assert alu_output = x"FFFFFFFB" report "int sgt initial failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;

        assert alu_output = x"0000000A" report "int sgt 10,5 failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000001010"; -- 10
        
        wait for 100 ns;

        assert alu_output = x"0000000A" report "int sgt 10,10 failed" severity error;

        opcode <= "1010"; -- sge

        wait for 100 ns;

        assert alu_output = x"0000000A" report "int sge initial failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;

        assert alu_output = x"0000000A" report "int sge 10,5 failed" severity error;

        operand_1 <= "11111111111111111111111111110110"; -- -10
        operand_2 <= "11111111111111111111111111111011"; -- -5
        
        wait for 100 ns;

        assert alu_output = x"FFFFFFFB" report "int sge -10,-5 failed" severity error;

        opcode <= "0101";  -- se

        wait for 100 ns;

        assert alu_output = x"00000000" report "int se initial failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5

        wait for 100 ns;

        assert alu_output = x"00000000" report "int se 10,5 failed" severity error;

        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000001010"; -- 10
        
        wait for 100 ns;

        assert alu_output = x"00000001" report "int se 10,10 failed" severity error;

        opcode <= "1100"; -- lui
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "01111110111011110110000000000000";
        wait for 100 ns;

        assert alu_output = x"7EEF6000" report "int lui failed" severity error;

        opcode <= "1101"; -- sll
        operand_1 <= "00000000000000000000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;

        assert alu_output = x"00000140" report "int sll by 5 failed" severity error;

        operand_2 <= "00000000000000000000000000001010"; -- 10        
        wait for 100 ns;

        assert alu_output = x"00002800" report "int sll by 10 failed" severity error;

        opcode <= "1110"; -- srl
        operand_1 <= "00000000000011100000000000001010"; -- 10
        operand_2 <= "00000000000000000000000000000101"; -- 5
        wait for 100 ns;

        assert alu_output = x"00007000" report "int srl failed" severity error;
        opcode <= "1111"; -- invalid opcode
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "int invalid opcode failed" severity error;

        -- Testing ml operations
        is_ml <= '1';
        opcode <= "0001"; -- macc
        operand_1 <= x"00000003";  -- 3
        operand_2 <= x"00000004";  -- 4
        operand_3 <= x"00000002";  -- 2
        wait for 100 ns;
        
        assert alu_output = x"0000000E" report "ml int macc failed" severity error;

        opcode <= "0010"; -- leaky relu
        operand_1 <= x"FFFFFFFE";  -- -2 (signed)
        operand_2 <= x"00000003";  -- slope multiplier
        operand_3 <= x"00000000";
        wait for 100 ns;
        
        assert alu_output = x"FFFFFFFA" report "ml int leaky relu failed" severity error;

        is_float <= '1';
        opcode <= "0001"; -- fixed macc
        operand_1 <=  x"3F800000";     -- 1.0
        operand_2 <= x"40000000";     -- 2.0
        operand_3 <=  x"3F000000";     -- 0.5
        wait for 100 ns;
        
        assert alu_output = x"40200000" report "ml float macc failed" severity error;

        opcode <= "0010"; -- fixed leaky relu
        operand_1 <= x"40000000";     -- > 0, should pass through
        operand_2 <=  x"3F000000";     -- leak multiplier not used
        wait for 100 ns;
        
        assert alu_output = x"40000000" report "ml float leaky relu positive failed" severity error;

        operand_1 <= x"BF800000";
        operand_2 <=  x"3F000000";     -- leak slope
        wait for 100 ns;
        
        assert alu_output = x"BF000000" report "ml float leaky relu negative failed" severity error;

        operand_1 <= x"BF800000"; -- -1.0
        operand_2 <= x"3DCCCCCD"; -- alpha (approx 0.1)
        wait for 100 ns;

        opcode <= "0000"; -- Invalid operation
        operand_1 <= x"00000002"; 
        operand_2 <= x"00000003"; 
        operand_3 <= x"00000004"; -- (2*3) + 4 = 10
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "ml float invalid opcode failed" severity error;

        -- Testing Fixed Point
        is_ml <= '0'; is_float <= '1';
        -- add 
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;
        
        assert alu_output = x"40400000" report "float add 1.0 + 2.0 failed" severity error;

        operand_1 <= x"3FC00000"; -- 1.5
        operand_2 <= x"00000000"; -- 0.0
        wait for 100 ns;
        
        assert alu_output = x"3FC00000" report "float add 1.5 + 0.0 failed" severity error;

        operand_1 <= x"40600000"; -- 3.5
        operand_2 <= x"40100000"; -- 2.25
        wait for 100 ns;
        
        assert alu_output = x"40B80000" report "float add 3.5 + 2.25 failed" severity error;

        opcode <= "0001";  -- sub
        operand_1 <= x"41100000"; -- 10.0
        operand_2 <= x"40800000"; -- 4.0
        wait for 100 ns;
        
        assert alu_output = x"40C00000" report "float sub 10.0 - 4.0 failed" severity error;

        opcode <= "0010"; -- mul
        wait for 100 ns;
        
        assert alu_output = x"42200000" report "float mul 10.0 * 4.0 failed" severity error;

        operand_1 <= x"3FC00000"; -- 1.5
        operand_2 <= x"C0000000"; -- -2.0
        wait for 100 ns;
        
        assert alu_output = x"C0400000" report "float mul 1.5 * -2.0 failed" severity error;

        opcode <= "0011"; -- lt/min
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;
        
        assert alu_output = x"3F800000" report "float min 1.0,2.0 failed" severity error;

        operand_1 <= x"40B00000"; -- 5.5 
        wait for 100 ns;
        
        assert alu_output = x"40000000" report "float min 5.5,2.0 failed" severity error;

        opcode <= "0100"; -- gt/max
        wait for 100 ns;
        
        assert alu_output = x"40B00000" report "float max 5.5,2.0 failed" severity error;

        operand_1 <= x"3F800000"; -- 1.0
        wait for 100 ns;
        
        assert alu_output = x"40000000" report "float max 1.0,2.0 failed" severity error;

        opcode <= "0101"; -- lte
        wait for 100 ns;
        
        assert alu_output = x"3F800000" report "float lte 1.0<=2.0 failed" severity error;

        operand_1 <= x"40B00000"; -- 5.5 
        wait for 100 ns;
        
        assert alu_output = x"40000000" report "float lte 5.5<=2.0 failed" severity error;

        operand_1 <= x"40400000"; -- 3.0
        operand_2 <= x"40400000"; -- 3.0
        wait for 100 ns;
        
        assert alu_output = x"40400000" report "float lte 3.0<=3.0 failed" severity error;

        opcode <= "0110"; --  eq
        operand_1 <= x"40B00000"; -- 5.5 
        operand_2 <= x"40B00000"; -- 5.5
        wait for 100 ns;
        
        assert alu_output = x"00000001" report "float eq failed" severity error;

        opcode <= "0111"; -- int to float
        operand_1 <= x"0000002A"; -- 42
        operand_2 <= x"00000000";
        wait for 100 ns;
        
        assert alu_output = x"42280000" report "i2f failed for 42" severity error;

        operand_1 <= x"00000000"; -- 0.0
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "i2f failed for 0" severity error;
        
        operand_1 <= x"00000001"; -- 1
        wait for 100 ns;
        
        assert alu_output = x"3F800000" report "i2f failed for 1" severity error;
        
        operand_1 <= x"FFFFFFFF"; -- -1
        wait for 100 ns;
        
        assert alu_output = x"BF800000" report "i2f failed for -1" severity error;

        operand_1 <= x"FFFFFFF6"; -- -10
        wait for 100 ns;
        
        assert alu_output = x"C1200000" report "i2f failed for -10" severity error;

        operand_1 <= x"00010000"; -- 65536
        wait for 100 ns;
        
        assert alu_output = x"47800000" report "i2f failed for 65536" severity error;
        
        operand_1 <= x"FFFF0000"; -- -65536
        wait for 100 ns;
        
        assert alu_output = x"C7800000" report "i2f failed for -65536" severity error;

        operand_1 <= x"7FFFFFFF"; -- 2147483647
        wait for 100 ns;
        
        operand_1 <= x"80000000"; -- -2147483648
        wait for 100 ns;

        opcode <= "1000"; -- float to int
        operand_1 <= x"C0E80000"; -- -7.25
        operand_2 <= x"00000000";
        wait for 100 ns;
        
        assert alu_output = x"FFFFFFF9" report "f2i failed for -7.25 (expected -7)" severity error;

        operand_1 <= x"40F80000"; -- 7.75
        wait for 100 ns;
        
        assert alu_output = x"00000007" report "f2i failed for 7.75 (expected 7)" severity error;

        operand_1 <= x"3F7D70A4"; -- ~0.99
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "f2i failed for 0.99 (expected 0)" severity error;

        operand_1 <= x"BF7D70A4"; -- ~-0.99
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "f2i failed for -0.99 (expected 0)" severity error;

        operand_1 <= x"3F800000"; -- 1.0
        wait for 100 ns;
        
        assert alu_output = x"00000001" report "f2i failed for 1.0" severity error;

        operand_1 <= x"BF800000"; -- -1.0
        wait for 100 ns;
        
        assert alu_output = x"FFFFFFFF" report "f2i failed for -1.0" severity error;

        operand_1 <= x"42800000"; -- 64.0
        wait for 100 ns;
        
        assert alu_output = x"00000040" report "f2i failed for 64.0" severity error;

        operand_1 <= x"C2800000"; -- -64.0
        wait for 100 ns;
        
        assert alu_output = x"FFFFFFC0" report "f2i failed for -64.0" severity error;

        operand_1 <= x"00000000"; -- +0.0
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "f2i failed for +0.0" severity error;

        operand_1 <= x"80000000"; -- -0.0
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "f2i failed for -0.0" severity error;

        opcode <= "0000"; -- add
        operand_1 <= x"00000000"; -- 0.0
        operand_2 <= x"00000000"; -- 0.0
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "float add 0 + 0 failed" severity error;

        opcode <= "0001"; -- sub
        -- result = x"80000000"
        wait for 100 ns;

        opcode <= "0010"; -- mul
        wait for 100 ns;
        
        assert alu_output = x"00000000" report "float mul 0 * 0 failed" severity error;

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
        
        assert alu_output = x"00000000" report "disabled ALU should drive zero" severity error;
        
        wait;
    end process;

end Behavioral;