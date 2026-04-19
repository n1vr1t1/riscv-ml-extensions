library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity comparator_tb is
end comparator_tb;

architecture Behavioral of comparator_tb is

    component comparator
        Port(
            rst : in STD_LOGIC;
            clk : in STD_LOGIC; 
            operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
            cond_opcode : in STD_LOGIC_VECTOR (3 downto 0);
            uncond_branch : in STD_LOGIC;
            branch_condition : out STD_LOGIC
        );
    end component;

    signal rst : STD_LOGIC := '0';
    signal clk : STD_LOGIC := '0';
    signal operand_1 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal operand_2 : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal cond_opcode : STD_LOGIC_VECTOR (3 downto 0) := (others => '0');
    signal uncond_branch : STD_LOGIC := '0';
    signal branch_condition : STD_LOGIC;
    constant clk_period : time := 10 ns;

begin

    dut: comparator PORT MAP (
          rst => rst,
          clk => clk,
          operand_1 => operand_1,
          operand_2 => operand_2,
          cond_opcode => cond_opcode,
          uncond_branch => uncond_branch,
          branch_condition => branch_condition
        );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin		
        rst <= '1';
        wait for 20 ns;	
        rst <= '0';
        wait for clk_period;

        uncond_branch <= '1';
        wait for clk_period;
        assert branch_condition = '1' report "JAL and JALR" severity error;
        uncond_branch <= '0';
        wait for clk_period;

        operand_1 <= x"00000005";
        operand_2 <= x"00000005";
        cond_opcode <= "0000";
        wait for clk_period;
        assert branch_condition = '1' report "BEQ != 1" severity error;

        operand_1 <= x"00000005";
        operand_2 <= x"0000000A";
        wait for clk_period;
        assert branch_condition = '0' report "BEQ != 0" severity error;

        cond_opcode <= "0001";
        wait for clk_period;
        assert branch_condition = '1' report "BNE != 1" severity error;

        operand_1 <= x"FFFFFFFF"; -- -1 in signed
        operand_2 <= x"00000001"; -- 1 in signed
        cond_opcode <= "0100";
        wait for clk_period;
        assert branch_condition = '1' report "BLT (-1 < 1) != 1" severity error;

        cond_opcode <= "0110";
        wait for clk_period;
        assert branch_condition = '0' report "BLTU (max < 1) != 0" severity error;

        operand_1 <= x"0000000A"; -- 10
        operand_2 <= x"00000005"; -- 5
        cond_opcode <= "0101";
        wait for clk_period;
        assert branch_condition = '1' report "BGE (-1 >= 1) != 1" severity error;

        operand_1 <= x"FFFFFFFF";
        operand_2 <= x"0000000A";
        cond_opcode <= "0111";
        wait for clk_period;
        assert branch_condition = '1' report "BGEU (max >= 10) != 1" severity error;

        report "Comparator Testbench Completed Successfully" severity note;
        wait;
    end process;

end Behavioral;
