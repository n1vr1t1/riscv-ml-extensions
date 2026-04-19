library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity instruction_decode is
  Port ( clk : in STD_LOGIC;
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
end instruction_decode;

architecture Behavioral of instruction_decode is
component register_file is
  	port ( rst : in std_logic;
    clk : in std_logic;
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
        we : in std_logic;
        vd_data : std_logic_vector( 127 downto 0 );
        vd : in std_logic_vector( 4 downto 0 );
        vec_element : in std_logic_vector( 3 downto 0 );
        v1 : in std_logic_vector( 4 downto 0 );
        v2 : in std_logic_vector( 4 downto 0 );
        v3 : in std_logic_vector( 4 downto 0 );
        v1_data : out std_logic_vector( 127 downto 0 );
        v2_data : out std_logic_vector( 127 downto 0 );
        v3_data : out std_logic_vector( 127 downto 0 ));
end component;
component decoder is
    Port (rst : in std_logic;
        clk : in std_logic;
    	flush : in std_logic; -- active low
		instruction : in std_logic_vector(31 downto 0);
        opclass : out STD_LOGIC_VECTOR (4 downto 0);
        operation_code : out STD_LOGIC_VECTOR (3 downto 0); -- used by alu, fpu and mlu
        a_select :out STD_LOGIC_VECTOR (1 downto 0);
        b_select : out STD_LOGIC_VECTOR (1 downto 0);
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
        uncond_branch : out STD_LOGIC;
        fpu_en : out std_logic;
        vpu_en : out std_logic;
        vec_reg_en : out std_logic;
        vecDM_en : out std_logic;
        mlu_en : out std_logic;
		reduction_unit_en : out std_logic);
end component;
component immediate_generator is
  	Port ( rst : in std_logic;
          clk : in std_logic;
          flush : in std_logic; --active low
          opcode : in STD_LOGIC_VECTOR( 6 downto 0 );
          instruction : in STD_LOGIC_VECTOR( 31 downto 7 );
          immediate : out STD_LOGIC_VECTOR( 31 downto 0 ));
end component;

-------- CONNECTIONS -----------
begin

reg_file_decode: register_file
  PORT map( rst => rst,
        clk => clk,
        r1 => instruction( 19 downto 15 ),
    	r2 => instruction( 24 downto 20 ),
    	r3 => instruction( 11 downto 7 ),
    	rd_in => dest_addr_wb,
    	rd_data_in => rd_val_wb,
    	we => wen_wb,
    	r1_data => source_1,
    	r2_data => source_2,
        r3_data => source_3 );

vec_file_decode : vec_reg
	port map( rst => rst,
		clk => clk,
		we => vec_wen_wb,
		vd_data => vd_val_wb,
		vd => dest_addr_wb,
		vec_element => vd_element,
		v1 => instruction ( 19 downto 15 ),
		v2 => instruction( 24 downto 20 ),
		v3 => instruction( 11 downto 7 ),
		v1_data => vec1_data,
		v2_data => vec2_data,
		v3_data => vec3_data );

decoder_decode : decoder 
  Port map( clk => clk,
		rst => rst,
		flush => flush,
		instruction => instruction,
		opclass => opclass,
		operation_code => opcode,
		a_select => a_select,
		b_select => b_select,
		conditional_opcode => conditional_opcode,
        uncond_branch => uncond_branch,
		fpu_en => float_en,
		vec_reg_en => vec_reg_en,
		vecDM_en => vecDM_en,
		vpu_en => vu_en,
		mlu_en => ml_en,
        reduction_unit_en => ru_en); 

imm_gen_decode : immediate_generator
  Port map( clk => clk,
          rst => rst,
          flush => flush,
          opcode => instruction( 6 downto 0 ), 
          instruction => instruction( 31 downto 7 ),
          immediate => immediate);
		  
-- for signals that need to be forwarded to the next stage without being
process ( clk, rst ) begin
    if rst = '0' then 
        pc_forward <= ( others => '0' );
        r1_address <= ( others => '0' );
        r2_address <= ( others => '0' );
        r3_address <= ( others => '0' );
    elsif rising_edge( clk ) then 
        if flush = '1' then 
            pc_forward <= ( others => '0' );
            r1_address <= ( others => '0' );
            r2_address <= ( others => '0' );
            r3_address <= ( others => '0' );
		else 
            pc_forward <= pc;
            r1_address <= instruction( 19 downto 15 );
            r2_address <= instruction( 24 downto 20 ); -- rewrite to have logic for vector write back through operations and store
            r3_address <= instruction( 11 downto 7 );
        end if;
    end if;
end process;
end Behavioral;