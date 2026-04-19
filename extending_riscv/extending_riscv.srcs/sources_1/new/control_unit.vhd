
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (rst : in std_logic;
        clk : in std_logic;  
        opclass : in std_logic_vector(4 downto 0);
        vec_en_if : in std_logic;
        vec_en_id : in std_logic;
        vec_en_ex : in std_logic;
    	-- signals for data hazards with consecutive operations
    	rs1_id : in std_logic_vector(4 downto 0);
    	rs2_id : in std_logic_vector(4 downto 0);
    	rs3_id : in std_logic_vector(4 downto 0);
    	rd_ex : in std_logic_vector(4 downto 0); --got from the output of the execution stage
    	con_data_hazard_1 : out std_logic;
    	con_data_hazard_2 : out std_logic;
    	con_data_hazard_3 : out std_logic;
        con_vd_hazard_1 : out std_logic;
        con_vd_hazard_2 : out std_logic;
        con_vd_hazard_3 : out std_logic;
		--signals for all types of data hazards
		rs1_if : in std_logic_vector(4 downto 0);
    	rs2_if : in std_logic_vector(4 downto 0);
    	rs3_if : in std_logic_vector(4 downto 0);
    	data_hazard_1 : out std_logic;
    	data_hazard_2 : out std_logic; 
    	data_hazard_3 : out std_logic;
        vec_data_hazard_1 : out std_logic;
        vec_data_hazard_2 : out std_logic;
        vec_data_hazard_3 : out std_logic;
		load_hazard_1 : out std_logic;
		load_hazard_2 : out std_logic;
		load_hazard_3 : out std_logic;
        vec_load_hazard_1 : out STD_LOGIC_VECTOR(3 downto 0);
        vec_load_hazard_2 : out STD_LOGIC_VECTOR(3 downto 0);
        vec_load_hazard_3 : out STD_LOGIC_VECTOR(3 downto 0);
        vd_element : in std_logic_vector(3 downto 0);
    	--signals for flushing
    	a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        branch_condition : in STD_LOGIC;
        flush : out STD_LOGIC);
end control_unit;

architecture Behavioral of control_unit is
signal nonvec_instructions : std_logic;
signal vec_instructions : std_logic;
begin
nonvec_instructions <= vec_en_if and vec_en_ex;
vec_instructions <= vec_en_id and vec_en_ex;

flushing: process (branch_condition, a_select, b_select) begin
	flush <= a_select and b_select and branch_condition;
end process;
--when hazards are 1 instruction apart ie. there is another instruction in between
nonconsecutive_data_forwarding : process (rst, clk) 
begin
    if rst = '0' then 
        data_hazard_1 <= '0';
        data_hazard_2 <= '0';
        data_hazard_3 <= '0';
        load_hazard_1 <= '0';
        load_hazard_2 <= '0';
        load_hazard_3 <= '0';
    elsif rising_edge (clk) then
        if rd_ex /= "00000" then
            if opclass = "00100" then --operation
                load_hazard_1 <= '0';
                load_hazard_2 <= '0';
                load_hazard_3 <= '0';
                vec_load_hazard_1 <= (others => '0');
                vec_load_hazard_2 <= (others => '0');
                vec_load_hazard_3 <= (others => '0');
                if rs1_if = rd_ex then 
                    if (nonvec_instructions = '1') then
                        vec_data_hazard_1 <= '1';
                        data_hazard_1 <= '0';
                    else
                        data_hazard_1 <= '1' ;
                        vec_data_hazard_1 <= '0';
                    end if;
                else
                    vec_data_hazard_1 <= '0';
                    data_hazard_1 <= '0';
                end if;
                if rs2_if = rd_ex then 
                   if (nonvec_instructions = '1') then
                        vec_data_hazard_2 <= '1';
                        data_hazard_2 <= '0';
                    else
                        data_hazard_2 <= '1' ;
                        vec_data_hazard_2 <= '0';
                    end if;
                else
                    data_hazard_2 <= '0';
                    vec_data_hazard_2 <= '0';
                end if; 
                if rs3_if = rd_ex then
                    if (nonvec_instructions = '1') then
                        vec_data_hazard_3 <= '1';
                        data_hazard_3 <= '0';
                    else
                        data_hazard_3 <= '1' ;
                        vec_data_hazard_3 <= '0';
                    end if;
                else
                    data_hazard_3 <= '0';
                    vec_data_hazard_3 <= '0';
                end if;
            elsif opclass = "00001" then --load
                data_hazard_1 <= '0';
                data_hazard_2 <= '0';
                data_hazard_3 <= '0';
                vec_data_hazard_1 <= '0';
                vec_data_hazard_2 <= '0';
                vec_data_hazard_3 <= '0';
                if rs1_if = rd_ex then 
                    if (nonvec_instructions = '1') then
                        vec_load_hazard_1 <= vd_element;
                        load_hazard_1 <= '0';
                    else
                        load_hazard_1 <= '1' ;
                        vec_load_hazard_1 <= (others => '0');
                    end if;
                else
                    load_hazard_1 <= '0';
                    vec_load_hazard_1 <= (others => '0');
                end if;
                if rs2_if = rd_ex then 
                    if (nonvec_instructions = '1') then
                        vec_load_hazard_2 <= vd_element;
                        load_hazard_2 <= '0';
                    else
                        load_hazard_2 <= '1' ;
                        vec_load_hazard_2 <= (others => '0');
                    end if;
                else
                    load_hazard_2 <= '0';
                    vec_load_hazard_2 <= (others => '0');
                end if;
                if rs3_if = rd_ex then 
                    if (nonvec_instructions = '1') then
                        vec_load_hazard_3 <= vd_element;
                        load_hazard_3 <= '0';
                    else
                        load_hazard_3 <= '1' ;
                        vec_load_hazard_3 <= (others => '0');
                    end if;
                else
                    load_hazard_3 <= '0';
                    vec_load_hazard_3 <= (others => '0');
                end if;
            else --when the opcode is not operation or load
                data_hazard_1 <= '0';
                data_hazard_2 <= '0';
                data_hazard_3 <= '0';
                load_hazard_1 <= '0';
                load_hazard_2 <= '0';
                load_hazard_3 <= '0';
                vec_data_hazard_1 <= '0';
                vec_data_hazard_2 <= '0';
                vec_data_hazard_3 <= '0';
                vec_load_hazard_1 <= (others => '0');
                vec_load_hazard_2 <= (others => '0');
                vec_load_hazard_3 <= (others => '0');
            end if;   
        else --when rd_ex = "00000" 
            data_hazard_1 <= '0';
            data_hazard_2 <= '0';
            data_hazard_3 <= '0';
            load_hazard_1 <= '0';
            load_hazard_2 <= '0';
            load_hazard_3 <= '0';
            vec_data_hazard_1 <= '0';
            vec_data_hazard_2 <= '0';
            vec_data_hazard_3 <= '0';
            vec_load_hazard_1 <= (others => '0');
            vec_load_hazard_2 <= (others => '0');
            vec_load_hazard_3 <= (others => '0');

        end if;
    --no else
    end if;
end process;
data_fowarding_operation : process (rst, rs1_id, rs2_id, rs3_id, rd_ex, opclass, vec_instructions) 
begin
    if rst = '0' then 
        con_data_hazard_1 <= '0';
        con_data_hazard_2 <= '0';
        con_data_hazard_3 <= '0';
        con_vd_hazard_1 <= '0';
        con_vd_hazard_2 <= '0';
        con_vd_hazard_3 <= '0';
    else
        if rd_ex /= "00000" then
            if opclass = "00100" then
                if rs1_id = rd_ex then 
                    if (vec_instructions = '1') then
                        con_vd_hazard_1 <= '1';
                        con_data_hazard_1 <= '0';
                    else
                        con_vd_hazard_1 <= '0';
                        con_data_hazard_1 <= '1';
                    end if;
                else 
                    con_vd_hazard_1 <= '0';
                    con_data_hazard_1 <= '0';
                end if;
                if rs2_id = rd_ex then
                    if (vec_instructions = '1') then
                        con_vd_hazard_2 <= '1';
                        con_data_hazard_2 <= '0';
                    else
                        con_vd_hazard_2 <= '0';
                        con_data_hazard_2 <= '1';
                    end if;
                else 
                    con_vd_hazard_2 <= '0';
                    con_data_hazard_2 <= '0';
                end if;
                if rs3_id = rd_ex then
                    if (vec_instructions = '1') then
                        con_vd_hazard_3 <= '1';
                        con_data_hazard_3 <= '0';
                    else
                        con_vd_hazard_3 <= '0';
                        con_data_hazard_3 <= '1';
                    end if;
                else 
                    con_vd_hazard_3 <= '0';
                    con_data_hazard_3 <= '0';
                end if;
            else 
                con_data_hazard_1 <= '0';
                con_data_hazard_2 <= '0';
                con_data_hazard_3 <= '0';
                con_vd_hazard_1 <= '0';
                con_vd_hazard_2 <= '0';
                con_vd_hazard_3 <= '0';
            end if;
        else 
            con_data_hazard_1 <= '0';
            con_data_hazard_2 <= '0';
            con_data_hazard_3 <= '0';
            con_vd_hazard_1 <= '0';
            con_vd_hazard_2 <= '0';
            con_vd_hazard_3 <= '0';
        end if;
    end if;
end process;
end Behavioral;