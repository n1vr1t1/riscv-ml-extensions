
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fpu is
  Port (clk: in std_logic;
        fp : in std_logic;
        opcode : in STD_LOGIC_VECTOR (1 downto 0);
        operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
        output : out STD_LOGIC_VECTOR (31 downto 0));
end fpu;

architecture Behavioral of fpu is
COMPONENT fp_add_sub
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_operation_tvalid : IN STD_LOGIC;
    s_axis_operation_tdata : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;
COMPONENT fp_mul
  PORT (
    aclk : IN STD_LOGIC;
    s_axis_a_tvalid : IN STD_LOGIC;
    s_axis_a_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    s_axis_b_tvalid : IN STD_LOGIC;
    s_axis_b_tdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    m_axis_result_tvalid : OUT STD_LOGIC;
    m_axis_result_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) 
  );
END COMPONENT;

signal add_sub_op1_tvalid : std_logic;
signal add_sub_op2_tvalid : std_logic;
signal add_sub_opcode : std_logic_vector(7 downto 0);
signal add_sub_operation_tvalid : std_logic;
signal add_sub_result_tvalid : std_logic;
signal add_sub_result : std_logic_vector(31 downto 0);

signal mul_op1_tvalid : std_logic;
signal mul_op2_tvalid : std_logic;
signal mul_result_tvalid : std_logic;
signal multiplication_result : std_logic_vector(31 downto 0);
begin

addition_subtraction : fp_add_sub
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid => add_sub_op1_tvalid,
    s_axis_a_tdata => operand_1,
    s_axis_b_tvalid => add_sub_op2_tvalid,
    s_axis_b_tdata => operand_2,
    s_axis_operation_tvalid => add_sub_operation_tvalid,
    s_axis_operation_tdata => add_sub_opcode,
    m_axis_result_tvalid => add_sub_result_tvalid,
    m_axis_result_tdata => add_sub_result
  );

multiplication : fp_mul
  PORT MAP (
    aclk => clk,
    s_axis_a_tvalid => mul_op1_tvalid,
    s_axis_a_tdata => operand_1,
    s_axis_b_tvalid => mul_op2_tvalid,
    s_axis_b_tdata => operand_2,
    m_axis_result_tvalid => mul_result_tvalid,
    m_axis_result_tdata => multiplication_result
  );

process (fp, opcode) begin
    if fp ='1' then
        if opcode = "00" then -- add
            add_sub_opcode <= "00000000";
            add_sub_op1_tvalid <= '1';
            add_sub_op2_tvalid <= '1';
            add_sub_operation_tvalid <= '1';
            mul_op1_tvalid <= '0';
            mul_op2_tvalid <= '0';
        elsif opcode ="01" then -- sub
            add_sub_opcode <= "00000001";
            add_sub_op1_tvalid <= '1';
            add_sub_op2_tvalid <= '1';
            add_sub_operation_tvalid <= '1';
            mul_op1_tvalid <= '0';
            mul_op2_tvalid <= '0';
        elsif opcode = "10" then -- mul
            add_sub_opcode <= "00000000";
            add_sub_op1_tvalid <= '0';
            add_sub_op2_tvalid <= '0';
            add_sub_operation_tvalid <= '0';
            mul_op1_tvalid <= '1';
            mul_op2_tvalid <= '1';
        else
            add_sub_opcode <= "00000000";
            add_sub_op1_tvalid <= '0';
            add_sub_op2_tvalid <= '0';
            add_sub_operation_tvalid <= '0';
            mul_op1_tvalid <= '0';
            mul_op2_tvalid <= '0';
        end if;
    else
        add_sub_opcode <= "00000000";
        add_sub_op1_tvalid <= '0';
        add_sub_op2_tvalid <= '0';
        add_sub_operation_tvalid <= '0';
        mul_op1_tvalid <= '0';
        mul_op2_tvalid <= '0';
    end if;
end process;

output <= add_sub_result when add_sub_result_tvalid = '1';
output <= multiplication_result when mul_result_tvalid = '1';

--add_sub_result_process : process (add_sub_result_tvalid) begin
--    if opcode = "00" or opcode = "01" then
--        if add_sub_result_tvalid = '1' then
--            output <= add_sub_result;
--            add_sub_op1_tvalid <= '0';
--            add_sub_op2_tvalid <= '0';
--            add_sub_operation_tvalid <= '0';
--        end if;
--    end if;
--end process;

--mul_result_process : process (mul_result_tvalid) begin
--    if opcode = "10" then
--        if mul_result_tvalid = '1' then
--            output <= multiplication_result;
--            mul_op1_tvalid <= '0';
--            mul_op2_tvalid <= '0';
--        end if;
--    end if;
--end process;


end Behavioral;