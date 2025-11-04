
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity instruction_fetch_stage is
    Port (clk : in STD_LOGIC;
          rst: in STD_LOGIC;
          branch_condition: in std_logic; --active high
          branch_pc: in STD_LOGIC_VECTOR(11 downto 0);
          pc_out : out STD_LOGIC_VECTOR (31 downto 0);
          instruction : out STD_LOGIC_VECTOR (31 downto 0));
end instruction_fetch_stage;

architecture Behavioral of instruction_fetch_stage is

signal program_counter_in : std_logic_vector(11 downto 0); --connected to the input of the program counter
signal program_counter_out : std_logic_vector(11 downto 0); --connected from the output of the program counter to the onputs of the sign extension and instruction memory
signal enable : std_logic;
signal instruction_signal : STD_LOGIC_VECTOR (31 downto 0);
signal instruction_flush : std_logic;

COMPONENT instruction_memory
    PORT (clka : IN STD_LOGIC;
      wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
      addra : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
      dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
    );
  END COMPONENT;
 component program_counter is
     Port (pc : in STD_LOGIC_VECTOR (11 downto 0);
     	clk: in std_logic;
    	pc_out : out STD_LOGIC_VECTOR (11 downto 0);
        rst: in std_logic);
end component;
  component sign_extention_pc is
      Port (clk: in std_logic;
      	rst: in std_logic;
    	en : in std_logic; --used for flushing, active high (gets the inverted signal of branch_condition)
    	pc : in STD_LOGIC_VECTOR (11 downto 0);
        extended_pc : out STD_LOGIC_VECTOR (31 downto 0));
  end component;

begin
 ifs_pc :program_counter
    Port map(pc =>program_counter_in,
    		pc_out=>program_counter_out,
		    clk=>clk,
        	rst=>rst);
ifs_mem : instruction_memory
  PORT MAP (clka => clk,
    wea(0) => '0' ,
    addra => std_logic_vector(program_counter_out(11 downto 2)) ,
    dina => "00000000000000000000000000000000" ,
    douta => instruction_signal);

pc_sign_extension: sign_extention_pc
    Port map (en => enable,
    	rst => rst,
    	clk =>clk,
        pc =>program_counter_in,
		extended_pc => pc_out);
process (branch_pc , program_counter_out, branch_condition) begin
    enable<=not(branch_condition);
    case branch_condition is
    when '1' => program_counter_in <= branch_pc;
    when others => program_counter_in <= std_logic_vector(unsigned(program_counter_out) + 4);
    end case;
--	if branch_condition = '1' then
--        program_counter_in <= branch_pc;
--    else 
--  	    program_counter_in <= std_logic_vector(unsigned(program_counter_out) + 4);
--  	end if;
end process;
process (rst, clk) begin
    if rst = '0' then 
        instruction_flush <= '0';
    elsif rising_edge(clk) then 
        instruction_flush <= branch_condition;
    end if;
end process;
process (instruction_flush, instruction_signal) begin

    case instruction_flush is
    when '1' => instruction <= (others => '0');
    when others => instruction <= instruction_signal;
    end case;
    
--    if instruction_flush = '1' then
--        instruction <= (others => '0');
--    else 
--        instruction <= instruction_signal;
--    end if;
end process;
end Behavioral;