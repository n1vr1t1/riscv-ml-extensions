-- Notes:
-- 1. The datapath contains the main alu which is always active for every instruction. 
--    There are 3 other alus that are activated only for vector instructions, 
--    they perform the exact same operation as the main alu. 
-- 2. Control logic for load hazards are done here
-- 
-- Todo:
-- 1. check if variable is working for the inputs of comparator and propagation of the signal to main alu
-- 2. data and load hazards for vector instructions
--------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execution_stage is
    Port( clk : in std_logic;
        rst : in std_logic;
        flush : in std_logic;
        source_1 : in STD_LOGIC_VECTOR( 31 downto 0 );
        source_2 : in STD_LOGIC_VECTOR( 31 downto 0 ); -- used in data memory and for vector load-store operations
        source_3 : in STD_LOGIC_VECTOR( 31 downto 0 ); -- used only for mlu
        vec1_data : in std_logic_vector( 127 downto 0 );
        vec2_data : in std_logic_vector( 127 downto 0 );
        vec3_data : in std_logic_vector( 127 downto 0 );
        conditional_opcode : in STD_LOGIC_VECTOR( 2 downto 0 );
        alu_opcode : in STD_LOGIC_VECTOR( 3 downto 0 );
        a_select : in STD_LOGIC_VECTOR(1 downto 0);
        b_select : in STD_LOGIC_VECTOR(1 downto 0);
        immediate : in STD_LOGIC_VECTOR( 31 downto 0 );
        fp_en : in std_logic;
        is_ml : in std_logic;
        vpu_en : in std_logic;
        red_en : in std_logic;
        result1 : out STD_LOGIC_VECTOR( 31 downto 0 );
        result2 : out STD_LOGIC_VECTOR( 31 downto 0 );
        result3 : out STD_LOGIC_VECTOR( 31 downto 0 );
        result4 : out STD_LOGIC_VECTOR( 31 downto 0 );
        branch_condition : out STD_LOGIC;
        vec3_out : out std_logic_vector( 127 downto 0 );
        vreg_wen : in std_logic;
        vreg_wen_forward : out std_logic;
        vDM_wen : in std_logic;
        vDM_wen_forward : out std_logic;
        address_2 : in std_logic_vector(3 downto 0);
        address_2_out : out std_logic_vector(3 downto 0);
        pc_in : in STD_LOGIC_VECTOR( 31 downto 0 );
        pc_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        dest_ad_in : in STD_LOGIC_VECTOR( 4 downto 0 );
        dest_ad_out : out STD_LOGIC_VECTOR( 4 downto 0 );
        a_sel_out : out std_logic;
        b_sel_out : out std_logic;
        opclass_in : in STD_LOGIC_VECTOR( 4 downto 0 );
        opclass_out : out STD_LOGIC_VECTOR( 4 downto 0 );
        source2_out : out STD_LOGIC_VECTOR( 31 downto 0 )
    );
end execution_stage;

architecture Behavioral of execution_stage is
    component comparator is
        Port( 
            clk : in std_logic;
            rst : in std_logic;
            operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
            cond_opcode : in STD_LOGIC_VECTOR (2 downto 0);
            branch_condition : out STD_LOGIC 
        );
    end component;
    component alu is
        Port( 
            clk : in std_logic;
            rst : in std_logic;
            opcode : in STD_LOGIC_VECTOR( 3 downto 0 );
            operand_1 : in STD_LOGIC_VECTOR( 31 downto 0 );
            operand_2 : in STD_LOGIC_VECTOR( 31 downto 0 );
            operand_3 : in STD_LOGIC_VECTOR( 31 downto 0 );
            is_float : in STD_LOGIC;
            is_ml : in STD_LOGIC;
            en : in STD_LOGIC;
            alu_output : out STD_LOGIC_VECTOR( 31 downto 0 )
        );
    end component;
    component reduction_unit is
        Port (
            clk : in std_logic;
            rst : in std_logic;
            operand_1 : in std_logic_vector(31 downto 0);
            operand_2 : in std_logic_vector(31 downto 0);
            operand_3 : in std_logic_vector(31 downto 0);
            operand_4 : in std_logic_vector(31 downto 0);
            operand_5 : in std_logic_vector(31 downto 0);
            opcode : in std_logic_vector(2 downto 0);
            fp_en : in std_logic;
            en : in std_logic;
            result : out std_logic_vector(31 downto 0)
        );
    end component;
    signal red_signal : std_logic;
    signal alu1_op_a, alu1_op_b, alu1_op_c : std_logic_vector(31 downto 0);
    signal alu2_op_b, alu3_op_b, alu4_op_b : std_logic_vector(31 downto 0);
    signal alu_out_signal : std_logic_vector(31 downto 0);
    signal reduction_unit_out : std_logic_vector(31 downto 0); 
begin
    comp_exe : comparator
        Port map(
            rst => rst, 
            clk => clk,
            operand_1 => source_1,
            operand_2 => source_2,
            cond_opcode => conditional_opcode,
            branch_condition => branch_condition );
    alu_1 : alu
        Port map(
            rst => rst,
            clk => clk,
            opcode => alu_opcode,
            operand_1 => alu1_op_a,
            operand_2 => alu1_op_b,
            operand_3 => alu1_op_c,
            is_float => fp_en,
            is_ml => is_ml,
            en => '1',
            alu_output => alu_out_signal );
    alu_2 : alu
        Port map(
            rst => rst,
            clk => clk,
            opcode => alu_opcode,
            operand_1 =>  vec2_data( 63 downto 32 ),
            operand_2 => alu2_op_b,
            operand_3 => vec3_data( 63 downto 32 ),
            is_float => fp_en,
            is_ml => is_ml,
            en => vpu_en,
            alu_output => result2 );
    alu_3 : alu
        Port map(
            rst => rst,
            clk => clk,
            opcode => alu_opcode,
            operand_1 => vec2_data( 95 downto 64 ),
            operand_2 => alu3_op_b,
            operand_3 => vec3_data( 95 downto 64 ),
            is_float => fp_en,
            is_ml => is_ml,
            en => vpu_en,
            alu_output => result3 );
    alu_4 : alu
        Port map(
            rst => rst,
            clk => clk,
            opcode => alu_opcode,
            operand_1 => vec2_data( 127 downto 96 ),
            operand_2 => alu4_op_b,
            operand_3 => vec3_data( 127 downto 96 ),
            is_float => fp_en,
            is_ml => is_ml,
            en => vpu_en,
            alu_output => result4 );  
    ru_exe : reduction_unit
    -- right now I am assuming that each of vector register address is filled like: (v4,v3,v2,v1)
    -- need to change to (v1,v2,v3,v4) if the order of the load is reversed in the instructions
        Port map(
            rst => rst,
            clk => clk,
            operand_1 => vec1_data( 31 downto 0 ),
            operand_2 => vec2_data( 31 downto 0 ),
            operand_3 => vec2_data( 63 downto 32 ),
            operand_4 => vec2_data( 95 downto 64 ),
            operand_5 => vec2_data( 127 downto 96 ),
            opcode => alu_opcode(2 downto 0),
            fp_en => fp_en,
            en => red_en,
            result => reduction_unit_out );

process(red_signal, alu_out_signal, reduction_unit_out) begin
    if red_signal = '1' then 
        result1 <= reduction_unit_out;
    else
        result1 <= alu_out_signal;
    end if;
end process;

selecting_opa : process (a_select, pc_in, vec2_data, source_1) begin
    case a_select is 
        when "01" => alu1_op_a <= pc_in;
        when "10" => alu1_op_a <= vec2_data( 31 downto 0 );
        when others => alu1_op_a <= source_1;
    end case;
end process;

selecting_opb : process (b_select, immediate, vec1_data, source_1, source_2) begin
    case b_select is 
        when "01" => 
            alu1_op_b <= immediate;
            alu2_op_b <= immediate;
            alu3_op_b <= immediate;
            alu4_op_b <= immediate;
        when "10" => 
            alu1_op_b <= vec1_data( 31 downto 0 );
            alu2_op_b <= vec1_data( 63 downto 32 );
            alu3_op_b <= vec1_data( 95 downto 64 );
            alu4_op_b <= vec1_data( 127 downto 96 );
        when "11" =>
            alu1_op_b <= source_1;
            alu2_op_b <= source_1;
            alu3_op_b <= source_1;
            alu4_op_b <= source_1;

        when others => 
            alu1_op_b <= source_2;
            alu2_op_b <= (others => '0');
            alu3_op_b <= (others => '0');
            alu4_op_b <= (others => '0');
    end case;
end process;

selecting_opc : process (vpu_en, vec3_data, source_3) begin
    if vpu_en = '1' then
        alu1_op_c <= vec3_data( 31 downto 0 );
    else
        alu1_op_c <= source_3;
    end if;
end process;

forwarding_signals : process (rst, clk) begin
    if rst = '1' then
        red_signal <= '0';
        vreg_wen_forward <= '0';
        vec3_out <= (others => '0');
        pc_out <= (others => '0');
        dest_ad_out <= (others => '0');
        a_sel_out <= '0';
        b_sel_out <= '0';
        opclass_out <= (others => '0');
        source2_out <= (others => '0');
        address_2_out <= (others => '0');
        vDM_wen_forward <= '0';
    elsif rising_edge(clk) then
        red_signal <= red_en;
        vreg_wen_forward <= vreg_wen;
        vec3_out <= vec3_data;
        pc_out <= pc_in;
        dest_ad_out <= dest_ad;
        a_sel_out <= a_select;
        b_sel_out <= b_select;
        opclass_out <= opclass_in;
        source2_out <= source2;
        address_2_out <= address_2;
        vDM_wen_forward <= vDM_wen;
    end if;
end process;
end Behavioral;