library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_tb is
end alu_tb;

architecture Behavioral of alu_tb is
    component alu is
        Port( rst: in std_logic;
              clk : in std_logic;
              opcode : in STD_LOGIC_VECTOR( 3 downto 0);
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
signal operand_1   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal operand_2   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal operand_3   : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal is_float    : STD_LOGIC := '0';
signal is_ml       : STD_LOGIC := '0';
signal en          : STD_LOGIC := '1';
signal alu_output  : STD_LOGIC_VECTOR(31 downto 0);
signal clk         : STD_LOGIC := '0';
signal rst         : STD_LOGIC := '0';
constant clk_period : time := 10 ns;
begin
    dut: alu 
        port map (
        rst => rst,
        clk => clk,
            opcode => opcode,
            operand_1 => operand_1,
            operand_2 => operand_2,
            operand_3 => operand_3,
            is_float => is_float,
            is_ml => is_ml,
            en => en,
            alu_output => alu_output
        );
clk_process: process begin
    clk <= '1';
    wait for clk_period;
    clk <= '0';
    wait for clk_period;
end process;

    process begin
    rst <= '0';
    wait for 100ns;
    rst <= '1';
        en <= '1'; 
        is_float <= '0'; 
        is_ml <= '0';
        opcode <= "0000";
        operand_1 <= x"0000000F"; -- 15
        operand_2 <= x"00000001"; -- 1
        wait for 100 ns;
        assert (alu_output = x"00000010") report "Integer Add failed" severity error;

        opcode <= "0001";
        operand_1 <= x"0000000F"; -- 15
        operand_2 <= x"00000001"; -- 1
        wait for 100 ns;
        assert (alu_output = x"0000000E") report "Integer Sub failed" severity error;

        opcode <= "0010";
        operand_1 <= x"0000000A"; -- 10
        operand_2 <= x"00000005"; -- 5
        wait for 100 ns;
        assert (alu_output = x"00000032") report "Integer Mul failed" severity error;

        opcode <= "0011";
        operand_1 <= x"0000000A"; -- 10
        operand_2 <= x"00000005"; -- 5
        wait for 100 ns;
        assert (alu_output = x"00000005") report "Integer SLT (min) failed" severity error;

        opcode <= "0100";
        operand_1 <= x"FFFFFFF6"; -- -10
        operand_2 <= x"FFFFFFF7"; -- -9
        wait for 100 ns;
        assert (alu_output = x"FFFFFFF6") report "Integer SLE failed" severity error;

        opcode <= "0101";
        operand_1 <= x"0000000A";
        operand_2 <= x"0000000A";
        wait for 100 ns;
        assert (alu_output = x"00000001") report "Integer SE failed" severity error;

        opcode <= "0110";
        operand_1 <= x"0000000F";
        operand_2 <= x"000000F0";
        wait for 100 ns;
        assert (alu_output = x"000000FF") report "Integer OR failed" severity error;

        opcode <= "0111";
        operand_1 <= x"000000FF";
        operand_2 <= x"0000000F";
        wait for 100 ns;
        assert (alu_output = x"0000000F") report "Integer AND failed" severity error;

        opcode <= "1000";
        operand_1 <= x"000000FF";
        operand_2 <= x"0000000F";
        wait for 100 ns;
        assert (alu_output = x"000000F0") report "Integer XOR failed" severity error;

        opcode <= "1001";
        operand_1 <= x"0000000A"; -- 10
        operand_2 <= x"00000005"; -- 5
        wait for 100 ns;
        assert (alu_output = x"00000002") report "Integer DIV failed" severity error;

        opcode <= "1010";
        operand_1 <= x"0000000A";
        operand_2 <= x"00000005";
        wait for 100 ns;
        assert (alu_output = x"0000000A") report "Integer SGE failed" severity error;

        opcode <= "1011";
        operand_1 <= x"0000000A";
        operand_2 <= x"00000005";
        wait for 100 ns;
        assert (alu_output = x"0000000A") report "Integer SGT failed" severity error;

        opcode <= "1100";
        operand_2 <= x"12345678";
        wait for 100 ns;
        assert (alu_output = x"12345678") report "Integer LUI failed" severity error;

        opcode <= "1101";
        operand_1 <= x"00000001";
        operand_2 <= x"00000004";
        wait for 100 ns;
        assert (alu_output = x"00000010") report "Integer SLL failed" severity error;

        opcode <= "1110";
        operand_1 <= x"00000010";
        operand_2 <= x"00000004";
        wait for 100 ns;
        assert (alu_output = x"00000001") report "Integer SRL failed" severity error;

        is_ml <= '1';
        opcode <= "0001";
        operand_1 <= x"00000003";  -- 3
        operand_2 <= x"00000004";  -- 4
        operand_3 <= x"00000002";  -- 2
        wait for 100 ns;
        assert (alu_output = x"0000000E") report "ML MACC failed" severity error;

        opcode <= "0010";
        operand_1 <= x"FFFFFFFE";  -- -2
        operand_2 <= x"00000003";  -- slope
        wait for 100 ns;
        assert (alu_output = x"FFFFFFFA") report "ML Leaky ReLU failed" severity error; -- -2 * 3 = -6

        is_ml <= '0'; 
        is_float <= '1';
        opcode <= "0000";
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;
        assert (alu_output = x"40400000") report "Float Add failed" severity error; -- 3.0

        opcode <= "0001";
        operand_1 <= x"40800000"; -- 4.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;
        assert (alu_output = x"40000000") report "Float Sub failed" severity error; -- 2.0

        opcode <= "0010";
        operand_1 <= x"40000000"; -- 2.0
        operand_2 <= x"3FC00000"; -- 1.5
        wait for 100 ns;
        assert (alu_output = x"40400000") report "Float Mul failed" severity error; -- 3.0

        opcode <= "0011";
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        wait for 100 ns;
        assert (alu_output = x"3F800000") report "Float Min failed" severity error;

        opcode <= "0110";
        operand_1 <= x"40400000"; -- 3.0
        operand_2 <= x"40400000"; -- 3.0
        wait for 100 ns;
        assert (alu_output = x"00000001") report "Float EQ failed" severity error;

        opcode <= "0111";
        operand_1 <= x"0000000A"; -- 10
        wait for 100 ns;
        assert (alu_output = x"41200000") report "Int to Float failed" severity error;

        opcode <= "1000";
        operand_1 <= x"41200000"; -- 10.0
        wait for 100 ns;
        assert (alu_output = x"0000000A") report "Float to Int failed" severity error;

        is_ml <= '1';
        opcode <= "0001";
        operand_1 <= x"40000000"; -- 2.0
        operand_2 <= x"3F800000"; -- 1.0
        operand_3 <= x"3F000000"; -- 0.5
        wait for 100 ns;
        assert (alu_output = x"40200000") report "ML FMACC failed" severity error; -- 2.5

        opcode <= "0010";
        operand_1 <= x"BF800000"; -- -1.0
        operand_2 <= x"3DCCCCCD"; -- 0.1
        wait for 100 ns;
        assert (alu_output = x"BDCCCCC0") report "ML Float Leaky ReLU failed" severity error;

        en <= '0';
        wait for 100 ns;
        assert (alu_output = x"00000000") report "ALU Disable failed" severity error;
        
        report "All tests completed successfully";
        wait;
    end process;

end Behavioral;