library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_test is
  Port (clk : in STD_LOGIC;
        rst: in STD_LOGIC; -- active low
        pc_in : in STD_LOGIC_VECTOR (31 downto 0);
        instruction : in STD_LOGIC_VECTOR (31 downto 0);
        destination_value_from_wb : in STD_LOGIC_VECTOR (31 downto 0);
        destination_address_from_wb : in STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_enable_from_wb : in STD_LOGIC;
        flush : in STD_LOGIC;
        fpu_output : out STD_LOGIC_VECTOR (31 downto 0);
        alu_output : out STD_LOGIC_VECTOR (31 downto 0);
        mlu_output : out STD_LOGIC_VECTOR (31 downto 0);
        branch_condition : out STD_LOGIC;
        pc_out :  out STD_LOGIC_VECTOR (31 downto 0);
        d_out :  out STD_LOGIC_VECTOR(4 downto 0);
        a_select_forward : out STD_LOGIC;
        b_select_forward : out STD_LOGIC;
        opclass_out : out STD_LOGIC_VECTOR (4 downto 0);
        value_1_forward : out STD_LOGIC_VECTOR (31 downto 0);
        value_2_forward : out STD_LOGIC_VECTOR (15 downto 0);
        a2_select : in STD_LOGIC;
        b2_select : in STD_LOGIC;
        c_select : in STD_LOGIC;
        memory_value : in STD_LOGIC_VECTOR (31 downto 0));
end top_test;

architecture Behavioral of top_test is

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

signal pc_id_ex : STD_LOGIC_VECTOR (31 downto 0);
signal a_select_id_ex : STD_LOGIC;
signal b_select_id_ex : STD_LOGIC; 
signal a_select_ex_control : STD_LOGIC := '0';
signal b_select_ex_control : STD_LOGIC := '0'; 
signal load_hazard_1_control_ex : STD_LOGIC;
signal load_hazard_2_control_ex : STD_LOGIC;
signal c_select_control_ex : STD_LOGIC := '0'; 
signal flush_control : STD_LOGIC; 
signal is_float_id_ex : STD_LOGIC; 
signal is_ml_id_ex : STD_LOGIC; 
signal ml_opcode_id_ex : STD_LOGIC;
signal opclass_id_ex : STD_LOGIC_VECTOR (4 downto 0);
signal opclass_out_ex : STD_LOGIC_VECTOR (4 downto 0);
signal alu_opcode_id_ex : STD_LOGIC_VECTOR (3 downto 0);
signal immediate_id_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_1_id : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_2_id : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3_id : STD_LOGIC_VECTOR (31 downto 0);
signal conditional_opcode_id_ex : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal source_1_id_control : STD_LOGIC_VECTOR(4 downto 0);
signal source_2_id_control : STD_LOGIC_VECTOR(4 downto 0);
signal destination_address_id_ex : STD_LOGIC_VECTOR(4 downto 0);
signal s_value_1_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_2_ex : STD_LOGIC_VECTOR (31 downto 0);
signal s_value_3_ex : STD_LOGIC_VECTOR (31 downto 0);
signal mem_out_wb : STD_LOGIC_VECTOR (31 downto 0);
signal value_1_ex_dm : STD_LOGIC_VECTOR (31 downto 0);
signal value_2_ex_display : STD_LOGIC_VECTOR (31 downto 0);
signal write_enable_dm : std_logic;
signal mem_out_dm : STD_LOGIC_VECTOR (31 downto 0); --output
begin
        
id : instruction_decode
    Port map(pc_in =>pc_in,
       	instruction=> instruction,
       	destination_value_from_wb => destination_value_from_wb,
       	destination_address_from_wb => destination_address_from_wb,
	    write_enable_from_wb => write_enable_from_wb,
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
      	flush => flush,
        is_float => is_float_id_ex,
        is_ml => is_ml_id_ex,
        ml_opcode => ml_opcode_id_ex);
exe : execution_stage
    Port map(clk => clk,
        rst => rst,
        flush => flush,
        value_1 => s_value_1_ex,
        value_2 => s_value_2_ex,
        value_3 => s_value_3_ex,
        conditional_opcode => conditional_opcode_id_ex,
        pc => pc_id_ex,
        a_select => a_select_id_ex,
        b_select => b_select_id_ex,
        c_select => c_select_control_ex,
        a2_select => load_hazard_1_control_ex,
        b2_select => load_hazard_2_control_ex,
        memory_value => mem_out_wb, ---input from the output of the data memory
       	immediate => immediate_id_ex,
        alu_opcode => alu_opcode_id_ex,
        opclass_in => opclass_id_ex, 
        opclass_out => opclass_out,
        value_1_forward => value_1_forward,
        value_2_forward => value_2_forward,
        a_select_forward => a_select_forward ,
        b_select_forward => b_select_forward,
        d_in => destination_address_id_ex,
        d_out => d_out,
        branch_condition => branch_condition,
        pc_out =>pc_out,
        alu_output => alu_output,
        ml_opcode => ml_opcode_id_ex,
        is_float => is_float_id_ex,
        is_ml => is_ml_id_ex,
        fpu_output => fpu_output,
        mlu_output => mlu_output);
end Behavioral;
