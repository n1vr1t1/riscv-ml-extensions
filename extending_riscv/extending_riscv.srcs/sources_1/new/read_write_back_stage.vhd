-------------------------------------------------------------------
-- notes: 
-- 1.
-------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity read_write_back_stage is
    Port (pc : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_1 : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_2 : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_3 : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward_4 : in STD_LOGIC_VECTOR (31 downto 0);
        opclass : in STD_LOGIC_VECTOR (4 downto 0);
        mem_out : in STD_LOGIC_VECTOR (31 downto 0);
        rd_in: in STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_out: out STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_vec_i : in std_logic;
        write_vec_o : out std_logic;
        vdata : out std_logic_vector ( 127 downto 0 );
        vc_elem_i : in std_logic_vector ( 3 downto 0 );
        vc_elem_o : out std_logic_vector ( 3 downto 0 );  
        write_register_file : out std_logic;
        rd_value : out STD_LOGIC_VECTOR (31 downto 0));
end read_write_back_stage;

architecture Behavioral of read_write_back_stage is

begin
process (pc, alu_forward_1, alu_forward_2, alu_forward_3, alu_forward_4, opclass, mem_out,
        rd_in, write_vec_i, vc_elem_i) begin
    rd_out <= rd_in;
    write_vec_o <= write_vec_i;
    vc_elem_o <= (others => '1');
    case opclass is
        when "00001" => --load        
            vdata(31 downto 0) <= mem_out;
            vdata(127 downto 32) <= (others => '0');
            vc_elem_o <= vc_elem_i;
            write_register_file <= not (write_vec_i);
            rd_value <= mem_out;
        when "00100" => --operation
	       write_register_file <= not (write_vec_i);
           vdata(31 downto 0) <= alu_forward_1;
           vdata(63 downto 32) <= alu_forward_2;
           vdata(95 downto 64) <= alu_forward_3;
           vdata(127 downto 96) <= alu_forward_4;
           rd_value <= alu_forward_1;
        when "10000" => --jump and link
	       write_register_file <= '1';
           write_vec_o <= write_vec_i;
           vdata(127 downto 0) <= (others => '0');
           rd_value <= pc;
        when others => -- branch & store
            vdata(127 downto 0) <= (others => '0');        
            write_register_file <= '0';
            rd_value <= pc;
    end case;
end process; 
end Behavioral;