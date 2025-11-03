library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity execution_stage is
    Port(clk :  in std_logic;
        rst :  in std_logic;
        flush :  in std_logic;
        value_1 : in STD_LOGIC_VECTOR (31 downto 0);
        value_2 : in STD_LOGIC_VECTOR (31 downto 0); -- used in data memory
        value_3 : in STD_LOGIC_VECTOR (31 downto 0); -- used only for mlu
        conditional_opcode : in STD_LOGIC_VECTOR (2 downto 0);
        alu_opcode : in STD_LOGIC_VECTOR (3 downto 0);
        ml_opcode : in std_logic;
        a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        immediate : in STD_LOGIC_VECTOR (31 downto 0);
        is_float : in std_logic;
        is_ml : in std_logic;
        float_forward : out std_logic;
        ml_forward : out std_logic;
        fpu_output : out STD_LOGIC_VECTOR (31 downto 0);
        alu_output : out STD_LOGIC_VECTOR (31 downto 0);
        mlu_output : out STD_LOGIC_VECTOR (31 downto 0);
        branch_condition : out STD_LOGIC;
        pc : in STD_LOGIC_VECTOR (31 downto 0);
        d_in :  in STD_LOGIC_VECTOR(4 downto 0);
        pc_out :  out STD_LOGIC_VECTOR (31 downto 0);
        d_out :  out STD_LOGIC_VECTOR(4 downto 0);
        a_select_forward : out std_logic;
        b_select_forward : out std_logic;
        opclass_in : in STD_LOGIC_VECTOR (4 downto 0);
        opclass_out : out STD_LOGIC_VECTOR (4 downto 0);
        value_1_forward : out STD_LOGIC_VECTOR (31 downto 0);
        value_2_forward : out STD_LOGIC_VECTOR (15 downto 0);
        a2_select : in STD_LOGIC;
        b2_select : in STD_LOGIC;
        c_select : in std_logic;
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
        Port (alu_opcode : in STD_LOGIC_VECTOR (3 downto 0);
          operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
          operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
          alu_output : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component fpu is
        Port (fp : in std_logic;
            opcode : in STD_LOGIC_VECTOR (1 downto 0);
            operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
            output : out STD_LOGIC_VECTOR (31 downto 0));
    end component;
    component mlu is
      Port (ml : in std_logic;
            fp : in std_logic;
            opcode : in std_logic;
            operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
            operand_3 : in STD_LOGIC_VECTOR (31 downto 0);
            output : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

signal branch_condition_signal, is_float_signal, is_ml_signal : std_logic;
signal operand_signal_1, operand_signal_2, operand_signal_3 : std_logic_vector(31 downto 0);
signal conditional_opcode_signal : STD_LOGIC_VECTOR (2 downto 0);
signal alu_opcode_signal : STD_LOGIC_VECTOR (3 downto 0);
signal ml_opcode_signal : STD_LOGIC;
signal load_value_1, load_value_2 : std_logic_vector(31 downto 0);

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
    fpu_exe : fpu
        Port map(fp => is_float_signal, 
                opcode => alu_opcode_signal(1 downto 0), 
                operand_1 => operand_signal_1, 
                operand_2 => operand_signal_2, 
                output => fpu_output);
    mlu_exe : mlu
        Port map(ml => is_ml_signal,
                fp => is_float_signal,
                opcode => ml_opcode_signal,
                operand_1 => operand_signal_1,
                operand_2 => operand_signal_2,
                operand_3 => operand_signal_3,
                output => mlu_output);

branch_condition <= branch_condition_signal;
float_forward <= is_float_signal;
ml_forward <= is_ml_signal;

process (rst, clk) begin
	if rst = '0' then
	    alu_opcode_signal <= (others => '0');
	    is_float_signal <= '0';
	    is_ml_signal <= '0';
	    ml_opcode_signal <= '0';
	    conditional_opcode_signal <= (others => '0');
        pc_out <= (others => '0');
		value_1_forward <= (others => '0');
		value_2_forward <= (others => '0');
		d_out <= (others => '0');
		opclass_out <= (others => '0');
		operand_signal_1 <= (others => '0');
		operand_signal_2 <= (others => '0');
		operand_signal_3 <= (others => '0');
		a_select_forward <= '0';
        b_select_forward <= '0';
        load_value_1 <= (others => '0');
        load_value_2 <= (others => '0');
    elsif rising_edge(clk) then
        if flush ='0' then
            a_select_forward <= a_select;
            b_select_forward <= b_select;
            alu_opcode_signal <= alu_opcode;
            is_float_signal <= is_float;
	        is_ml_signal <= is_ml;
	        ml_opcode_signal <= ml_opcode;
            conditional_opcode_signal <= conditional_opcode;
            pc_out <= pc;
            value_1_forward <= value_1;
            value_2_forward <= value_2( 15 downto 0 );
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
            if b_select = '1' then
                operand_signal_2 <= immediate;
            elsif b2_select = '1' then 
                operand_signal_2 <= memory_value;   
            else   operand_signal_2 <= value_2;
            end if;
            if c_select = '1' then
                operand_signal_3 <= memory_value;
            else
                operand_signal_3 <= value_3;
            end if;
	    else
	       alu_opcode_signal <= (others => '0');
	       is_float_signal <= '0';
	       is_ml_signal <= '0';
	       ml_opcode_signal <= '0';
           conditional_opcode_signal <= (others => '0');
           pc_out <= (others => '0');
           value_1_forward <= (others => '0');
           value_2_forward <= (others => '0');
           d_out <= (others => '0');
           opclass_out <= (others => '0');
           operand_signal_1 <= (others => '0');
           operand_signal_2 <= (others => '0');
           operand_signal_3 <= (others => '0');
           a_select_forward <= '0';
           b_select_forward <= '0';
           load_value_1 <= (others => '0');
           load_value_2 <= (others => '0');
        end if;
	end if;
end process;
end Behavioral;