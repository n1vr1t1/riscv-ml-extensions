
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpu_tb is
end fpu_tb;

architecture Behavioral of fpu_tb is
    component fpu
        Port (
            clk : in std_logic;
            fp : in std_logic;
            opcode : in STD_LOGIC_VECTOR (1 downto 0);
            operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
            output : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

signal clk_tb : std_logic := '0';
signal fp_tb : std_logic := '0';
signal opcode_tb : std_logic_vector(1 downto 0) := (others => '0');
signal operand_1_tb : std_logic_vector(31 downto 0) := (others => '0');
signal operand_2_tb : std_logic_vector(31 downto 0) := (others => '0');
signal output_tb : std_logic_vector(31 downto 0);

begin
    clk_process : process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;

    uut: fpu
        port map (
            clk => clk_tb,
            fp => fp_tb,
            opcode => opcode_tb,
            operand_1 => operand_1_tb,
            operand_2 => operand_2_tb,
            output => output_tb
        );

    process begin
        fp_tb <= '1';
        opcode_tb <= "00"; -- add
        operand_1_tb <= x"3F800000"; -- 1.0
        operand_2_tb <= x"40000000"; -- 2.0
        wait for 20 ns;

        fp_tb <= '0';
        operand_1_tb <= x"000000F0"; -- 240
        operand_2_tb <= x"40000000"; -- 1073741824
        wait for 20 ns;

        fp_tb <= '1';
        opcode_tb <= "01"; -- sub
        operand_1_tb <= x"40400000"; -- 3.0
        operand_2_tb <= x"40000000"; -- 2.0
        wait for 20 ns;

        opcode_tb <= "10"; -- mul
        operand_1_tb <= x"3F800000"; -- 1.0
        operand_2_tb <= x"40000000"; -- 2.0
        wait for 20 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"3F800000"; -- 1.0
        operand_2_tb <= x"C0400000"; -- -3.0
        wait for 20 ns;
        
        opcode_tb <= "10"; -- mul
        operand_1_tb <= x"C1000000"; -- -8.0
        operand_2_tb <= x"C0A00000"; -- -5.0
        wait for 20 ns;

        opcode_tb <= "01"; -- sub
        operand_1_tb <= x"C0A00000"; -- -5.0
        operand_2_tb <= x"40400000"; -- 3.0
        wait for 20 ns;

        opcode_tb <= "01"; -- sub
        operand_1_tb <= x"C1000000"; -- -8.0
        operand_2_tb <= x"C0A00000"; -- -5.0
        wait for 20 ns;
        
        opcode_tb <= "11"; -- invalid
        wait for 20 ns;

        wait;
    end process;

end Behavioral;
