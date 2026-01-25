library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_decode is
  Port ( clk : in STD_LOGIC;
      	rst : in STD_LOGIC;
      	flush : in STD_LOGIC; -- active high, used for flushing 
--        stall : in std_logic;
		pc : in STD_LOGIC_VECTOR ( 31 downto 0 ); -- forwarded to the next stage without being used
		instruction : in STD_LOGIC_VECTOR ( 31 downto 0 );
		destination_value_from_wb : in STD_LOGIC_VECTOR ( 31 downto 0 ); -- writing value into register file
		destination_address_from_wb : in STD_LOGIC_VECTOR( 4 DOWNTO 0 ); -- address to which the value is written to
		write_enable_from_wb : in STD_LOGIC;
		write_vec_reg : in std_logic; -- enable to indicate whether the vector file should be written into
		destination_value_vec : in std_logic_vector( 127 downto 0 ); -- value to be written into vector register
		destination_element_vec : in std_logic_vector( 3 downto 0 ); -- address to which the value should be written to
		pc_forward : out STD_LOGIC_VECTOR ( 31 downto 0 ); -- value used for the execution stage
		immediate : out STD_LOGIC_VECTOR ( 31 downto 0 );
		opclass : out STD_LOGIC_VECTOR ( 4 downto 0 );
		opcode : out STD_LOGIC_VECTOR ( 3 downto 0 ); 
		a_select :out STD_LOGIC_VECTOR (1 downto 0);
        b_select : out STD_LOGIC_VECTOR (1 downto 0);
		conditional_opcode : out STD_LOGIC_VECTOR ( 2 downto 0 ); 
		r1_forward : out std_logic_vector( 4 downto 0 );
		r2_forward : out std_logic_vector( 4 downto 0 );
		r3_forward : out STD_LOGIC_vector( 4 downto 0 );
		s_value_1 : out STD_LOGIC_VECTOR ( 31 downto 0 ); 
		s_value_2 : out STD_LOGIC_VECTOR ( 31 downto 0 );
		s_value_3 : out STD_LOGIC_VECTOR ( 31 downto 0 );
		destination_address : out STD_LOGIC_VECTOR( 4 DOWNTO 0 );
		is_float : out std_logic;
		is_ml : out std_logic;
		is_vl : out std_logic;
		vec_reg_en : out std_logic;
		vec1_data : out std_logic_vector ( 127 downto 0 );
        vec2_data : out std_logic_vector ( 127 downto 0 ));
end instruction_decode;

architecture Behavioral of instruction_decode is
component register_file is
  	port ( rst : in std_logic;
    clk : in std_logic;
    en : in std_logic; -- active low
    r1 : in std_logic_vector( 4 downto 0 ); 
    r2 : in std_logic_vector( 4 downto 0 ); 
    r3 : in std_logic_vector( 4 downto 0 ); 
    rd_in : in std_logic_vector( 4 downto 0 );
    rd_data_in : in std_logic_vector( 31 downto 0 );
    we : in std_logic;
    r1_data : out std_logic_vector( 31 downto 0 );
    r2_data : out std_logic_vector( 31 downto 0 );
    r3_data : out std_logic_vector( 31 downto 0 ));
end component;
component vec_reg is
    Port( rst : in std_logic;
        clk : in std_logic;
        en : in std_logic;
        write_en : in std_logic;
        vd_data_in : std_logic_vector ( 127 downto 0 );
        vec_dest : in std_logic_vector( 4 downto 0 );
        vec_element : in std_logic_vector ( 3 downto 0 );
        v1 : in std_logic_vector( 4 downto 0 );
        v2 : in std_logic_vector( 4 downto 0 );
        v1_data : out std_logic_vector ( 127 downto 0 );
        v2_data : out std_logic_vector ( 127 downto 0 ));
end component;
component decoder is
  	Port ( rst : in std_logic;
        clk : in std_logic;
    	flush : in std_logic;
    	opcode : in std_logic_vector(6 downto 0);
		funct7 : in std_logic_vector(6 downto 0);
		funct3 : in std_logic_vector(2 downto 0);
        opclass : out STD_LOGIC_VECTOR (4 downto 0);
        operation_code : out STD_LOGIC_VECTOR (3 downto 0);
        a_select :out STD_LOGIC_VECTOR (1 downto 0);
        b_select : out STD_LOGIC_VECTOR (1 downto 0);
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
        fpu_en : out std_logic;
        vpu_en : out std_logic;
        vec_reg_en : out std_logic;
        mlu_en : out std_logic);
end component;
component immediate_generator is
  	Port ( rst : in std_logic;
          clk : in std_logic;
          flush : in std_logic;
          opcode : in STD_LOGIC_VECTOR( 6 downto 0 );
          funct3 : in STD_LOGIC_VECTOR( 2 downto 0 );
          instruction : in STD_LOGIC_VECTOR( 31 downto 7 );
          immediate : out STD_LOGIC_VECTOR( 31 downto 0 ));
end component;

--------connections-----------
signal v1_input : std_logic_vector(4 downto 0);

begin

reg_file_decode: register_file
  PORT map( rst => rst,
        clk => clk,
    	en => flush,
        r1 => instruction( 19 downto 15 ),
    	r2 => instruction( 24 downto 20 ),
    	r3 => instruction( 11 downto 7 ),
    	rd_in => destination_address_from_wb,
    	rd_data_in => destination_value_from_wb,
    	we => write_enable_from_wb,
    	r1_data => s_value_1,
    	r2_data => s_value_2,
        r3_data => s_value_3 );

vec_file_decode : vec_reg
	port map( rst => rst,
		clk => clk,
		en => flush,
		write_en => write_vec_reg,
		vd_data_in => destination_value_vec,
		vec_dest => destination_address_from_wb,
		vec_element => destination_element_vec,
		v1 => v1_input,
		v2 => instruction( 24 downto 20 ),
		v1_data => vec1_data,
		v2_data => vec2_data );

decoder_decode : decoder 
  Port map( clk => clk,
		rst => rst,
		flush => flush,
		opcode => instruction( 6 downto 0 ),
		funct7 =>  instruction( 31 downto 25 ),
		funct3 =>  instruction( 14 downto 12 ),
		opclass => opclass,
		operation_code => opcode,
		a_select => a_select,
		b_select => b_select,
		conditional_opcode => conditional_opcode,
		fpu_en => is_float,
		vec_reg_en => vec_reg_en,
		vpu_en => is_vl,
		mlu_en => is_ml ); 

imm_gen_decode : immediate_generator
  Port map( clk => clk,
          rst => rst,
          opcode => instruction( 6 downto 0 ), 
          instruction => instruction( 31 downto 7 ),
          immediate => immediate,
          funct3 =>  instruction( 14 downto 12 ),
          flush => flush );

vec_file_input_1 : process ( instruction ) begin
	if instruction(6 downto 0) = "0100111" then -- vector store
		v1_input <= instruction(11 downto 7);
	else
		v1_input <= instruction(19 downto 15);
	end if;
end process;
-- for signals that need to be forwarded to the next stage without being
process ( clk, rst ) begin
    if rst = '0' then 
        pc_forward <= ( others => '0' );
        destination_address <= ( others => '0' );
        r1_forward <= ( others => '0' );
        r2_forward <= ( others => '0' );
        r3_forward <= ( others => '0' );
    elsif rising_edge( clk ) then 
        if flush ='0' then 
            pc_forward <= pc;
            destination_address <= instruction( 11 downto 7 );
            r1_forward <= instruction( 19 downto 15 );
            r2_forward <= instruction( 24 downto 20 );
            r3_forward <= instruction( 11 downto 7 );
		else 
            pc_forward <= ( others => '0' );
            destination_address <= ( others => '0' );
            r1_forward <= ( others => '0' );
            r2_forward <= ( others => '0' );
            r3_forward <= ( others => '0' );
        end if;
    end if;
end process;
end Behavioral;