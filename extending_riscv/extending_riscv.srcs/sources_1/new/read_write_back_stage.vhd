
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity read_write_back_stage is
    Port (pc : in STD_LOGIC_VECTOR (31 downto 0);
        alu_forward: in STD_LOGIC_VECTOR (31 downto 0);
        fpu_forward : in STD_LOGIC_VECTOR (31 downto 0);
        is_float : in std_logic;
        is_ml : in std_logic;
        mlu_forward : in STD_LOGIC_VECTOR (31 downto 0);
        opclass : in STD_LOGIC_VECTOR (4 downto 0);
        mem_out : in STD_LOGIC_VECTOR (31 downto 0);
        rd_in: in STD_LOGIC_VECTOR(4 DOWNTO 0);
        rd_out: out STD_LOGIC_VECTOR(4 DOWNTO 0);
        write_register_file : out std_logic;
        rd_value : out STD_LOGIC_VECTOR (31 downto 0));
end read_write_back_stage;

architecture Behavioral of read_write_back_stage is

begin
process (is_ml, is_float, pc, alu_forward, opclass, 
            mem_out, rd_in, fpu_forward, mlu_forward) begin
    rd_out <= rd_in; 
    case opclass is
        when "00001" => --load 
            write_register_file <= '1';
            rd_value <= mem_out;
        when "00100" => --operation
	       write_register_file <= '1';
           if is_ml = '1' then
               rd_value <= mlu_forward;
           elsif is_float = '1' then
               rd_value <= fpu_forward;
           else rd_value <= alu_forward;
           end if;
        when "10000" => --jump and link
	       write_register_file <= '1';
           rd_value <= pc;
        when others => -- branch & store
            write_register_file <= '0';
            rd_value <= pc;
    end case;
--    if opclass = "00001" then --load 
--	   write_register_file <= '1';
--	   rd_value <= mem_out;
--	elsif opclass = "00100" then --operation
--	   write_register_file <= '1';
--	   if is_ml = '1' then
--	       rd_value <= mlu_forward;
--	   elsif is_float = '1' then
--	       rd_value <= fpu_forward;
--	   else rd_value <= alu_forward;
--	   end if;
--	elsif opclass = "10000" then --jump and link
--	   write_register_file <= '1';
--       rd_value <= pc;
--	else --branch & store
--	   write_register_file <= '0';
--	   rd_value <= pc;
--	end if;
end process; 
end Behavioral;