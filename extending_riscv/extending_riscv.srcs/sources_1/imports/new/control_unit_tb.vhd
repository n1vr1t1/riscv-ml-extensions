library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit_tb is
end control_unit_tb;

architecture Behavioral of control_unit_tb is

    component control_unit
        Port (
            rst : in std_logic;
            clk : in std_logic;
            opclass : in std_logic_vector(4 downto 0);
            vec_en_if : in std_logic;
            vec_en_id : in std_logic;
            vec_en_ex : in std_logic;
            rs1_id : in std_logic_vector(4 downto 0);
            rs2_id : in std_logic_vector(4 downto 0);
            rs3_id : in std_logic_vector(4 downto 0);
            rd_ex : in std_logic_vector(4 downto 0);
            con_data_hazard_1 : out std_logic;
            con_data_hazard_2 : out std_logic;
            con_data_hazard_3 : out std_logic;
            con_vd_hazard_1 : out std_logic;
            con_vd_hazard_2 : out std_logic;
            con_vd_hazard_3 : out std_logic;
            rs1_if : in std_logic_vector(4 downto 0);
            rs2_if : in std_logic_vector(4 downto 0);
            rs3_if : in std_logic_vector(4 downto 0);
            data_hazard_1 : out std_logic;
            data_hazard_2 : out std_logic;
            data_hazard_3 : out std_logic;
            vec_data_hazard_1 : out std_logic;
            vec_data_hazard_2 : out std_logic;
            vec_data_hazard_3 : out std_logic;
            load_hazard_1 : out std_logic;
            load_hazard_2 : out std_logic;
            load_hazard_3 : out std_logic;
            vec_load_hazard_1 : out STD_LOGIC_VECTOR(3 downto 0);
            vec_load_hazard_2 : out STD_LOGIC_VECTOR(3 downto 0);
            vec_load_hazard_3 : out STD_LOGIC_VECTOR(3 downto 0);
            vd_element : in std_logic_vector(3 downto 0);
            a_select : in STD_LOGIC;
            b_select : in STD_LOGIC;
            branch_condition : in STD_LOGIC;
            flush : out STD_LOGIC
        );
    end component;

    -- Inputs
    signal rst : std_logic := '0';
    signal clk : std_logic := '0';
    signal opclass : std_logic_vector(4 downto 0) := (others => '0');
    signal vec_en_if : std_logic := '0';
    signal vec_en_id : std_logic := '0';
    signal vec_en_ex : std_logic := '0';
    signal rs1_id : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2_id : std_logic_vector(4 downto 0) := (others => '0');
    signal rs3_id : std_logic_vector(4 downto 0) := (others => '0');
    signal rd_ex : std_logic_vector(4 downto 0) := (others => '0');
    signal rs1_if : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2_if : std_logic_vector(4 downto 0) := (others => '0');
    signal rs3_if : std_logic_vector(4 downto 0) := (others => '0');
    signal vd_element : std_logic_vector(3 downto 0) := (others => '0');
    signal a_select : std_logic := '0';
    signal b_select : std_logic := '0';
    signal branch_condition : std_logic := '0';

    -- Outputs
    signal con_data_hazard_1 : std_logic;
    signal con_data_hazard_2 : std_logic;
    signal con_data_hazard_3 : std_logic;
    signal con_vd_hazard_1 : std_logic;
    signal con_vd_hazard_2 : std_logic;
    signal con_vd_hazard_3 : std_logic;
    signal data_hazard_1 : std_logic;
    signal data_hazard_2 : std_logic;
    signal data_hazard_3 : std_logic;
    signal vec_data_hazard_1 : std_logic;
    signal vec_data_hazard_2 : std_logic;
    signal vec_data_hazard_3 : std_logic;
    signal load_hazard_1 : std_logic;
    signal load_hazard_2 : std_logic;
    signal load_hazard_3 : std_logic;
    signal vec_load_hazard_1 : std_logic_vector(3 downto 0);
    signal vec_load_hazard_2 : std_logic_vector(3 downto 0);
    signal vec_load_hazard_3 : std_logic_vector(3 downto 0);
    signal flush : std_logic;

    constant clk_period : time := 10 ns;

begin

    uut: control_unit PORT MAP (
        rst => rst,
        clk => clk,
        opclass => opclass,
        vec_en_if => vec_en_if,
        vec_en_id => vec_en_id,
        vec_en_ex => vec_en_ex,
        rs1_id => rs1_id,
        rs2_id => rs2_id,
        rs3_id => rs3_id,
        rd_ex => rd_ex,
        con_data_hazard_1 => con_data_hazard_1,
        con_data_hazard_2 => con_data_hazard_2,
        con_data_hazard_3 => con_data_hazard_3,
        con_vd_hazard_1 => con_vd_hazard_1,
        con_vd_hazard_2 => con_vd_hazard_2,
        con_vd_hazard_3 => con_vd_hazard_3,
        rs1_if => rs1_if,
        rs2_if => rs2_if,
        rs3_if => rs3_if,
        data_hazard_1 => data_hazard_1,
        data_hazard_2 => data_hazard_2,
        data_hazard_3 => data_hazard_3,
        vec_data_hazard_1 => vec_data_hazard_1,
        vec_data_hazard_2 => vec_data_hazard_2,
        vec_data_hazard_3 => vec_data_hazard_3,
        load_hazard_1 => load_hazard_1,
        load_hazard_2 => load_hazard_2,
        load_hazard_3 => load_hazard_3,
        vec_load_hazard_1 => vec_load_hazard_1,
        vec_load_hazard_2 => vec_load_hazard_2,
        vec_load_hazard_3 => vec_load_hazard_3,
        vd_element => vd_element,
        a_select => a_select,
        b_select => b_select,
        branch_condition => branch_condition,
        flush => flush
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
        rst <= '0';
        wait for 20 ns;
        rst <= '1';
        wait for clk_period;

        a_select <= '1';
        b_select <= '1';
        branch_condition <= '1';
        wait until rising_edge(clk); wait for 1 ns;
        assert flush = '1' report "Flush failed" severity error;
        
        branch_condition <= '0';
        wait until rising_edge(clk); wait for 1 ns;
        assert flush = '0' report "Flush reset failed" severity error;
        
        opclass <= "00100";
        rd_ex <= "00010";
        rs1_if <= "00010";
        wait until rising_edge(clk); wait for 1 ns;
        assert data_hazard_1 = '1' report "Data Hazard 1 test failed" severity error;

        vec_en_if <= '1';
        vec_en_ex <= '1';
        rd_ex <= "00011";
        rs1_if <= "00011";
        wait until rising_edge(clk); wait for 1 ns;
        assert vec_data_hazard_1 = '1' and data_hazard_1 = '0' report "Vector Data Hazard 1 test failed" severity error;

        rd_ex <= "00000";
        wait until rising_edge(clk); wait for 1 ns;
        assert data_hazard_1 = '0' and vec_data_hazard_1 = '0' report "Hazard clear test failed" severity error;
        
        opclass <= "00100"; vec_en_if <= '0'; vec_en_ex <= '0';
        rd_ex <= "00001";
        rs1_if <= "00001"; rs2_if <= "00001"; rs3_if <= "00001";
        wait until rising_edge(clk); wait for 1 ns;
        assert data_hazard_1 = '1' report "data_hazard_1 failed" severity error;
        assert data_hazard_2 = '1' report "data_hazard_2 failed" severity error;
        assert data_hazard_3 = '1' report "data_hazard_3 failed" severity error;

        vec_en_if <= '1'; vec_en_ex <= '1';
        rd_ex <= "01001";
        rs1_if <= "01001"; rs2_if <= "01001"; rs3_if <= "01001";
        wait until rising_edge(clk); wait for 1 ns;
        assert vec_data_hazard_1 = '1' and data_hazard_1 = '0' report "vec_data_hazard_1 failed" severity error;
        assert vec_data_hazard_2 = '1' and data_hazard_2 = '0' report "vec_data_hazard_2 failed" severity error;
        assert vec_data_hazard_3 = '1' and data_hazard_3 = '0' report "vec_data_hazard_3 failed" severity error;

        vec_en_if <= '0'; vec_en_ex <= '0'; vec_en_id <= '0';
        rd_ex <= "00010";
        rs1_id <= "00010"; rs2_id <= "00010"; rs3_id <= "00010";
        opclass <= "00100";
        wait for 20 ns;
        assert con_data_hazard_1 = '1' report "con_data_hazard_1 failed" severity error;
        assert con_data_hazard_2 = '1' report "con_data_hazard_2 failed" severity error;
        assert con_data_hazard_3 = '1' report "con_data_hazard_3 failed" severity error;

        vec_en_id <= '1'; vec_en_ex <= '1';
        rd_ex <= "00100";
        rs1_id <= "00100"; rs2_id <= "00100"; rs3_id <= "00100";
        wait for 20 ns;
        assert con_vd_hazard_1 = '1' and con_data_hazard_1 = '0' report "con_vd_hazard_1 failed" severity error;
        assert con_vd_hazard_2 = '1' and con_data_hazard_2 = '0' report "con_vd_hazard_2 failed" severity error;
        assert con_vd_hazard_3 = '1' and con_data_hazard_3 = '0' report "con_vd_hazard_3 failed" severity error;

        opclass <= "00001";
        vec_en_if <= '0'; vec_en_ex <= '0';
        rd_ex <= "00011";
        rs1_if <= "00011"; rs2_if <= "00011"; rs3_if <= "00011";
        wait until rising_edge(clk); wait for 1 ns;
        assert load_hazard_1 = '1' report "load_hazard_1 failed" severity error;
        assert load_hazard_2 = '1' report "load_hazard_2 failed" severity error;
        assert load_hazard_3 = '1' report "load_hazard_3 failed" severity error;

        vec_en_if <= '1'; vec_en_ex <= '1';
        rd_ex <= "00110";
        rs1_if <= "00110"; rs2_if <= "00110"; rs3_if <= "00110";
        vd_element <= "1010";
        wait until rising_edge(clk); wait for 1 ns;
        assert vec_load_hazard_1 = "1010" and load_hazard_1 = '0' report "vec_load_hazard_1 failed" severity error;
        assert vec_load_hazard_2 = "1010" and load_hazard_2 = '0' report "vec_load_hazard_2 failed" severity error;
        assert vec_load_hazard_3 = "1010" and load_hazard_3 = '0' report "vec_load_hazard_3 failed" severity error;

        wait;
    end process;

end Behavioral;
