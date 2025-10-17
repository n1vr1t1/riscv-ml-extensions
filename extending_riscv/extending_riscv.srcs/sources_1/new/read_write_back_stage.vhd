
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_write_back_stage is
    Port (pc : in STD_LOGIC_VECTOR (31 downto 0);
         alu_forward: in STD_LOGIC_VECTOR (31 downto 0);
         opclass : in STD_LOGIC_VECTOR (4 downto 0);
         mem_out : in STD_LOGIC_VECTOR (31 downto 0);
         rd_in: in STD_LOGIC_VECTOR(4 DOWNTO 0);
         rd_out: out STD_LOGIC_VECTOR(4 DOWNTO 0);
         write_register_file : out std_logic;
         rd_value : out STD_LOGIC_VECTOR (31 downto 0));
end read_write_back_stage;

architecture Behavioral of read_write_back_stage is

signal mem_out_signal : std_logic_vector(31 downto 0);

begin
mem_out_signal<= mem_out; --check if data memory has a delay and check if redundant

process (pc, alu_forward, opclass, mem_out_signal, rd_in) begin
    rd_out <= rd_in; 
    if opclass = "00001" then --load 
	   write_register_file <= '1';
	   rd_value <= mem_out_signal;
	elsif opclass = "00100" then --operation
	   write_register_file <= '1';
	   rd_value <= alu_forward;
	elsif opclass = "10000" then --jump and link
	   write_register_file <= '1';
       rd_value <= pc;
	else --branch & store
	   write_register_file <= '0';
	   rd_value <= pc;
	end if;
end process; 
end Behavioral;