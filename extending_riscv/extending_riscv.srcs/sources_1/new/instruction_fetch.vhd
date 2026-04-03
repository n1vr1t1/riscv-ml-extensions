library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instruction_fetch_stage is
    Port( clk : in STD_LOGIC;
          rst: in STD_LOGIC;
          branch_condition: in std_logic; -- active high
          branch_pc: in STD_LOGIC_VECTOR( 11 downto 0 );
          pc_out : out STD_LOGIC_VECTOR( 31 downto 0 );
          instruction : out STD_LOGIC_VECTOR( 31 downto 0 ));
end instruction_fetch_stage;

architecture Behavioral of instruction_fetch_stage is

signal next_pc : std_logic_vector( 11 downto 0 ); -- input of the program counter amd sign ext
signal curr_pc : std_logic_vector( 11 downto 0 ); -- pc to instr mem
signal instruction_signal : STD_LOGIC_VECTOR( 31 downto 0 ); -- output of the instruction memory

COMPONENT instruction_memory IS
  PORT( clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR( 0 DOWNTO 0 );
        addra : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        dina : IN STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        douta : OUT STD_LOGIC_VECTOR( 31 DOWNTO 0 ));
END COMPONENT;
 component program_counter is
      Port( pc : in STD_LOGIC_VECTOR (11 downto 0);
            branch_pc : in STD_LOGIC_VECTOR (11 downto 0);
            branch_condition : in std_logic;
            clk: in std_logic;
            pc_out : out STD_LOGIC_VECTOR (11 downto 0);
            rst: in std_logic);
end component;
  component sign_extention_pc is
      Port( clk: in std_logic;
            rst : in std_logic;
            flush : in std_logic;
            pc : in STD_LOGIC_VECTOR( 11 downto 0 );
            extended_pc : out STD_LOGIC_VECTOR( 31 downto 0 ));
  end component;

begin
ifs_pc :program_counter
    Port map( pc => next_pc,
    		pc_out => curr_pc,
    		branch_pc => branch_pc,
            branch_condition => branch_condition,
		    clk => clk,
        	rst => rst );
        	
ifs_mem : instruction_memory
    PORT MAP( clka => clk,
            wea(0) => '0' ,
            addra => std_logic_vector( curr_pc( 11 downto 2 )) ,
            dina => "00000000000000000000000000000000" ,
            douta => instruction_signal );

pc_sign_extension: sign_extention_pc
    Port map( flush => branch_condition,
            rst => rst,
            clk => clk,
            pc => next_pc,
            extended_pc => pc_out );

next_pc <= std_logic_vector( unsigned( curr_pc ) + 4 );

process ( clk ) begin
    if rising_edge( clk ) then 
        if branch_condition = '1' then
            instruction <= ( others => '0' );
        else
            instruction <= instruction_signal;
        end if;
    end if;
end process;
end Behavioral;
