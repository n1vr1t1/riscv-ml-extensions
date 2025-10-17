library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity execution_stage is
    Port(clk :  in std_logic;
        rst :  in std_logic;
        stall :  in std_logic;
        value_1 : in STD_LOGIC_VECTOR (31 downto 0);
        value_2 : in STD_LOGIC_VECTOR (31 downto 0); --used in data memory
        conditional_opcode : in STD_LOGIC_VECTOR (2 downto 0);
        a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        immediate : in STD_LOGIC_VECTOR (31 downto 0);
        alu_opcode : in STD_LOGIC_VECTOR (2 downto 0);
        alu_output : out STD_LOGIC_VECTOR (31 downto 0);
        branch_condition : out STD_LOGIC;
        -- signals needed to be forwarded to the next stage
        pc : in STD_LOGIC_VECTOR (31 downto 0);
        d_in :  in STD_LOGIC_VECTOR(4 downto 0);
        pc_out :  out STD_LOGIC_VECTOR (31 downto 0);
        d_out :  out STD_LOGIC_VECTOR(4 downto 0);
        a_select_forward : out std_logic;
        b_select_forward : out std_logic;
        opclass_in : in STD_LOGIC_VECTOR (4 downto 0); --for the data memory
        opclass_out : out STD_LOGIC_VECTOR (4 downto 0);
        value_1_forward : out STD_LOGIC_VECTOR (31 downto 0);
        value_2_forward : out STD_LOGIC_VECTOR (15 downto 0);
        --signals for load hazard control signal to the multiplexer (mem_in from  mem_out and load_hazard from control unit)
        a2_select : in STD_LOGIC;
        b2_select : in STD_LOGIC;
        memory_value : in STD_LOGIC_VECTOR (31 downto 0));
end execution_stage;

architecture Behavioral of execution_stage is
    component comparator is
        Port (value_1 : in STD_LOGIC_VECTOR (31 downto 0);
              value_2 : in STD_LOGIC_VECTOR (31 downto 0);
              cond_opcode : in STD_LOGIC_VECTOR (2 downto 0);
              branch_condition : out STD_LOGIC);
    end component;
    component alu is
        Port (alu_opcode : in STD_LOGIC_VECTOR (2 downto 0);
              operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
              operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
              alu_output : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal branch_condition_signal : std_logic;
signal operand_signal_1, operand_signal_2 : std_logic_vector(31 downto 0);
signal alu_opcode_signal : STD_LOGIC_VECTOR (2 downto 0);
signal conditional_opcode_signal : STD_LOGIC_VECTOR (2 downto 0);
signal load_value_1 : std_logic_vector(31 downto 0);
signal load_value_2 : std_logic_vector(31 downto 0);
begin
    alu_exe : alu
        Port map(alu_opcode  => alu_opcode_signal,
                operand_1  => operand_signal_1,
                operand_2  => operand_signal_2,
                alu_output => alu_output);
    comp_exe : comparator
        Port map(value_1 => load_value_1,
                value_2  => load_value_2,
                cond_opcode  => conditional_opcode_signal,
                branch_condition  => branch_condition_signal);

branch_condition <= branch_condition_signal;

process (rst, clk) begin --might need to put stall(1% chance)
	if rst = '0' then
	   alu_opcode_signal <= (others => '0');
	   conditional_opcode_signal <= (others => '0');
		pc_out <= (others => '0');
		value_1_forward <= (others => '0');
		value_2_forward <= (others => '0');
		d_out <= (others => '0');
		opclass_out <= (others => '0');
		operand_signal_1 <= (others => '0');
		operand_signal_2 <= (others => '0');
		a_select_forward <= '0';
        b_select_forward <= '0';
        load_value_1 <= (others => '0');
        load_value_2 <= (others => '0');
    elsif rising_edge(clk) then
        if stall ='0' then
            a_select_forward <= a_select;
            b_select_forward <= b_select;
            alu_opcode_signal <= alu_opcode;
            conditional_opcode_signal <= conditional_opcode;
            pc_out <= pc;
            value_1_forward <= value_1;
            value_2_forward <= value_2(15 downto 0);
            d_out <= d_in;
            opclass_out <= opclass_in;
            if a2_select = '1' then  --load hazard
                load_value_1 <= memory_value;
            else
                load_value_1 <= value_1;
            end if;
            if b2_select = '1' then --load hazard
                load_value_2 <= memory_value;
            else 
                load_value_2 <= value_2;
            end if;
            if a_select = '1' then
                operand_signal_1 <= pc;
            elsif a2_select = '1' then 
                operand_signal_1 <= memory_value;
            else operand_signal_1 <= value_1;
            end if;
            if b_select='1' then
                    operand_signal_2 <= immediate;
            elsif b2_select = '1' then 
                operand_signal_2 <= memory_value;   
            else   operand_signal_2 <= value_2;
            end if;
	    else
	       alu_opcode_signal <= (others => '0');
           conditional_opcode_signal <= (others => '0');
           pc_out <= (others => '0');
           value_1_forward <= (others => '0');
           value_2_forward <= (others => '0');
           d_out <= (others => '0');
           opclass_out <= (others => '0');
           operand_signal_1 <= (others => '0');
           operand_signal_2 <= (others => '0');
           a_select_forward <= '0';
           b_select_forward <= '0';
           load_value_1 <= (others => '0');
           load_value_2 <= (others => '0');
        end if;
	end if;
end process;
end Behavioral;