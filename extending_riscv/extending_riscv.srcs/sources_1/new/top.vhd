library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top is
  Port (clk : in STD_LOGIC;
        rst: in STD_LOGIC; --active low
        switches: in std_logic_vector(15 downto 0); -- 16 swicthes
		CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
		AN : out std_logic_vector(3 downto 0));
end top;

architecture Behavioral of top is
component instruction_fetch_stage is
    Port (clk : in STD_LOGIC;
        rst: in STD_LOGIC;
        branch_condition: in std_logic; --active high
        branch_pc: in STD_LOGIC_VECTOR(11 downto 0);
        pc_out : out STD_LOGIC_VECTOR (31 downto 0);
        instruction : out STD_LOGIC_VECTOR (31 downto 0));
end component;
component instruction_decode is
    Port (pc_in : in STD_LOGIC_VECTOR (31 downto 0); --forwarded to the next stage without being used
      instruction : in STD_LOGIC_VECTOR (31 downto 0);
      destination_value_from_wb : in STD_LOGIC_VECTOR (31 downto 0);
      destination_address_from_wb : in STD_LOGIC_VECTOR(4 DOWNTO 0);
      write_enable_from_wb : in STD_LOGIC; 
      clk : in STD_LOGIC;
      rst : in STD_LOGIC;
      flush : in STD_LOGIC; --active high, used fo flushing 
      pc_out : out STD_LOGIC_VECTOR (31 downto 0);
      immediate : out STD_LOGIC_VECTOR (31 downto 0);
      op_class : out STD_LOGIC_VECTOR (4 downto 0);
      alu_opcode : out STD_LOGIC_VECTOR (3 downto 0); 
      a_select : out STD_LOGIC; 
      b_select : out STD_LOGIC;
      conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0); 
      r1 : out STD_LOGIC_vector(4 downto 0);
      r2 : out STD_LOGIC_vector(4 downto 0);
      s_value_1 : out STD_LOGIC_VECTOR (31 downto 0); 
      s_value_2 : out STD_LOGIC_VECTOR (31 downto 0);
      s_value_3 : out STD_LOGIC_VECTOR (31 downto 0);
      destination_address : out STD_LOGIC_VECTOR(4 DOWNTO 0);
      is_float : out STD_LOGIC;
      is_ml : out STD_LOGIC;
      ml_opcode : out STD_LOGIC);
end component;
component execution_stage is
    Port(clk :  in STD_LOGIC;
        rst :  in STD_LOGIC;
        flush :  in STD_LOGIC;
        value_1 : in STD_LOGIC_VECTOR (31 downto 0);
        value_2 : in STD_LOGIC_VECTOR (31 downto 0); -- used in data memory
        value_3 : in STD_LOGIC_VECTOR (31 downto 0); -- used only for mlu -> mac instructions
        conditional_opcode : in STD_LOGIC_VECTOR (2 downto 0);
        alu_opcode : in STD_LOGIC_VECTOR (3 downto 0);
        ml_opcode : in STD_LOGIC;
        a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        immediate : in STD_LOGIC_VECTOR (31 downto 0);
        is_float : in STD_LOGIC;
        is_ml : in STD_LOGIC;
        fpu_output : out STD_LOGIC_VECTOR (31 downto 0);
        alu_output : out STD_LOGIC_VECTOR (31 downto 0);
        mlu_output : out STD_LOGIC_VECTOR (31 downto 0);
        branch_condition : out STD_LOGIC;
        pc : in STD_LOGIC_VECTOR (31 downto 0);
        d_in :  in STD_LOGIC_VECTOR(4 downto 0);
        pc_out :  out STD_LOGIC_VECTOR (31 downto 0);
        d_out :  out STD_LOGIC_VECTOR(4 downto 0);
        a_select_forward : out STD_LOGIC;
        b_select_forward : out STD_LOGIC;
        opclass_in : in STD_LOGIC_VECTOR (4 downto 0); -- for the data memory
        opclass_out : out STD_LOGIC_VECTOR (4 downto 0);
        value_1_forward : out STD_LOGIC_VECTOR (31 downto 0);
        value_2_forward : out STD_LOGIC_VECTOR (15 downto 0);
        a2_select : in STD_LOGIC;
        b2_select : in STD_LOGIC;
        c_select : in STD_LOGIC;
        memory_value : in STD_LOGIC_VECTOR (31 downto 0));
end component;
COMPONENT data_memory
  PORT (clka : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
   );
END COMPONENT;
component read_write_back_stage is
    Port (pc : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward: in STD_LOGIC_VECTOR (31 downto 0);
        fpu_forward : in STD_LOGIC_VECTOR (31 downto 0);
        is_float : in std_logic;
        is_ml : in std_logic;
        mlu_forward : in STD_LOGIC_VECTOR (31 downto 0);
        opclass : in STD_LOGIC_VECTOR (4 downto 0);
        mem_out : in STD_LOGIC_VECTOR (31 downto 0);
        rd_in: in STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_out: out STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_register_file : out std_logic;
        rd_value : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component control_unit is
    Port ( rst : in std_logic;
        clk : in std_logic;  
        opclass : in std_logic_vector(4 downto 0);
    	-- signals for data hazards with consecutive operations
    	data_source1 : in std_logic_vector(4 downto 0);
    	data_source2 : in std_logic_vector(4 downto 0);
    	data_destination : in std_logic_vector(4 downto 0); --got from the outptu of the execution stage
    	con_data_hazard_1 : out std_logic;
    	con_data_hazard_2 : out std_logic;
		--signals for all types of data hazards
		source1 : in std_logic_vector(4 downto 0);
    	source2 : in std_logic_vector(4 downto 0);
    	destination : in std_logic_vector(4 downto 0);--got from the input of the write back
    	data_hazard_1 : out std_logic;
    	data_hazard_2 : out std_logic;
		load_hazard_1 : out std_logic;
		load_hazard_2 : out std_logic;
    	--signals for flushing
    	a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        branch_condition : in STD_LOGIC;
        stall : out STD_LOGIC);
end component;
component seven_segment_driver is
generic (
    size : integer := 20
    );
Port (clock : in std_logic;
      reset : in std_logic;
      digit0 : in std_logic_vector( 3 downto 0 );
      digit1 : in std_logic_vector( 3 downto 0 );
      digit2 : in std_logic_vector( 3 downto 0 );
      digit3 : in std_logic_vector( 3 downto 0 );
      CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
      AN : out std_logic_vector( 3 downto 0 ));
    end component;

-----signals to connect each stage-----

--signals in between instruction fetch and instruction decode
signal pc_if_id : STD_LOGIC_VECTOR (31 downto 0);
signal instruction_if_id : STD_LOGIC_VECTOR (31 downto 0);

--signals between instruction decode and execution
signal pc_id_ex :  STD_LOGIC_VECTOR (31 downto 0);
signal immediate_id_ex : STD_LOGIC_VECTOR (31 downto 0);
signal opclass_id_ex : STD_LOGIC_VECTOR (4 downto 0);
signal alu_opcode_id_ex : STD_LOGIC_VECTOR (2 downto 0);
signal a_select_id_ex : STD_LOGIC;
signal b_select_id_ex : STD_LOGIC;
signal is_float_id_ex : STD_LOGIC;
signal is_ml_id_ex : STD_LOGIC;
signal ml_opcode_id_ex : STD_LOGIC;
signal conditional_opcode_id_ex : STD_LOGIC_VECTOR (2 downto 0);
signal destination_address_id_ex : STD_LOGIC_VECTOR(4 DOWNTO 0);
signal s_value_1_id : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_2_id : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3_id : STD_LOGIC_VECTOR (31 downto 0);

--signals from execute 
signal alu_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal mlu_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal fpu_output_ex : STD_LOGIC_VECTOR (31 downto 0);
signal branch_condition_ex_control : std_logic;
signal destination_address_out_ex :  STD_LOGIC_VECTOR (4 downto 0);
signal pc_ex : STD_LOGIC_VECTOR (31 downto 0);
signal opclass_out_ex : STD_LOGIC_VECTOR (4 downto 0);
signal s_value_1_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_2_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3_ex : STD_LOGIC_VECTOR (31 downto 0);
signal value_2_ex_display : STD_LOGIC_VECTOR (15 downto 0);

--signals connected to data memory
signal write_enable_dm : std_logic;
signal value_1_ex_dm : STD_LOGIC_VECTOR (31 downto 0);
signal mem_out_dm : STD_LOGIC_VECTOR (31 downto 0); -- output

--signals connected to read and write back stage
signal mem_out_wb : STD_LOGIC_VECTOR (31 downto 0);
signal rd_in_wb : STD_LOGIC_VECTOR (4 downto 0);
signal pc_wb : STD_LOGIC_VECTOR (31 downto 0);
signal alu_forward_wb : STD_LOGIC_VECTOR (31 downto 0);
signal opclass_wb : STD_LOGIC_VECTOR (4 downto 0);
signal mlu_forward_wb : STD_LOGIC_VECTOR (31 downto 0);
signal fpu_forward_wb : STD_LOGIC_VECTOR (31 downto 0);
signal is_float_wb : std_logic;
signal is_ml_wb : std_logic;

--signals in between write back and instruction decode
signal destination_value_wb_id : STD_LOGIC_VECTOR (31 downto 0);
signal destination_address_wb_id : STD_LOGIC_VECTOR(4 DOWNTO 0); 
signal write_enable_wb_id : std_logic;

--signals connected to control unit
signal opclass_control : STD_LOGIC_VECTOR (4 downto 0);
signal flush_control : std_logic;
signal load_hazard_1_control_ex : std_logic;
signal load_hazard_2_control_ex : std_logic;
signal load_hazard_3_control_ex : std_logic;
signal consecutive_data_hazard_1_control : std_logic;
signal consecutive_data_hazard_2_control : std_logic;
signal consecutive_data_hazard_3_control : std_logic;
signal non_consecutive_data_hazard_1_control : std_logic;
signal non_consecutive_data_hazard_2_control : std_logic;
signal non_consecutive_data_hazard_3_control : std_logic;

--signals in between instruction decode and control unit
signal source_1_id_control : std_logic_vector(4 downto 0);
signal source_2_id_control : std_logic_vector(4 downto 0);

--signals in between execution and control unit
signal a_select_ex_control: std_logic;
signal b_select_ex_control: std_logic;

-- I/O signals
signal switches_signal :STD_LOGIC_VECTOR (15 downto 0);
signal display_signal : std_logic_vector(15 downto 0);

begin
if_stage: instruction_fetch_stage
    Port map(clk=>clk,
        rst=>rst,
        branch_condition=> flush_control,
        branch_pc=>alu_output_ex(11 downto 0),
        pc_out=>pc_if_id,
       	instruction=>instruction_if_id);
id_stage: instruction_decode
    Port map(pc_in =>pc_if_id,
       	instruction=> instruction_if_id,
       	destination_value_from_wb => destination_value_wb_id,
       	destination_address_from_wb => destination_address_wb_id,
	    write_enable_from_wb =>write_enable_wb_id,
	   	clk=>clk,
        rst =>rst,
	    pc_out => pc_id_ex,
       	immediate => immediate_id_ex,
	    op_class => opclass_id_ex,
       	alu_opcode => alu_opcode_id_ex,
	    a_select => a_select_id_ex,
       	b_select => b_select_id_ex,
	    conditional_opcode => conditional_opcode_id_ex,
       	s_value_1 => s_value_1_id,
		s_value_2  => s_value_2_id,
		s_value_3  => s_value_3_id,
		r1 => source_1_id_control,
		r2 => source_2_id_control,
       	destination_address  => destination_address_id_ex,
      	flush => flush_control,
        is_float => is_float_id_ex,
        is_ml => is_ml_id_ex,
        ml_opcode => ml_opcode_id_ex);
exe_stage : execution_stage
    Port map(clk => clk,
        rst => rst,
        flush => flush_control,
        value_1 => s_value_1_ex,
        value_2 => s_value_2_ex,
        value_3 => s_value_3_ex,
        conditional_opcode => conditional_opcode_id_ex,
        pc => pc_id_ex,
        a_select => a_select_id_ex,
        b_select => b_select_id_ex,
        a2_select => load_hazard_1_control_ex,
        b2_select => load_hazard_2_control_ex,
        c_select => load_hazard_3_control_ex,
        memory_value => mem_out_wb, ---input from the output of the data memory
       	immediate => immediate_id_ex,
        alu_opcode => alu_opcode_id_ex,
        opclass_in => opclass_id_ex, 
        opclass_out => opclass_out_ex,
        value_1_forward => value_1_ex_dm,
        value_2_forward => value_2_ex_display,
        a_select_forward =>a_select_ex_control ,
        b_select_forward => b_select_ex_control,
        d_in => destination_address_id_ex,
        d_out => destination_address_out_ex,
        branch_condition => branch_condition_ex_control,
        pc_out =>pc_ex,
        alu_output => alu_output_ex,
        ml_opcode => ml_opcode_id_ex,
        is_float => is_float_id_ex,
        is_ml => is_ml_id_ex,
        fpu_output => fpu_output_ex,
        mlu_output => mlu_output_ex);

stage_dm : data_memory
   	PORT MAP ( clka => clk ,
    	wea(0) => write_enable_dm,
    	addra => alu_output_ex(9 DOWNTO 0),
    	dina => value_1_ex_dm,
    	douta => mem_out_dm);
    	
wb_stage : read_write_back_stage
    Port map(pc => pc_wb,
        is_float => is_float_wb,
        is_ml => is_ml_wb,
        alu_forward => alu_forward_wb,
        fpu_forward => fpu_forward_wb,
        mlu_forward => mlu_forward_wb,
        opclass => opclass_wb,
        mem_out => mem_out_wb,
        rd_in => rd_in_wb,
        rd_out=> destination_address_wb_id,
        write_register_file => write_enable_wb_id,
        rd_value => destination_value_wb_id);  

cu : control_unit
    Port map (rst => rst,
        clk => clk,
        opclass => opclass_control,
        -- signals for data hazards with consecutive operations
    	data_source1 => source_1_id_control,
    	data_source2 => source_2_id_control,
    	data_destination => destination_address_out_ex,
    	con_data_hazard_1 => consecutive_data_hazard_1_control,
    	con_data_hazard_2 =>consecutive_data_hazard_2_control,
    	-- signals for data hazards with nonconsecutive operations
		source1 => instruction_if_id(19 downto 15),
    	source2 => instruction_if_id(24 downto 20),
    	destination => destination_address_out_ex,
    	data_hazard_1 => non_consecutive_data_hazard_1_control,
    	data_hazard_2 => non_consecutive_data_hazard_2_control,
		load_hazard_1 => load_hazard_1_control_ex,
		load_hazard_2 => load_hazard_2_control_ex,
		a_select => a_select_ex_control,
        b_select => b_select_ex_control,
        branch_condition => branch_condition_ex_control,
        stall => flush_control);
		    	
seven_segment_display : seven_segment_driver
Port map(clock => clk,
        reset => rst,
        digit0 => display_signal(3 downto 0),
        digit1 => display_signal(7 downto 4),
        digit2 => display_signal(11 downto 8),
        digit3 => display_signal(15 downto 12),
        CA => CA,
        CB => CB,
        CC => CC,
        CD => CD,
        CE => CE,
        CF => CF,
        CG => CG,
        DP => DP,
        AN => AN);
-- I/O
switches_signal <= switches;

registered_write_back : process (rst, clk) begin
    if rst = '0' then 
        pc_wb <= (others => '0');
        alu_forward_wb <= (others => '0');
        opclass_wb <= (others => '0');
        rd_in_wb <= (others => '0');
    elsif rising_edge(clk) then 
        pc_wb <= pc_ex;
        alu_forward_wb <= alu_output_ex;
        opclass_wb <= opclass_out_ex;
        rd_in_wb <= destination_address_out_ex;
    end if;
end process;
dm_write : process (opclass_out_ex) begin
    if opclass_out_ex = "00010" then --store
        write_enable_dm <= '1';
    else write_enable_dm <= '0';
    end if;
    opclass_control <= opclass_out_ex;
end process;

switch_display : process (rst, clk) begin
    if rst = '0' then
        display_signal <= (others => '0');
        mem_out_wb(31 downto 0) <= (others => '0');
    elsif rising_edge(clk) then
        if  (value_1_ex_dm >=  x"20000000" and value_1_ex_dm <= x"20000010") then
            mem_out_wb(31 downto 16) <= (others => '0');
            mem_out_wb(15 downto 0) <= switches_signal(15 downto 0);
        else
            mem_out_wb <= mem_out_dm;
        end if;
        if value_1_ex_dm(31 downto 0) = x"30000000" then
            if opclass_out_ex = "00010" then
                display_signal <= value_2_ex_display;
            end if;
        end if;
    end if;
end process;

data_hazards_1 : process ( s_value_1_id, consecutive_data_hazard_1_control, alu_output_ex,
                           non_consecutive_data_hazard_1_control, destination_value_wb_id ) begin
	if non_consecutive_data_hazard_1_control = '1' then 
        s_value_1_ex <= destination_value_wb_id;
    elsif consecutive_data_hazard_1_control ='1' then 
		s_value_1_ex <= alu_output_ex;
	else 
	 	s_value_1_ex <= s_value_1_id;
	 end if;
end process;
data_hazards_2 : process ( s_value_2_id, consecutive_data_hazard_2_control , alu_output_ex ,
                           non_consecutive_data_hazard_2_control, destination_value_wb_id ) begin
	if non_consecutive_data_hazard_2_control = '1' then 
        s_value_2_ex <= destination_value_wb_id;
	elsif consecutive_data_hazard_2_control ='1' then 
		s_value_2_ex <= alu_output_ex;
	else 
	 	s_value_2_ex <= s_value_2_id;
	 end if;
end process;
data_hazards_3 : process ( s_value_3_id, consecutive_data_hazard_3_control , alu_output_ex ,
                           non_consecutive_data_hazard_3_control, destination_value_wb_id ) begin
	if non_consecutive_data_hazard_3_control = '1' then 
        s_value_3_ex <= destination_value_wb_id;
	elsif consecutive_data_hazard_3_control ='1' then 
		s_value_3_ex <= alu_output_ex;
	else 
	 	s_value_3_ex <= s_value_3_id;
	 end if;
end process;
end Behavioral;