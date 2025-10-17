
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_tb is
--  Port ( );
end alu_tb;

architecture Behavioral of alu_tb is

component alu is 
    Port (alu_opcode : in STD_LOGIC_VECTOR (3 downto 0);
          operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
          operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
          alu_output : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal alu_opcode : STD_LOGIC_VECTOR (3 downto 0);
signal operand_1 : STD_LOGIC_VECTOR (31 downto 0);
signal operand_2 : STD_LOGIC_VECTOR (31 downto 0);
signal alu_output : STD_LOGIC_VECTOR (31 downto 0);


begin

dut : alu
Port map( alu_opcode => alu_opcode,
          operand_1 => operand_1,
          operand_2 => operand_2,
          alu_output => alu_output
); 

process begin

    wait for 10 ps;
    alu_opcode <= "0000"; -- add
    operand_1 <= "00101110011100111110001011111111";
    operand_2 <= "00111100011101100001010110110010";

    wait for 10 ps;
    alu_opcode <= "0000"; -- add
    operand_1 <= "00000000000011110001001001010100";
    operand_2 <= "10111100011101100001010110110010";

    wait for 10 ps;
    alu_opcode <= "0001"; -- sub

    wait for 10 ps;
    operand_1 <= "00101110011100111110001011111111";
    operand_2 <= "00111100011101100001010110110010";

    wait for 10 ps;
    alu_opcode <= "0010"; -- mul
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    alu_opcode <= "0011"; -- or

    wait for 10 ps;
    operand_1 <= "10101110011100111110001011111111";
    operand_2 <= "00111100011101100001010110110010";

    wait for 10 ps;
    alu_opcode <= "0100"; -- and

    wait for 10 ps;
    operand_1 <= "10101110011100111110001011111111";
    operand_2 <= "00111100011101100001010110110010";

    wait for 10 ps;
    alu_opcode <= "0101"; -- xor

    wait for 10 ps;
    operand_1 <= "00101110011100111110001011111111";
    operand_2 <= "00111100011101100001010110110010";

    wait for 10 ps;
    alu_opcode <= "0110";  -- div

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5
    
    wait for 10 ps;
    operand_1 <= "11111111111111111111111111110110"; -- -10
    operand_2 <= "11111111111111111111111111111011"; -- -5
    
    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "11111111111111111111111111111011"; -- -5
    
    wait for 10 ps;
    operand_1 <= "11111111111111111111111111110110"; -- -10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    alu_opcode <= "0111"; -- slt

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000001010"; -- 10

    wait for 10 ps;
	alu_opcode <= "1000"; -- sle

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    operand_1 <= "11111111111111111111111111110110"; -- -10
    operand_2 <= "11111111111111111111111111111011"; -- -5

    wait for 10 ps;
    alu_opcode <= "1001" ; -- sgt

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000001010"; -- 10
    
    wait for 10 ps;
    alu_opcode <= "1010"; -- sge

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    operand_1 <= "11111111111111111111111111110110"; -- -10
    operand_2 <= "11111111111111111111111111111011"; -- -5
    
    wait for 10 ps;
    alu_opcode <= "1011";  -- se

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000001010"; -- 10
    
    wait for 10 ps;
    alu_opcode <= "1100"; -- lui
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "01111110111011110110000000000000";

    wait for 10 ps;
    alu_opcode <= "1101"; -- sll
    operand_1 <= "00000000000000000000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    operand_2 <= "00000000000000000000000000001010"; -- 10
    
    wait for 10 ps;
    alu_opcode <= "1110"; -- srl
    operand_1 <= "00000000000011100000000000001010"; -- 10
    operand_2 <= "00000000000000000000000000000101"; -- 5

    wait for 10 ps;
    alu_opcode <= "1111"; -- invalid opcode
    wait;
end process;


end Behavioral;
