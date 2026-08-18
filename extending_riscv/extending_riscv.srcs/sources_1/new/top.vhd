library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
    Port (clk : in STD_LOGIC;
        rst : in std_logic;
        led : out std_logic
);
end top;

architecture Behavioral of top is
component instruction_fetch_stage is
    Port( clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          branch_condition : in std_logic; -- active high
          branch_pc : in STD_LOGIC_VECTOR( 11 downto 0 );
          pc_out : out STD_LOGIC_VECTOR( 31 downto 0 );
          instruction : out STD_LOGIC_VECTOR( 31 downto 0 ));
end component;
component instruction_decode is
    Port (clk : in STD_LOGIC;
      	rst : in STD_LOGIC;
--        stall : in std_logic;
      	flush : in STD_LOGIC; -- active high, used for flushing 
		pc : in STD_LOGIC_VECTOR( 31 downto 0 ); -- forwarded to the next stage without being used
		instruction : in STD_LOGIC_VECTOR( 31 downto 0 );
		rd_val_wb : in STD_LOGIC_VECTOR( 31 downto 0 ); -- writing value into register file
		wen_wb : in STD_LOGIC; -- write enable for register file
		dest_addr_wb : in STD_LOGIC_VECTOR( 4 DOWNTO 0 ); -- address in the normal and vector file 
		vec_wen_wb : in std_logic; -- enable to indicate whether the vector file should be written into
		vd_val_wb : in std_logic_vector( 127 downto 0 ); -- value to be written into vector register
		vd_element : in std_logic_vector( 3 downto 0 ); -- element of the register to which the value should be written
		pc_forward : out STD_LOGIC_VECTOR( 31 downto 0 ); -- value used for the execution stage
		immediate : out STD_LOGIC_VECTOR( 31 downto 0 ); -- immediate value found by the immedate generator
		opclass : out STD_LOGIC_VECTOR( 4 downto 0 );
		opcode : out STD_LOGIC_VECTOR( 3 downto 0 ); 
		a_select : out STD_LOGIC_VECTOR(1 downto 0);
        b_select : out STD_LOGIC_VECTOR(1 downto 0);
		conditional_opcode : out STD_LOGIC_VECTOR( 2 downto 0 ); 
        uncond_branch : out STD_LOGIC;
		r1_address : out std_logic_vector( 4 downto 0 );
		r2_address : out std_logic_vector( 4 downto 0 );
		r3_address : out STD_LOGIC_vector( 4 downto 0 ); -- destination and source 3 address 
		source_1 : out STD_LOGIC_VECTOR( 31 downto 0 ); -- value of the first source address
		source_2 : out STD_LOGIC_VECTOR( 31 downto 0 ); -- value of the second source address
		source_3 : out STD_LOGIC_VECTOR( 31 downto 0 ); -- value of the third/destination address
		float_en : out std_logic;
		ml_en : out std_logic;
		vu_en : out std_logic; -- vector unit enable
        ru_en : out std_logic; -- reduction unit enable
		vec_reg_en : out std_logic;
		vecDM_en : out std_logic;
		vec1_data : out std_logic_vector( 127 downto 0 );
		vec2_data : out std_logic_vector( 127 downto 0 );
        vec3_data : out std_logic_vector( 127 downto 0 ));
end component;
component execution_stage is
    Port( clk : in std_logic;
        rst : in std_logic;
        flush : in std_logic;
        source_1 : in STD_LOGIC_VECTOR( 31 downto 0 );
        source_2 : in STD_LOGIC_VECTOR( 31 downto 0 ); -- used in data memory and for vector load-store operations
        source_3 : in STD_LOGIC_VECTOR( 31 downto 0 ); -- used only for mlu
        vec1_data : in std_logic_vector( 127 downto 0 );
        vec2_data : in std_logic_vector( 127 downto 0 );
        vec3_data : in std_logic_vector( 127 downto 0 );
        uncond_branch : in STD_LOGIC; 
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
end component;
COMPONENT data_mem
 PORT (clka : IN STD_LOGIC;
     wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
     addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
     dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
     douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;
component read_write_back_stage is
   Port (pc : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_1 : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_2 : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_3 : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_4 : in STD_LOGIC_VECTOR (31 downto 0);
        opclass : in STD_LOGIC_VECTOR (4 downto 0);
        mem_out : in STD_LOGIC_VECTOR (31 downto 0);
        rd_in: in STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_out: out STD_LOGIC_VECTOR(4 DOWNTO 0);
        vec_wen_in : in std_logic;
        vec_wen_out : out std_logic;
        vdata : out std_logic_vector ( 127 downto 0 );
        vc_elem_i : in std_logic_vector ( 3 downto 0 );
        vc_elem_o : out std_logic_vector ( 3 downto 0 );  
        write_register_file : out std_logic;
        rd_value : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component control_unit is
   Port (rst : in std_logic;
        clk : in std_logic;  
        opclass : in std_logic_vector(4 downto 0);
        vec_en_if : in std_logic;
        vec_en_id : in std_logic;
        vec_en_ex : in std_logic;
    	-- signals for data hazards with consecutive operations
    	rs1_id : in std_logic_vector(4 downto 0);
    	rs2_id : in std_logic_vector(4 downto 0);
    	rs3_id : in std_logic_vector(4 downto 0);
    	rd_ex : in std_logic_vector(4 downto 0); --got from the output of the execution stage
    	con_data_hazard_1 : out std_logic;
    	con_data_hazard_2 : out std_logic;
    	con_data_hazard_3 : out std_logic;
        con_vd_hazard_1 : out std_logic;
        con_vd_hazard_2 : out std_logic;
        con_vd_hazard_3 : out std_logic;
		--signals for all types of data hazards
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
    	--signals for flushing
    	a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        branch_condition : in STD_LOGIC;
        flush : out STD_LOGIC);
end component;

-------signals to connect each stage-----

--signals in between instruction fetch and instruction decode
signal pc_if_id : STD_LOGIC_VECTOR (31 downto 0);
signal instruction_if_id : STD_LOGIC_VECTOR (31 downto 0);

--signals between instruction decode and execution
signal pc_id_ex :  STD_LOGIC_VECTOR (31 downto 0);
signal immediate_id_ex : STD_LOGIC_VECTOR (31 downto 0);
signal opclass_id_ex : STD_LOGIC_VECTOR (4 downto 0);
signal opcode_id_ex : STD_LOGIC_VECTOR (3 downto 0);
signal a_select_id_ex : STD_LOGIC_VECTOR(1 downto 0);
signal b_select_id_ex : STD_LOGIC_VECTOR(1 downto 0);
signal conditional_opcode_id_ex : STD_LOGIC_VECTOR (2 downto 0);
signal s_value_1_id : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_2_id : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3_id : STD_LOGIC_VECTOR (31 downto 0); -- also the destination address
signal source_1_id : STD_LOGIC_VECTOR (4 downto 0);
signal source_2_id : STD_LOGIC_VECTOR (4 downto 0);
signal source_3_id : STD_LOGIC_VECTOR (4 downto 0);
signal is_float_id_ex : std_logic;
signal is_ml_id_ex : std_logic;
signal ru_en_id_ex : std_logic;
signal vu_id_ex : std_logic;
signal uncond_branch_id_ex : std_logic;
signal vec_reg_en_id_ex : std_logic;
signal vecDM_en_id_ex : std_logic;
signal vec1_data_id : std_logic_vector( 127 downto 0 );
signal vec2_data_id : std_logic_vector( 127 downto 0 );
signal vec3_data_id : std_logic_vector( 127 downto 0 );

--signals from execute 
signal alu1_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal alu2_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal alu3_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal alu4_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal destination_address_out_ex :  STD_LOGIC_VECTOR (4 downto 0);
signal pc_ex : STD_LOGIC_VECTOR (31 downto 0);
signal opclass_out_ex : STD_LOGIC_VECTOR (4 downto 0);
signal s_value_1_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_2_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3_ex : STD_LOGIC_VECTOR (31 downto 0);
signal vec_we_ex : std_logic;
signal source_2_ex : std_logic_vector (31 downto 0);
signal vec3_ex : STD_LOGIC_VECTOR (127 downto 0);
signal address_2_ex : std_logic_vector (3 downto 0);
signal vec1_data_ex : std_logic_vector( 127 downto 0 );
signal vec2_data_ex : std_logic_vector( 127 downto 0 );
signal vec3_data_ex : std_logic_vector( 127 downto 0 );
signal vecDM_en_ex : std_logic;

----signals connected to data memory
signal write_enable_dm : std_logic;
signal mem_in_dm : STD_LOGIC_VECTOR (31 downto 0);

----signals connected to read and write back stage
signal mem_out_dm_wb : STD_LOGIC_VECTOR (31 downto 0);
signal rd_in_wb : STD_LOGIC_VECTOR (4 downto 0);
signal pc_wb : STD_LOGIC_VECTOR (31 downto 0);
signal opclass_wb : STD_LOGIC_VECTOR (4 downto 0);
signal alu1_output_wb : STD_LOGIC_VECTOR (31 downto 0);
signal alu2_output_wb : STD_LOGIC_VECTOR (31 downto 0);
signal alu3_output_wb : STD_LOGIC_VECTOR (31 downto 0);
signal alu4_output_wb : STD_LOGIC_VECTOR (31 downto 0);
signal vec_dest_element_wb : std_logic_vector( 3 downto 0 );
signal vec_we_wb : std_logic;

--signals in between write back and instruction decode
signal destination_value_wb_id : STD_LOGIC_VECTOR (31 downto 0);
signal destination_address_wb_id : STD_LOGIC_VECTOR(4 DOWNTO 0); 
signal write_enable_wb_id : std_logic;
signal vec_we_wb_id : std_logic;
signal vd_value_wb_id : std_logic_vector( 127 downto 0 );
signal vec_dest_element_wb_id : std_logic_vector( 3 downto 0 );

----signals connected to control unit
signal flush_control : std_logic;
signal load_hazard_1_control : std_logic;
signal load_hazard_2_control : std_logic;
signal load_hazard_3_control : std_logic;
signal consecutive_data_hazard_1_control : std_logic;
signal consecutive_data_hazard_2_control : std_logic;
signal consecutive_data_hazard_3_control : std_logic;
signal non_consecutive_data_hazard_1_control : std_logic;
signal non_consecutive_data_hazard_2_control : std_logic;
signal non_consecutive_data_hazard_3_control : std_logic;
signal vec_en_control : std_logic;
signal con_vd_hazard_1_control : std_logic;
signal con_vd_hazard_2_control : std_logic;
signal con_vd_hazard_3_control : std_logic;
signal vec_data_hazard_1_control : std_logic;
signal vec_data_hazard_2_control : std_logic;
signal vec_data_hazard_3_control : std_logic;
signal vec_load_hazard_1_control : std_logic_vector(3 downto 0);
signal vec_load_hazard_2_control : std_logic_vector(3 downto 0);
signal vec_load_hazard_3_control : std_logic_vector(3 downto 0);
----signals in between execution and control unit
signal a_select_ex_control: std_logic;
signal b_select_ex_control: std_logic;
signal branch_condition_ex_control : std_logic;

begin
if_stage: instruction_fetch_stage
    Port map (clk => clk,
        rst => rst,
        branch_condition => flush_control,
        branch_pc => alu1_output_ex(11 downto 0),
        pc_out => pc_if_id,
       	instruction => instruction_if_id);
        
id_stage: instruction_decode
    Port map (clk => clk,
        rst => rst,
        pc => pc_if_id,
       	instruction => instruction_if_id,
       	rd_val_wb => destination_value_wb_id, 
       	dest_addr_wb => destination_address_wb_id, 
	    wen_wb => write_enable_wb_id,
	    vec_wen_wb => vec_we_wb_id,
        vd_val_wb => vd_value_wb_id,
        vd_element => vec_dest_element_wb_id,
	    pc_forward => pc_id_ex,
       	immediate => immediate_id_ex,
	    opclass => opclass_id_ex,
       	opcode => opcode_id_ex,
	    a_select => a_select_id_ex,
       	b_select => b_select_id_ex,
	    conditional_opcode => conditional_opcode_id_ex,
        uncond_branch => uncond_branch_id_ex,
       	source_1 => s_value_1_id,
		source_2 => s_value_2_id,
		source_3 => s_value_3_id,
		r1_address => source_1_id,
		r2_address => source_2_id,
		r3_address => source_3_id, 
		flush => flush_control,
        float_en => is_float_id_ex,
        ml_en => is_ml_id_ex,
        vu_en => vu_id_ex,
        ru_en => ru_en_id_ex,
        vec_reg_en => vec_reg_en_id_ex,
        vecDM_en => vecDM_en_id_ex,
        vec1_data => vec1_data_id,
        vec2_data => vec2_data_id,
        vec3_data => vec3_data_id);

exe_stage : execution_stage
   Port map (clk => clk,
        rst => rst,
        flush => flush_control,
        source_1 => s_value_1_ex,
        source_2 => s_value_2_ex,
        source_3 => s_value_3_ex,
        vec1_data => vec1_data_ex,
        vec2_data => vec2_data_ex,
        vec3_data => vec3_data_ex,
        vreg_wen => vec_reg_en_id_ex,
        vreg_wen_forward => vec_we_ex,
        vDM_wen => vecDM_en_id_ex,
        vDM_wen_forward => vecDM_en_ex,
        conditional_opcode => conditional_opcode_id_ex,
        uncond_branch => uncond_branch_id_ex,
        pc_in => pc_id_ex,
        a_select => a_select_id_ex,
        b_select => b_select_id_ex,
        immediate => immediate_id_ex,
        alu_opcode => opcode_id_ex,
        opclass_in => opclass_id_ex, 
        opclass_out => opclass_out_ex,
        a_sel_out => a_select_ex_control ,
        b_sel_out => b_select_ex_control,
        dest_ad_in => source_3_id,
        dest_ad_out => destination_address_out_ex,
        branch_condition => branch_condition_ex_control,
        pc_out => pc_ex,
        result1 => alu1_output_ex,
        result2 => alu2_output_ex,
        result3 => alu3_output_ex,
        result4 => alu4_output_ex,
        fp_en => is_float_id_ex,
        is_ml => is_ml_id_ex,
        vpu_en => vu_id_ex,
        red_en => ru_en_id_ex,
        vec3_out => vec3_ex,
        address_2 => source_2_id(3 downto 0),
        address_2_out => address_2_ex,
        source2_out => source_2_ex
	   );

stage_dm : data_mem
  	PORT MAP (clka => clk ,
   	wea(0) => write_enable_dm,
   	addra => alu1_output_ex(11 DOWNTO 2),
   	dina => mem_in_dm,
   	douta => mem_out_dm_wb);
    	
wb_stage : read_write_back_stage
   Port map (pc => pc_wb,
        alu_forward_1 => alu1_output_wb,
        alu_forward_2 => alu2_output_wb,
        alu_forward_3 => alu3_output_wb,
        alu_forward_4 => alu4_output_wb,
        vec_wen_in => vec_we_wb,
        vec_wen_out => vec_we_wb_id,
        vdata => vd_value_wb_id,
        vc_elem_i => vec_dest_element_wb,
        vc_elem_o => vec_dest_element_wb_id,
        opclass => opclass_wb,
        mem_out => mem_out_dm_wb,
        rd_in => rd_in_wb,
        rd_out => destination_address_wb_id,
        write_register_file => write_enable_wb_id,
        rd_value => destination_value_wb_id);  

cu : control_unit
   Port map (rst => rst,
        clk => clk,
        opclass => opclass_out_ex,
        vec_en_if => vec_en_control,
        vec_en_id => vec_reg_en_id_ex,
        vec_en_ex => vec_we_ex,
        rs1_id => source_1_id,
        rs2_id => source_2_id,
        rs3_id => source_3_id,
        rd_ex => destination_address_out_ex,
        con_data_hazard_1 => consecutive_data_hazard_1_control,
        con_data_hazard_2 => consecutive_data_hazard_2_control,
        con_data_hazard_3 => consecutive_data_hazard_3_control,
        con_vd_hazard_1 => con_vd_hazard_1_control,
        con_vd_hazard_2 => con_vd_hazard_2_control,
        con_vd_hazard_3 => con_vd_hazard_3_control,
		rs1_if => instruction_if_id(19 downto 15),
        rs2_if => instruction_if_id(24 downto 20),
        rs3_if => instruction_if_id(11 downto 7),
        data_hazard_1 => non_consecutive_data_hazard_1_control,
        data_hazard_2 => non_consecutive_data_hazard_2_control,
        data_hazard_3 => non_consecutive_data_hazard_3_control,
        vec_data_hazard_1 => vec_data_hazard_1_control,
        vec_data_hazard_2 => vec_data_hazard_2_control,
        vec_data_hazard_3 => vec_data_hazard_3_control,
		load_hazard_1 => load_hazard_1_control,
		load_hazard_2 => load_hazard_2_control,
		load_hazard_3 => load_hazard_3_control,
        vec_load_hazard_1 => vec_load_hazard_1_control,
        vec_load_hazard_2 => vec_load_hazard_2_control,
        vec_load_hazard_3 => vec_load_hazard_3_control,
		a_select => a_select_ex_control,
        b_select => b_select_ex_control,
        branch_condition => branch_condition_ex_control,
        flush => flush_control,
        vd_element => address_2_ex(3 downto 0));
		 
registered_write_back : process (rst, clk) begin
   if rst = '0' then 
        pc_wb <= (others => '0'); 
        alu1_output_wb <= (others => '0');
        alu2_output_wb <= (others => '0');
        alu3_output_wb <= (others => '0');
        alu4_output_wb <= (others => '0');
        vec_we_wb <= '0';
        vec_dest_element_wb <= (others => '0');
        opclass_wb <= (others => '0');
        rd_in_wb <= (others => '0');
   elsif rising_edge(clk) then 
        pc_wb <= pc_ex; 
        alu1_output_wb <= alu1_output_ex;
        alu2_output_wb <= alu2_output_ex;
        alu3_output_wb <= alu3_output_ex;
        alu4_output_wb <= alu4_output_ex;
        vec_we_wb <= vec_we_ex;
        vec_dest_element_wb <= address_2_ex;
        opclass_wb <= opclass_out_ex;
        rd_in_wb <= destination_address_out_ex;
   end if;
end process;
dm_write : process (opclass_out_ex) begin
   if opclass_out_ex = "00010" then --store
       write_enable_dm <= '1';
   else write_enable_dm <= '0';
   end if;
end process;

process (instruction_if_id) begin 
    -- vector operation or load or store instruction
    if instruction_if_id(6 downto 0) = "1010111" or instruction_if_id(6 downto 0) = "0000111"  or instruction_if_id(6 downto 0) = "0100111" then
            vec_en_control <= '1';
    else vec_en_control <= '0';
    end if;
end process;

writing_data_mem_process : process (vecDM_en_ex, address_2_ex, vec3_ex, source_2_ex) begin
   if vecDM_en_ex = '1' then  -- value taken from the vector register
       if address_2_ex(3) = '1' then -- storing value from 4th element
           mem_in_dm <= vec3_ex( 127 downto 96 );
       elsif address_2_ex(2) = '1' then -- storing value from 3rd element
           mem_in_dm <= vec3_ex( 95 downto 64 );
       elsif address_2_ex(1) = '1' then -- storing value from 2nd element
           mem_in_dm <= vec3_ex( 63 downto 32 );
       else -- address_2_ex(0) = '1' then -- storing value from 1st element
           mem_in_dm <= vec3_ex( 31 downto 0 );
       end if;
   else -- value taken from the register file for intger/float stores
       mem_in_dm <= source_2_ex;
   end if;
end process;

data_hazards_1 : process ( s_value_1_id, consecutive_data_hazard_1_control, alu1_output_ex,
                          non_consecutive_data_hazard_1_control, destination_value_wb_id, 
                          load_hazard_1_control, mem_out_dm_wb ) begin
	if consecutive_data_hazard_1_control ='1' then 
		s_value_1_ex <= alu1_output_ex;
    elsif load_hazard_1_control = '1' then
        s_value_1_ex <= mem_out_dm_wb;
   elsif non_consecutive_data_hazard_1_control = '1' then 
       s_value_1_ex <= destination_value_wb_id;
	else 
	 	s_value_1_ex <= s_value_1_id;
	 end if;
end process;
data_hazards_2 : process ( s_value_2_id, load_hazard_2_control, consecutive_data_hazard_2_control , alu1_output_ex ,
                          non_consecutive_data_hazard_2_control, destination_value_wb_id, mem_out_dm_wb ) begin
	if consecutive_data_hazard_2_control = '1' then 
		s_value_2_ex <= alu1_output_ex;
    elsif load_hazard_2_control = '1' then
        s_value_2_ex <= mem_out_dm_wb;
    elsif non_consecutive_data_hazard_2_control = '1' then 
       s_value_2_ex <= destination_value_wb_id;
	else 
	 	s_value_2_ex <= s_value_2_id;
	 end if;
end process;
data_hazards_3 : process ( s_value_3_id, consecutive_data_hazard_3_control , alu1_output_ex , load_hazard_3_control, mem_out_dm_wb, 
                          non_consecutive_data_hazard_3_control, destination_value_wb_id ) begin
    if consecutive_data_hazard_3_control = '1' then 
		s_value_3_ex <= alu1_output_ex;
    elsif load_hazard_3_control = '1' then
        s_value_3_ex <= mem_out_dm_wb;
    elsif non_consecutive_data_hazard_3_control = '1' then 
       s_value_3_ex <= destination_value_wb_id;
	else 
	 	s_value_3_ex <= s_value_3_id;
	 end if;
end process;

vector_hazards_1 : process ( vec1_data_id, vec_data_hazard_1_control, vd_value_wb_id, 
            vec_load_hazard_1_control, mem_out_dm_wb, con_vd_hazard_1_control, alu1_output_ex, 
            alu2_output_ex, alu3_output_ex, alu4_output_ex ) begin
    
    vec1_data_ex <= vec1_data_id;
    if vec_data_hazard_1_control = '1' then 
       vec1_data_ex <= vd_value_wb_id;
    end if;
    if vec_load_hazard_1_control(0) = '1' then
        vec1_data_ex(31 downto 0) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_1_control(1) = '1' then
        vec1_data_ex(63 downto 32) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_1_control(2) = '1' then
        vec1_data_ex(95 downto 64) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_1_control(3) = '1' then
        vec1_data_ex(127 downto 96) <= mem_out_dm_wb;
    end if;
	if con_vd_hazard_1_control ='1' then 
		vec1_data_ex(31 downto 0) <= alu1_output_ex;
        vec1_data_ex(63 downto 32) <= alu2_output_ex;
        vec1_data_ex(95 downto 64) <= alu3_output_ex;
        vec1_data_ex(127 downto 96) <= alu4_output_ex;
	end if;
end process;
vector_hazards_2 : process ( vec2_data_id, vec_data_hazard_2_control, vd_value_wb_id, 
        vec_load_hazard_2_control, mem_out_dm_wb, con_vd_hazard_2_control, alu1_output_ex, alu2_output_ex, 
        alu3_output_ex, alu4_output_ex ) begin
	vec2_data_ex <= vec2_data_id;
    if vec_data_hazard_2_control = '1' then 
       vec2_data_ex <= vd_value_wb_id;
    end if;
    if vec_load_hazard_2_control(0) = '1' then
        vec2_data_ex(31 downto 0) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_2_control(1) = '1' then
        vec2_data_ex(63 downto 32) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_2_control(2) = '1' then
        vec2_data_ex(95 downto 64) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_2_control(3) = '1' then
        vec2_data_ex(127 downto 96) <= mem_out_dm_wb;
    end if;
	if con_vd_hazard_2_control ='1' then 
		vec2_data_ex(31 downto 0) <= alu1_output_ex;
        vec2_data_ex(63 downto 32) <= alu2_output_ex;
        vec2_data_ex(95 downto 64) <= alu3_output_ex;
        vec2_data_ex(127 downto 96) <= alu4_output_ex;
	end if;
end process;
vector_hazards_3 : process ( vec3_data_id, vec_data_hazard_3_control, vd_value_wb_id, 
        vec_load_hazard_3_control, mem_out_dm_wb, con_vd_hazard_3_control, alu1_output_ex, alu2_output_ex, 
        alu3_output_ex, alu4_output_ex ) begin
    vec3_data_ex <= vec3_data_id;
    if vec_data_hazard_3_control = '1' then 
       vec3_data_ex <= vd_value_wb_id;
    end if;
    if vec_load_hazard_3_control(0) = '1' then
        vec3_data_ex(31 downto 0) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_3_control(1) = '1' then
        vec3_data_ex(63 downto 32) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_3_control(2) = '1' then
        vec3_data_ex(95 downto 64) <= mem_out_dm_wb;
    end if;
    if vec_load_hazard_3_control(3) = '1' then
        vec3_data_ex(127 downto 96) <= mem_out_dm_wb;
    end if;
	if con_vd_hazard_3_control ='1' then 
		vec3_data_ex(31 downto 0) <= alu1_output_ex;
        vec3_data_ex(63 downto 32) <= alu2_output_ex;
        vec3_data_ex(95 downto 64) <= alu3_output_ex;
        vec3_data_ex(127 downto 96) <= alu4_output_ex;
	end if;
end process;

end Behavioral;