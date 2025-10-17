library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity instruction_decode is
  Port (pc_in : in STD_LOGIC_VECTOR (31 downto 0); --forwarded to the next stage without being used
      instruction : in STD_LOGIC_VECTOR (31 downto 0);
      destination_value_from_wb : in STD_LOGIC_VECTOR (31 downto 0);
      destination_address_from_wb : in STD_LOGIC_VECTOR(4 DOWNTO 0);
      write_enable_from_wb : in STD_LOGIC; 
      clk : in STD_LOGIC; -- not in use (why?)
      rst : in STD_LOGIC;
      flush : in STD_LOGIC; --active high, used fo flushing 
--      stall : in std_logic;
      pc_out : out STD_LOGIC_VECTOR (31 downto 0);
      immediate : out STD_LOGIC_VECTOR (31 downto 0);
      op_class : out STD_LOGIC_VECTOR (4 downto 0);
      alu_opcode : out STD_LOGIC_VECTOR (3 downto 0); 
      a_select : out STD_LOGIC; 
      b_select : out STD_LOGIC;
      conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0); 
      r1 : out std_logic_vector(4 downto 0);
      r2 : out std_logic_vector(4 downto 0);
      s_value_1 : out STD_LOGIC_VECTOR (31 downto 0); 
      s_value_2 : out STD_LOGIC_VECTOR (31 downto 0);
      s_value_3 : out STD_LOGIC_VECTOR (31 downto 0);
      destination_address : out STD_LOGIC_VECTOR(4 DOWNTO 0);
      is_float : out std_logic;
      is_ml : out std_logic;
      ml_opcode : out std_logic);
end instruction_decode;

architecture Behavioral of instruction_decode is
component register_file is
  port (rst : in std_logic;
    clk : in std_logic;
--        stall : in std_logic;
    en : in std_logic; -- active low
    r1 : in std_logic_vector( 4 downto 0 );-- Source 1 address
    r2 : in std_logic_vector( 4 downto 0 );-- Source 2 address
    rd_out : in std_logic_vector( 4 downto 0 );-- Destination address for reading
    rd_in : in std_logic_vector( 4 downto 0 );-- Destination address for writing
    rd_data_in : in std_logic_vector( 31 downto 0 );-- Destination data for writing
    we : in std_logic;-- write enable
    r1_data : out std_logic_vector( 31 downto 0 );-- Register value of source 1
    r2_data : out std_logic_vector( 31 downto 0 );-- Register value of source 2
    rd_data_out : out std_logic_vector( 31 downto 0 ) -- Register value of destination for reading
  );
 end component;
component decoder is
  Port (rst : in std_logic;
--        stall : in std_logic;
        clk : in std_logic;
    	flush : in std_logic; --active low
    	op_code : in std_logic_vector(6 downto 0);
		funct7 : in std_logic_vector(6 downto 0);
		funct3 : in std_logic_vector(2 downto 0);
        op_class : out STD_LOGIC_VECTOR (4 downto 0);
        alu_opcode : out STD_LOGIC_VECTOR (3 downto 0);
        a_select : out STD_LOGIC;
        b_select : out STD_LOGIC;
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
        f_op : out std_logic;
        ml_op : out std_logic;
        ml_opcode : out std_logic);
  end component;
component immediate_generator is
    Port (rst : in std_logic;
--        stall : in std_logic;
          clk : in std_logic;
          flush : in std_logic; --active low
          opcode : in STD_LOGIC_VECTOR (6 downto 0);
          funct3 : in STD_LOGIC_VECTOR (2 downto 0);
          instruction : in STD_LOGIC_VECTOR (31 downto 7); -- reduce the instruction signal to exclude opcode part
          immediate : out STD_LOGIC_VECTOR (31 downto 0));
  end component;

--------connections-----------
begin

reg_file_decode: register_file
  PORT map(rst => rst,
        clk => clk,
        r1 => instruction(19 downto 15),
    	r2 => instruction(24 downto 20),
    	rd_in => destination_address_from_wb,
    	rd_data_in => destination_value_from_wb,
    	we => write_enable_from_wb,
    	r1_data => s_value_1,
    	r2_data => s_value_2,
        rd_out => instruction(11 downto 7),
        rd_data_out => s_value_3,
    	en =>flush); -- need to and with the stall signal if creating one

decoder_decode : decoder 
  Port map(clk => clk,
            rst=>rst,
--            stall => stall,
          	op_code => instruction(6 downto 0),
			funct7 =>  instruction(31 downto 25),
		  	funct3 =>  instruction(14 downto 12),
          	op_class => op_class,
          	alu_opcode => alu_opcode,
          	a_select => a_select,
          	b_select => b_select,
          	conditional_opcode => conditional_opcode,
            f_op => is_float,
            ml_op => is_ml,
            ml_opcode => ml_opcode,
          	flush => flush ); 

imm_gen_decode : immediate_generator
  Port map(clk => clk,
          rst => rst,
--        stall => stall,
          opcode => instruction(6 downto 0), 
          instruction => instruction(31 downto 7),
          immediate => immediate,
          funct3 =>  instruction(14 downto 12),
          flush => flush);
process (clk, rst) begin
    if rst = '0' then 
        pc_out <= (others => '0');
        destination_address <= (others => '0');
        r1 <= (others => '0');
        r2 <= (others => '0');
    elsif rising_edge(clk) then 
        if flush ='0' then 
            pc_out <= pc_in;
            destination_address <= instruction(11 downto 7);
            r1 <= instruction(19 downto 15);
            r2 <= instruction(24 downto 20);
        else
            pc_out <= (others => '0');
            destination_address <= (others => '0');
            r1 <= (others => '0');
            r2 <= (others => '0'); 
        end if;
    end if;
end process;
end Behavioral;