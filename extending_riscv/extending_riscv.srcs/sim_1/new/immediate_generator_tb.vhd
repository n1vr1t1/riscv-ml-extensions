library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity immediate_generator_tb is
end immediate_generator_tb;

architecture Behavioral of immediate_generator_tb is

    component immediate_generator is
        Port (rst : in std_logic;
              clk : in std_logic;
              flush : in std_logic;
              opcode : in STD_LOGIC_VECTOR(6 downto 0);
              instruction : in STD_LOGIC_VECTOR(31 downto 7);
              immediate : out STD_LOGIC_VECTOR(31 downto 0));
    end component;

    signal rst : std_logic := '0';
    signal clk : std_logic := '0';
    signal flush : std_logic := '0';
    signal opcode : std_logic_vector(6 downto 0) := (others => '0');
    signal instruction_bits : std_logic_vector(31 downto 7) := (others => '0');
    signal immediate : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;

begin

    dut: immediate_generator
        port map (
            rst => rst,
            clk => clk,
            flush => flush,
            opcode => opcode,
            instruction => instruction_bits,
            immediate => immediate
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
        procedure check_imm(
            constant test_name : in string;
            constant op        : in std_logic_vector(6 downto 0);
            constant inst      : in std_logic_vector(31 downto 7);
            constant expected  : in std_logic_vector(31 downto 0)
        ) is
        begin
            opcode <= op;
            instruction_bits <= inst;
            wait until rising_edge(clk);
            wait for 1 ns;
            assert immediate = expected 
                report test_name & " failed: Expected " & to_hstring(expected) & " but got " & to_hstring(immediate)
                severity error;
        end procedure;

    begin
        -- Reset state
        rst <= '0';
        flush <= '0';
        wait for 20 ns;
        rst <= '1';
        wait for 5 ns;

        check_imm("addi positive imm", "0010011", "0111111111110000000000000", x"000007FF");

        check_imm("addi negative imm", "0010011", "1111111111110000000000000", x"FFFFFFFF");

        check_imm("slti", "0010011", "0000000010100000101000000", x"0000000A"); -- imm=10
        check_imm("xori", "0010011", "1111111111110100001000000", x"FFFFFFFF"); -- imm=-1
        check_imm("ori", "0010011", "0000111111110110001000000", x"000000FF"); -- imm=255
        check_imm("andi", "0010011", "0000000000010111001000000", x"00000001"); -- imm=1

        check_imm("slli", "0010011", "0000000001010000100000000", x"00000005");

        check_imm("srli", "0010011", "0000000011110000101000000", x"0000000F");

        check_imm("store positive offset", "0100011", "0000000010100001000000100", x"00000004");
        check_imm("store negative offset", "0100011", "1111111010100001000010001", x"FFFFFFE4");

        check_imm("float store", "0100111", "0000000010100001001000100", x"00000004");

        check_imm("vector store", "0100111", "0000000010100001000000100", x"00000000");

        check_imm("load", "0000011", "0000000001000000101000001", x"00000004");

        check_imm("float load", "0000111", "0000000001000000101000001", x"00000004");

        check_imm("vector load", "0000111", "0000000001000000100000001", x"00000000");

        check_imm("beq forward", "1100011", "0000000000100000100000100", x"00000008");
        check_imm("beq backward", "1100011", "1111111000000000000000111", x"FFFFFFF8");

        check_imm("jal", "1101111", "0000000010000000000000001", x"00000008");

        check_imm("lui", "0110111", "0001001000110100010100101", x"12345000");

        check_imm("vector imm", "1010111", "0000001001010000001100101", x"00000005");

        report "Immediate Generator testing completed successfully" severity note;
        wait;
    end process;

end Behavioral;
