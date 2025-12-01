----------------------------------------------------------------------
-- does not do operations with nan, inf or subnormals
-- assumes the input is 0.0 if any of the above numbers are detected
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpu_tb is
end fpu_tb;

architecture Behavioral of fpu_tb is
    component fpu is
        Port (fp : in  std_logic;
            opcode : in  STD_LOGIC_VECTOR (2 downto 0);
            operand_1 : in  STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in  STD_LOGIC_VECTOR (31 downto 0);
            output : out STD_LOGIC_VECTOR (31 downto 0)
          );
    end component;

signal fp_tb : std_logic;
signal opcode_tb : std_logic_vector(2 downto 0);
signal operand_1_tb : std_logic_vector(31 downto 0);
signal operand_2_tb : std_logic_vector(31 downto 0);
signal output_tb : std_logic_vector(31 downto 0);

begin
    uut: fpu
        port map (fp => fp_tb,
            opcode => opcode_tb,
            operand_1 => operand_1_tb,
            operand_2 => operand_2_tb,
            output => output_tb
        );

    process begin
    
        fp_tb <= '0';
        opcode_tb <= "111"; -- 
        operand_1_tb <= x"00000000"; -- 1.0
        operand_2_tb <= x"00000000"; -- 2.0
        wait for 10 ns;
        
        fp_tb <= '1';
        wait for 10 ns;

        -- TEST 1 : ADD (3.5 + 2.25)
        opcode_tb <= "000"; 
        operand_1_tb <= x"40600000";
        operand_2_tb <= x"40100000";
        wait for 20 ns;

        -- TEST 2 : SUB (10.0 - 4.0)
        opcode_tb <= "001"; 
        operand_1_tb <= x"41200000";
        operand_2_tb <= x"40800000";
        wait for 20 ns;

        -- TEST 3 : MUL (1.5 × -2.0)
        opcode_tb <= "010";
        operand_1_tb <= x"3FC00000";
        operand_2_tb <= x"C0000000";
        wait for 20 ns;

        -- TEST 4 : Set Less Than (1.0 < 2.0)
        opcode_tb <= "011";
        operand_1_tb <= x"3F800000";
        operand_2_tb <= x"40000000";
        wait for 20 ns;

        -- TEST 5 : LTE (3.0 <= 3.0)
        opcode_tb <= "100";
        operand_1_tb <= x"40400000";
        operand_2_tb <= x"40400000";
        wait for 20 ns;

        -- TEST 6 : Equal (5.5 == 5.5)
        opcode_tb <= "101";
        operand_1_tb <= x"40B00000";
        operand_2_tb <= x"40B00000";
        wait for 20 ns;

        -- TEST 7 : INT ? FLOAT (42)
        opcode_tb <= "110";
        operand_1_tb <= x"0000002A";
        operand_2_tb <= x"00000000";
        wait for 20 ns;

        -- TEST 8 : FLOAT ? INT (-7.25)
        opcode_tb <= "111";
        operand_1_tb <= x"C0E80000";
        operand_2_tb <= x"00000000";
        wait for 20 ns;


        opcode_tb <= "000"; -- add
        operand_1_tb <= x"00000000"; -- 0.0
        operand_2_tb <= x"00000000"; -- 0.0
        -- result = x"00000000"
        wait for 10 ns;

        opcode_tb <= "001"; -- sub
        -- result = x"80000000"
        wait for 10 ns;

        opcode_tb <= "010"; -- mul
        -- result = x"00000000"
        wait for 10 ns;

        opcode_tb <= "000"; -- add
        operand_1_tb <= x"7f7fffff"; -- max normal
        operand_2_tb <= x"7f7fffff"; -- max normal
        -- result = x"7f800000" -- +Inf
        wait for 10 ns;

        opcode_tb <= "000"; -- add
        operand_1_tb <= x"ff7fffff"; -- min negative normal
        operand_2_tb <= x"ff7fffff"; -- min negative normal
        -- result = x"ff800000" -- -Inf (overflow)
        wait for 10 ns;

        opcode_tb <= "010"; -- mul
        operand_1_tb <= x"7f7fffff"; -- max normal
        operand_2_tb <= x"40000000"; -- 2.0
        -- result = x"7f800000" -- +Inf (overflow)
        wait for 10 ns;

        opcode_tb <= "000"; -- add
        operand_1_tb <= x"7f800000"; -- +Inf
        operand_2_tb <= x"ff800000"; -- -Inf
        -- result = x"00000000" -- (should be NaN, but your FPU sets to 0.0)
        wait for 10 ns;

        opcode_tb <= "001"; -- sub
        operand_1_tb <= x"80000000"; -- -0.0
        operand_2_tb <= x"00000000"; -- +0.0
        -- result = x"80000000" -- -0.0
        wait for 10 ns;
        wait;
    end process;

end Behavioral;
