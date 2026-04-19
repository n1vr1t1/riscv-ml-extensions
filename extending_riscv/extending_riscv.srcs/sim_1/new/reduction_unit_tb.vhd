library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity reduction_unit_tb is
end reduction_unit_tb;

architecture Behavioral of reduction_unit_tb is
    component reduction_unit
        Port (rst : in std_logic;
            clk : in std_logic;
            operand_1 : in std_logic_vector(31 downto 0);
            operand_2 : in std_logic_vector(31 downto 0);
            operand_3 : in std_logic_vector(31 downto 0);
            operand_4 : in std_logic_vector(31 downto 0);
            operand_5 : in std_logic_vector(31 downto 0);
            opcode : in std_logic_vector(2 downto 0);
            fp_en : in std_logic;
            en : in std_logic;
            result : out std_logic_vector(31 downto 0));
    end component;

signal rst : std_logic;
signal clk : std_logic;
signal operand_1 : std_logic_vector(31 downto 0) := (others => '0');
signal operand_2 : std_logic_vector(31 downto 0) := (others => '0');
signal operand_3 : std_logic_vector(31 downto 0) := (others => '0');
signal operand_4 : std_logic_vector(31 downto 0) := (others => '0');
signal operand_5 : std_logic_vector(31 downto 0) := (others => '0');
signal opcode : std_logic_vector(2 downto 0) := (others => '0');
signal fp_en : std_logic := '0';
signal en : std_logic := '0';
signal result : std_logic_vector(31 downto 0);
constant clk_period : time := 10 ns;

begin
    dut: reduction_unit
        port map (
        rst => rst,
        clk => clk,
            operand_1 => operand_1,
            operand_2 => operand_2,
            operand_3 => operand_3,
            operand_4 => operand_4,
            operand_5 => operand_5,
            opcode => opcode,
            fp_en => fp_en,
            en => en,
            result => result);
            
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    process begin
    
        rst <= '1';
        wait for 20ns;
        rst <= '0';

        en <= '0';
        wait for 20 ns;
        assert result = x"00000000" report "Failed: Disabling unit" severity error;

        en <= '1'; fp_en <= '0'; opcode <= "000";
        operand_1 <= x"00000001";
        operand_2 <= x"00000002"; 
        operand_3 <= x"00000003"; 
        operand_4 <= x"00000004"; 
        operand_5 <= x"00000005"; 
        wait until rising_edge(clk);
        wait for 2 ns;
        assert result = x"0000000F" report "Failed: VREDSUM" severity error;

        opcode <= "001";
        operand_1 <= x"FFFFFFFF";
        operand_2 <= x"0000FFFF";
        operand_3 <= x"FFFF0000";
        operand_4 <= x"AAAAAAAA";
        operand_5 <= x"55555555";
        wait until rising_edge(clk);
        wait for 2 ns;
        assert result = x"00000000" report "Failed: VREDAND" severity error;

        opcode <= "100";
        operand_1 <= x"00000010";
        operand_2 <= x"00000005";
        operand_3 <= x"00000020";
        operand_4 <= x"00000002";
        operand_5 <= x"00000008";
        wait until rising_edge(clk);
        wait for 2 ns;
        assert result = x"00000002" report "Failed: VREDMIN" severity error;

        fp_en <= '1'; opcode <= "000";
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        operand_3 <= x"40000000"; -- 2.0
        operand_4 <= x"3F800000"; -- 1.0
        operand_5 <= x"40000000"; -- 2.0
        wait until rising_edge(clk);
        wait for 2 ns;
        assert result = x"41000000" report "Failed: VFREDUSUM" severity error;

        opcode <= "010";
        operand_1 <= x"3F800000"; -- 1.0
        operand_2 <= x"40000000"; -- 2.0
        operand_3 <= x"40800000"; -- 4.0
        operand_4 <= x"40400000"; -- 3.0
        operand_5 <= x"40000000"; -- 2.0
        wait until rising_edge(clk);
        wait for 2 ns;
        assert result = x"40800000" report "Failed: VFREDMAX" severity error; -- Expected result: 4.0

        wait;
    end process;

end Behavioral;
