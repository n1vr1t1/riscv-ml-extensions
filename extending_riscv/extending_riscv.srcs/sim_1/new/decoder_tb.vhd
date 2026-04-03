
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder_tb is
end decoder_tb;

architecture Behavioral of decoder_tb is

    component decoder is
        Port (rst : in std_logic;
              clk : in std_logic;
              flush : in std_logic;
              opcode : in std_logic_vector(6 downto 0);
              funct7 : in std_logic_vector(6 downto 0);
              funct3 : in std_logic_vector(2 downto 0);
              opclass : out STD_LOGIC_VECTOR (4 downto 0);
              operation_code : out STD_LOGIC_VECTOR (3 downto 0);
              a_select : out STD_LOGIC_VECTOR (1 downto 0);
              b_select : out STD_LOGIC_VECTOR (1 downto 0);
              c_select : out std_logic;
              conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
              fpu_en : out std_logic;
              vpu_en : out std_logic;
              vec_reg_en : out std_logic;
              vec_data_mem_en : out std_logic;
              mlu_en : out std_logic);
    end component;

    signal rst : std_logic := '1';
    signal clk : std_logic := '0';
    signal flush : std_logic := '0';
    signal instructions : std_logic_vector(31 downto 0) := (others => '0');
    alias opcode : std_logic_vector(6 downto 0) is instructions(6 downto 0);
    alias funct7 : std_logic_vector(6 downto 0) is instructions(31 downto 25);
    alias funct3 : std_logic_vector(2 downto 0) is instructions(14 downto 12);

    signal opclass : STD_LOGIC_VECTOR (4 downto 0);
    signal operation_code : STD_LOGIC_VECTOR (3 downto 0);
    signal a_select : STD_LOGIC_VECTOR (1 downto 0);
    signal b_select : STD_LOGIC_VECTOR (1 downto 0);
    signal c_select : std_logic;
    signal conditional_opcode : STD_LOGIC_VECTOR (2 downto 0);
    signal fpu_en : std_logic;
    signal vpu_en : std_logic;
    signal vec_reg_en : std_logic;
    signal vec_data_mem_en : std_logic;
    signal mlu_en : std_logic;

begin

    dut: decoder
        port map (
            rst => rst,
            clk => clk,
            flush => flush,
            opcode => instructions(6 downto 0),
            funct7 => instructions(31 downto 25),
            funct3 => instructions(14 downto 12),
            opclass => opclass,
            operation_code => operation_code,
            a_select => a_select,
            b_select => b_select,
            c_select => c_select,
            conditional_opcode => conditional_opcode,
            fpu_en => fpu_en,
            vpu_en => vpu_en,
            vec_reg_en => vec_reg_en,
            vec_data_mem_en => vec_data_mem_en,
            mlu_en => mlu_en
        );

    clk_process: process
    begin
        clk <= '0';
        wait for 5 ns;
        clk <= '1';
        wait for 5 ns;
    end process;

    stim_proc: process
        procedure check_decoder(
            constant test_name : in string;
            constant exp_opclass : in std_logic_vector(4 downto 0);
            constant exp_operation_code : in std_logic_vector(3 downto 0);
            constant exp_a_select : in std_logic_vector(1 downto 0);
            constant exp_b_select : in std_logic_vector(1 downto 0);
            constant exp_c_select : in std_logic;
            constant exp_conditional : in std_logic_vector(2 downto 0);
            constant exp_fpu_en : in std_logic;
            constant exp_vpu_en : in std_logic;
            constant exp_vec_reg_en : in std_logic;
            constant exp_vec_data_mem_en : in std_logic;
            constant exp_mlu_en : in std_logic
        ) is
        begin
            assert opclass = exp_opclass report test_name & " opclass mismatch" severity error;
            assert operation_code = exp_operation_code report test_name & " operation_code mismatch" severity error;
            assert a_select = exp_a_select report test_name & " a_select mismatch" severity error;
            assert b_select = exp_b_select report test_name & " b_select mismatch" severity error;
            assert c_select = exp_c_select report test_name & " c_select mismatch" severity error;
            assert conditional_opcode = exp_conditional report test_name & " conditional_opcode mismatch" severity error;
            assert fpu_en = exp_fpu_en report test_name & " fpu_en mismatch" severity error;
            assert vpu_en = exp_vpu_en report test_name & " vpu_en mismatch" severity error;
            assert vec_reg_en = exp_vec_reg_en report test_name & " vec_reg_en mismatch" severity error;
            assert vec_data_mem_en = exp_vec_data_mem_en report test_name & " vec_data_mem_en mismatch" severity error;
            assert mlu_en = exp_mlu_en report test_name & " mlu_en mismatch" severity error;
        end procedure;

        procedure check_vector_core(
            constant test_name : in string;
            constant exp_operation_code : in std_logic_vector(3 downto 0);
            constant exp_a_select : in std_logic_vector(1 downto 0);
            constant exp_fpu_en : in std_logic;
            constant exp_mlu_en : in std_logic
        ) is
        begin
            check_decoder(test_name, "00100", exp_operation_code, exp_a_select, "10", '1', "111", exp_fpu_en, '1', '1', '0', exp_mlu_en);
        end procedure;
    begin
        rst <= '0';
        wait for 1 ns;

        rst <= '1';
        flush <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;
        check_decoder("flush", "00000", "1111", "00", "00", '0', "111", '0', '0', '0', '0', '0');
        flush <= '0';

        instructions <= x"00600233"; -- add
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("add", "00100", "0000", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"40600233"; -- sub
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("sub", "00100", "0001", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00B07233"; -- and
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("and", "00100", "0111", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060E233"; -- or
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("or", "00100", "0110", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060C233"; -- xor
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("xor", "00100", "1000", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00609233"; -- sll
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("sll", "00100", "1101", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060D233"; -- srl
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("srl", "00100", "1110", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060A233"; -- slt
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("slt", "00100", "0011", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00608213"; -- addi
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("addi", "00100", "0000", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00A0F213"; -- andi
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("andi", "00100", "0111", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060E213"; -- ori
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("ori", "00100", "0110", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060C213"; -- xori
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("xori", "00100", "1000", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00609213"; -- slli
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("slli", "00100", "1101", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060D213"; -- srli
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("srli", "00100", "1110", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00A0A213"; -- slti
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("slti", "00100", "0011", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00001237"; -- lui
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("lui", "00100", "1100", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"02608233"; -- mul
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("mul", "00100", "0010", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0260C233"; -- div
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("div", "00100", "1001", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"04608233"; -- sle (int)
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("sle (int)", "00100", "0001", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"04609233"; -- seq (int)
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("seq (int)", "00100", "0001", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0460A233"; -- sge (int)
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("sge (int)", "00100", "0001", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0460B233"; -- sgt (int)
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("sgt (int)", "00100", "0001", "00", "00", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0460C233"; -- macc
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("macc (int)", "00100", "0001", "00", "00", '0', "111", '0', '0', '0', '0', '1');

        instructions <= x"0460D233"; -- lrelu
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("leaky relu (int)", "00100", "0010", "00", "00", '0', "111", '0', '0', '0', '0', '1');

        instructions <= x"0060A203"; -- lw
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("load", "00001", "0000", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060A207"; -- vload
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vector load", "00001", "0000", "00", "01", '0', "111", '0', '0', '1', '0', '0');

        instructions <= x"0040A023"; -- sw
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("store", "00010", "0000", "00", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"0060A227"; -- vstore
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vector store", "00010", "0000", "00", "01", '0', "111", '0', '0', '0', '1', '0');

        instructions <= x"FE1084E3"; -- beq
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("beq", "01000", "0000", "01", "01", '0', "000", '0', '0', '0', '0', '0');

        instructions <= x"00C21063"; -- bne
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("bne", "01000", "0000", "01", "01", '0', "001", '0', '0', '0', '0', '0');

        instructions <= x"00C24063"; -- blt
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("blt", "01000", "0000", "01", "01", '0', "100", '0', '0', '0', '0', '0');

        instructions <= x"00C25063"; -- bge
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("bge", "01000", "0000", "01", "01", '0', "101", '0', '0', '0', '0', '0');

        instructions <= x"00C26063"; -- bltu
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("bltu", "01000", "0000", "01", "01", '0', "110", '0', '0', '0', '0', '0');

        instructions <= x"00C27063"; -- bgeu
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("bgeu", "01000", "0000", "01", "01", '0', "111", '0', '0', '0', '0', '0');

        instructions <= x"00C000EF"; -- jal
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("jal", "10000", "0000", "01", "01", '0', "110", '0', '0', '0', '0', '0');

        instructions <= x"00008067"; -- jalr
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("jalr", "10000", "0000", "00", "01", '0', "110", '0', '0', '0', '0', '0');

        instructions <= x"00608253"; -- fadd
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fadd", "00100", "0000", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"0860F2D3"; -- fsub
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fsub", "00100", "0001", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"10007053"; -- fmul
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fmul", "00100", "0010", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"28B00253"; -- fmin
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fmin", "00100", "0011", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"28939253"; -- fmax
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fmax", "00100", "0100", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"A0B02253"; -- feq
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("feq", "00100", "0110", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"a0921453"; -- flt
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("flt", "00100", "0011", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"A0B00253"; -- fgt
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fgt", "00100", "0100", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"E0000253"; -- fmv.x.w (int -> float)
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fmv.x.w", "00100", "0111", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"F0000253"; -- fmv.w.x (float -> int)
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fmv.w.x", "00100", "1000", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"0460A253"; -- flrelu
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("float leaky relu", "00100", "0010", "00", "00", '0', "111", '1', '0', '0', '0', '1');

        instructions <= x"08608243"; -- fmadd
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("fmadd", "00100", "0001", "00", "00", '0', "111", '1', '0', '0', '0', '1');

        instructions <= x"D0008253"; -- fcvt.s.w
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("int -> float", "00100", "0111", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"C0008253"; -- fcvt.w.s
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("float -> int", "00100", "1000", "00", "00", '0', "111", '1', '0', '0', '0', '0');

        instructions <= x"00608257"; -- vadd.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vadd.vv", "00100", "0000", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"0060B257"; -- vadd.vi
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vadd.vi", "00100", "0000", "11", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"08608257"; -- vsub.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vsub.vv", "00100", "0001", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"24608257"; -- vand.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vand.vv", "00100", "0111", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"28608257"; -- vor.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vor.vv", "00100", "0110", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"2C608257"; -- vxor.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vxor.vv", "00100", "1000", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"8460A257"; -- vdiv.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vdiv.vv", "00100", "1001", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"94608257"; -- vsll.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vsll.vv", "00100", "1101", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"A060B257"; -- vsrl.vi
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vsrl.vi", "00100", "1110", "11", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"14608257"; -- vmin.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmin.vv", "00100", "0011", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"1C60C257"; -- vmax.vx
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmax.vx", "00100", "1010", "00", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"6C608257"; -- vmslt.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmslt.vv", "00100", "0011", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"7460B257"; -- vmsle.vi
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmsle.vi", "00100", "0100", "11", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"60608257"; -- vmseq.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmseq.vv", "00100", "0101", "10", "10", '1', "111", '0', '1', '1', '0', '0');

        instructions <= x"B460A257"; -- vmacc.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmacc.vv", "00100", "0001", "10", "10", '1', "111", '0', '1', '1', '0', '1');

        instructions <= x"00609257"; -- vfadd.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vfadd.vv", "00100", "0000", "10", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"0860D257"; -- vfsub.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vfsub.vf", "00100", "0001", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"9060D257"; -- vfmul.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vfmul.vf", "00100", "0010", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"10609257"; -- vfmin.vv
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vfmin.vv", "00100", "0011", "10", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"1860D257"; -- vfmax.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vfmax.vf", "00100", "0100", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"6060D257"; -- vmfeq.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmfeq.vf", "00100", "0110", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"1060D257"; -- vmflt.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmflt.vf", "00100", "0011", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"6460D257"; -- vmfle.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmfle.vf", "00100", "0101", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"1860D257"; -- vmfgt.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vmfgt.vf", "00100", "0100", "00", "10", '1', "111", '1', '1', '1', '0', '0');

        instructions <= x"B060D257"; -- vfmacc.vf
        wait until rising_edge(clk); wait for 1 ns;
        check_decoder("vfmacc.vf", "00100", "0000", "00", "10", '1', "111", '1', '1', '1', '0', '1');

        assert false report "All decoder tests completed" severity note;
        wait;
    end process;

end Behavioral;
