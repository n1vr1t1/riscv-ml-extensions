-- Notes:
-- 1. The datapath contains the main alu which is always used for every instruction. 
--    There are 3 other alus that are activated and used only for vector instructions, 
--    they perform the exact same operations as the main alu. 
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
        c_select : in std_logic;
        immediate : in STD_LOGIC_VECTOR( 31 downto 0 );
        is_float : in std_logic;
        is_ml : in std_logic;
        is_vec : in std_logic;
        alu_1_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        alu_2_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        alu_3_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        alu_4_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        branch_condition : out STD_LOGIC;
        vec3_out : out std_logic_vector( 127 downto 0 );
        vec_we : in std_logic;
        vec_we_forward : out std_logic;
        -- address_2 : in std_logic_vector(3 downto 0); -- ?
        -- s_out : out std_logic_vector(3 downto 0);
        pc_in : in STD_LOGIC_VECTOR( 31 downto 0 );
        pc_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        dest_ad_in : in STD_LOGIC_VECTOR( 4 downto 0 );
        dest_ad_out : out STD_LOGIC_VECTOR( 4 downto 0 );
        a_sel_out : out std_logic;
        b_sel_out : out std_logic;
        opclass_in : in STD_LOGIC_VECTOR( 4 downto 0 );
        opclass_out : out STD_LOGIC_VECTOR( 4 downto 0 );
        source1_out : out STD_LOGIC_VECTOR( 31 downto 0 );
        -- source2_out : out STD_LOGIC_VECTOR( 15 downto 0 );
        load_a : in STD_LOGIC;
        load_b : in STD_LOGIC;
        load_c : in std_logic;
        memory_value : in STD_LOGIC_VECTOR( 31 downto 0 ));
end execution_stage;

architecture Behavioral of execution_stage is
    component comparator is
        Port( operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
        cond_opcode : in STD_LOGIC_VECTOR (2 downto 0);
        branch_condition : out STD_LOGIC );
    end component;
    component alu is
        Port( opcode : in STD_LOGIC_VECTOR( 3 downto 0 );
          operand_1 : in STD_LOGIC_VECTOR( 31 downto 0 );
          operand_2 : in STD_LOGIC_VECTOR( 31 downto 0 );
          operand_3 : in STD_LOGIC_VECTOR( 31 downto 0 );
          is_float : in STD_LOGIC;
          is_ml : in STD_LOGIC;
          en : in STD_LOGIC;
          alu_output : out STD_LOGIC_VECTOR( 31 downto 0 ));
    end component;

signal branch_condition_signal, is_float_signal, is_ml_signal, vec_signal : std_logic;
signal alu1_op_a, alu1_op_b, alu1_op_c : std_logic_vector( 31 downto 0 );
signal conditional_opcode_signal : STD_LOGIC_VECTOR( 2 downto 0 );
signal alu_opcode_signal : STD_LOGIC_VECTOR( 3 downto 0 );
signal comp_a, comp_b : std_logic_vector( 31 downto 0 );
signal alu2_op_a, alu3_op_a, alu4_op_a : std_logic_vector( 31 downto 0 );
-- signal alu2_op_b, alu3_op_b, alu4_op_b : std_logic_vector( 31 downto 0 );
-- signal alu2_op_c, alu3_op_c, alu4_op_c : std_logic_vector( 31 downto 0 );

begin
    comp_exe : comparator
        Port map(operand_1 => comp_a,
                operand_2 => comp_b,
                cond_opcode => conditional_opcode_signal,
                branch_condition => branch_condition );
    alu_1 : alu
        Port map(opcode => alu_opcode_signal,
                operand_1 => alu1_op_a,
                operand_2 => alu1_op_b,
                operand_3 => alu1_op_c,
                is_float => is_float_signal,
                is_ml => is_ml_signal,
                en => '1',
                alu_output => alu_1_out );
    alu_2 : alu
        Port map(opcode => alu_opcode_signal,
                operand_1 => alu2_op_a,
                operand_2 => vec2_data( 63 downto 32 ),
                operand_3 => vec3_data( 63 downto 32 ),
                is_float => is_float_signal,
                is_ml => is_ml_signal,
                en => vec_signal,
                alu_output => alu_2_out );
    alu_3 : alu
        Port map(opcode => alu_opcode_signal,
                operand_1 => alu3_op_a,
                operand_2 => vec2_data( 95 downto 64 ),
                operand_3 => vec3_data( 95 downto 64 ),
                is_float => is_float_signal,
                is_ml => is_ml_signal,
                en => vec_signal,
                alu_output => alu_3_out );
    alu_4 : alu
        Port map(opcode => alu_opcode_signal,
                operand_1 => alu4_op_a,
                operand_2 => vec2_data( 127 downto 96 ),
                operand_3 => vec3_data( 127 downto 96 ),
                is_float => is_float_signal,
                is_ml => is_ml_signal,
                en => vec_signal,
                alu_output => alu_4_out );  
                           
-- branch_condition <= branch_condition_signal;

process ( rst, clk ) 
variable post_load_a, post_load_b, post_load_c : std_logic_vector( 31 downto 0 );
begin
	if rst = '0' then
	    alu_opcode_signal <= ( others => '1' );
	    is_float_signal <= '0';
	    is_ml_signal <= '0';
        vec_signal <= '0';
	    conditional_opcode_signal <= ( others => '0' );
        pc_out <= ( others => '0' );
		source1_out <= ( others => '0' );
--		source2_out <= ( others => '0' );
		dest_ad_out <= ( others => '0' );
		opclass_out <= ( others => '0' );
		a_sel_out <= '0';
        b_sel_out <= '0';
        -- s_out <= (others => '0');
        vec3_out <= (others => '0');
		alu1_op_a <= ( others => '0' );
		alu1_op_b <= ( others => '0' );
		alu1_op_c <= ( others => '0' );
        alu2_op_a <= ( others => '0' );
        alu3_op_a <= ( others => '0' );
        alu4_op_a <= ( others => '0' );
        vec_we_forward <= '0';
        post_load_a := ( others => '0' );
        post_load_b := ( others => '0' );
        comp_a <= ( others => '0' );
        comp_b <= ( others => '0' );
    elsif rising_edge( clk ) then
        if flush = '1' then
            alu_opcode_signal <= ( others => '0' );
            is_float_signal <= '0';
            is_ml_signal <= '0';
            vec_signal <= '0';
            conditional_opcode_signal <= ( others => '0' );
            pc_out <= ( others => '0' );
            source1_out <= ( others => '0' );
--            source2_out <= ( others => '0' );
            dest_ad_out <= ( others => '0' );
            opclass_out <= ( others => '0' );
            a_sel_out <= '0';
            b_sel_out <= '0';
            -- s_out <= (others => '0');
            vec3_out <= (others => '0');
            alu1_op_a <= ( others => '0' );
            alu1_op_b <= ( others => '0' );
            alu1_op_c <= ( others => '0' );
            alu2_op_a <= ( others => '0' );
            alu3_op_a <= ( others => '0' );
            alu4_op_a <= ( others => '0' );
            vec_we_forward <= '0';
            post_load_a := ( others => '0' );
            post_load_b := ( others => '0' );
            comp_a <= ( others => '0' );
            comp_b <= ( others => '0' );
	    else
            a_sel_out <= a_select( 0 );
            b_sel_out <= b_select( 0 );
            alu_opcode_signal <= alu_opcode;
            is_float_signal <= is_float;
	        is_ml_signal <= is_ml;
            vec_signal <= is_vec;
            vec_we_forward <= vec_we;
            conditional_opcode_signal <= conditional_opcode;
            pc_out <= pc_in;
            source1_out <= source_1;
--            source2_out <= source_2( 15 downto 0 );
            dest_ad_out <= dest_ad_in;
            opclass_out <= opclass_in;
            vec3_out <= vec3_data;
            if load_a = '1' then  --  load hazard for 32 bit data
                post_load_a := memory_value;
            else
                post_load_a := source_1;
            end if;
            if load_b = '1' then --load hazard for 32 bit data
                post_load_b := memory_value;
            else 
                post_load_b := source_2;
            end if;
            comp_a <= post_load_a;
            comp_b <= post_load_b;
            case a_select is
                -- when "00" => -- value from register
                    -- alu1_op_a <= post_load_a;
                    -- alu2_op_a <= post_load_a;
                    -- alu3_op_a <= post_load_a;
                    -- alu4_op_a <= post_load_a;
                when "01" => -- program counter
                    alu1_op_a <= pc_in;
                    alu1_op_a <= ( others => '0' );
                    alu2_op_a <= ( others => '0' );
                    alu3_op_a <= ( others => '0' );
                    alu4_op_a <= ( others => '0' );
                when "10" => -- value from vector register
                    alu1_op_a <= vec1_data( 31 downto 0 ); 
                    alu2_op_a <= vec1_data( 63 downto 32 );
                    alu3_op_a <= vec1_data( 95 downto 64 );
                    alu4_op_a <= vec1_data( 127 downto 96 );
                when "11" => -- value taken from immediate
                    alu1_op_a <= immediate;
                    alu2_op_a <= immediate;
                    alu3_op_a <= immediate;
                    alu4_op_a <= immediate;
                when others => -- by default, the register value is taken
                    alu1_op_a <= post_load_a;
                    alu2_op_a <= post_load_a;
                    alu3_op_a <= post_load_a;
                    alu4_op_a <= post_load_a;
            end case;
            case b_select is -- selecting operand 2 based on b_select 
                -- when "00" => alu1_op_b <= source_2;
                when "01" => -- immediate (only for the main alu)
                    alu1_op_b <= immediate;
                when "10" => -- value from vector register
                    alu1_op_b <= vec2_data( 31 downto 0 ); 
                when others => 
                    alu1_op_b <= post_load_b; -- value from register
            end case;
            if c_select = '1' then -- choosing the third operand of the alu
                alu1_op_c <= vec3_data( 31 downto 0 ); -- vector macc instructions
            elsif load_c = '1' then
                alu1_op_c <= memory_value; -- load hazard
            else
                alu1_op_c <= source_3;
            end if;
        end if;
	end if;
end process;
end Behavioral;