
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    Port (rst : in std_logic;
        clk : in std_logic;  
        opclass : in std_logic_vector(4 downto 0);
    	-- signals for data hazards with consecutive operations
    	data_source1 : in std_logic_vector(4 downto 0);
    	data_source2 : in std_logic_vector(4 downto 0);
    	data_source3 : in std_logic_vector(4 downto 0);
    	data_destination : in std_logic_vector(4 downto 0); --got from the output of the execution stage
    	con_data_hazard_1 : out std_logic;
    	con_data_hazard_2 : out std_logic;
    	con_data_hazard_3 : out std_logic;
		--signals for all types of data hazards
		source1 : in std_logic_vector(4 downto 0);
    	source2 : in std_logic_vector(4 downto 0);
    	source3 : in std_logic_vector(4 downto 0);
    	destination : in std_logic_vector(4 downto 0); -- got from the input of the write back
    	data_hazard_1 : out std_logic;
    	data_hazard_2 : out std_logic; 
    	data_hazard_3 : out std_logic;
		load_hazard_1 : out std_logic;
		load_hazard_2 : out std_logic;
		load_hazard_3 : out std_logic;
    	--signals for flushing
    	a_select : in STD_LOGIC;
        b_select : in STD_LOGIC;
        branch_condition : in STD_LOGIC;
        flush : out STD_LOGIC);
end control_unit;

architecture Behavioral of control_unit is

begin

flushing: process (branch_condition, a_select, b_select) begin --see if it needs to depend on the clock
	flush <= a_select and b_select and branch_condition;
end process;
--when hazards are 1 instruction apart ie. there is another instruction in between
nonconsecutive_data_forwardind : process (rst, clk) begin
    if rst = '0' then 
        data_hazard_1 <= '0';
        data_hazard_2 <= '0';
        data_hazard_3 <= '0';
        load_hazard_1 <= '0';
        load_hazard_2 <= '0';
        load_hazard_3 <= '0';
    elsif rising_edge (clk) then
        if destination /= "00000" then
            if opclass = "00100" then --operation
                load_hazard_1 <= '0';
                load_hazard_2 <= '0';
                load_hazard_3 <= '0';
                if source1 = destination then 
                    data_hazard_1 <= '1' ;
                else
                    data_hazard_1 <= '0';
                end if;
                if source2 = destination then 
                    data_hazard_2 <= '1' ;
                else
                    data_hazard_2 <= '0';
                end if; 
                if source3 = destination then
                    data_hazard_3 <= '1' ;
                else
                    data_hazard_3 <= '0';
                end if;
            elsif opclass = "00001" then --load
                data_hazard_1 <= '0';
                data_hazard_2 <= '0';
                data_hazard_3 <= '0';
                if source1 = destination then 
                    load_hazard_1 <= '1' ;
                else
                    load_hazard_1 <= '0';
                end if;
                if source2 = destination then 
                    load_hazard_2 <= '1' ;
                else
                    load_hazard_2 <= '0';
                end if;
                if source3 = destination then 
                    load_hazard_3 <= '1' ;
                else
                    load_hazard_3 <= '0';
                end if;
            else --when the opcode is not operation or 
                data_hazard_1 <= '0';
                data_hazard_2 <= '0';
                data_hazard_3 <= '0';
                load_hazard_1 <= '0';
                load_hazard_2 <= '0';
                load_hazard_3 <= '0';
            end if;   
        else --when destination = "00000" 
            data_hazard_1 <= '0';
            data_hazard_2 <= '0';
            data_hazard_3 <= '0';
            load_hazard_1 <= '0';
            load_hazard_2 <= '0';
            load_hazard_3 <= '0';
        end if;
    --no else
    end if;
end process;
data_fowarding_operation : process (data_source1, data_source2, data_source3, data_destination, opclass) begin
    if data_destination /= "00000" then
        if opclass = "00100" then
            if data_source1 = data_destination then 
                con_data_hazard_1 <= '1';
            else 
                con_data_hazard_1 <= '0';
            end if;
            if data_source2 = data_destination then
                con_data_hazard_2 <= '1';
            else 
               con_data_hazard_2 <= '0';
            end if;
            if data_source3 = data_destination then
                con_data_hazard_3 <= '1';
            else 
               con_data_hazard_3 <= '0';
            end if;
        else 
            con_data_hazard_1 <= '0';
            con_data_hazard_2 <= '0';
            con_data_hazard_3 <= '0';
        end if;
    else 
        con_data_hazard_1 <= '0';
        con_data_hazard_2 <= '0';
        con_data_hazard_3 <= '0';
	end if;
end process;
end Behavioral;