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
        vec_wen_in : in std_logic;
        vec_wen_out : out std_logic;
        vdata : out std_logic_vector ( 127 downto 0 );
        vc_elem_i : in std_logic_vector ( 3 downto 0 );
        vc_elem_o : out std_logic_vector ( 3 downto 0 );  
        write_register_file : out std_logic;
        rd_value : out STD_LOGIC_VECTOR (31 downto 0));
end read_write_back_stage;

architecture Behavioral of read_write_back_stage is

begin
rd_out <= rd_in;
vec_wen_out <= vec_wen_in;
    process (vc_elem_i, opclass) begin
        case opclass is
            when "00001" => -- load
                vc_elem_o <= vc_elem_i;
            when "00100" => -- operation
                vc_elem_o <= (others => '1');
            when others =>
                vc_elem_o <= (others => '0');
        end case;
    end process;
    process (opclass, mem_out, alu_forward_1, alu_forward_2, alu_forward_3, alu_forward_4) begin
        case opclass is
            when "00001" => -- load
                vdata(31 downto 0) <= mem_out;
                vdata(63 downto 32) <= mem_out;
                vdata(95 downto 64) <= mem_out;
                vdata(127 downto 96) <= mem_out;
            when others => -- operation
                vdata(31 downto 0) <= alu_forward_1;
                vdata(63 downto 32) <= alu_forward_2;
                vdata(95 downto 64) <= alu_forward_3;
                vdata(127 downto 96) <= alu_forward_4;
        end case;
    end process;
    process (opclass, mem_out, alu_forward_1, pc, vec_wen_in) begin
        case opclass is
            when "00001" => -- load
                write_register_file <= not (vec_wen_in);
                rd_value <= mem_out;
            when "00100" => -- operation
                write_register_file <= not (vec_wen_in);
                rd_value <= alu_forward_1;
            when "10000" => -- jump and link
                write_register_file <= '1';
                rd_value <= pc;
            when others => -- branch & store
                write_register_file <= '0';
                rd_value <= pc;
    end case;
end process; 
end Behavioral;