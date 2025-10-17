-------------------------------------------------
-- add a new block for comparasions (that gives out 1 if the condition is true, else 0). 
-- The alu gives back the value that satisfies the condition
-- add if block for immediate operations

-- Notes: 
-- 1. For flw and fsw, the float bit is not activated because we are writing to the normal register file 
--    and the address is an int so fp operation is needed
-- 2. Stall can be uncommented if we are implementing it for any reason
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    Port (rst : in std_logic;
--        stall : in std_logic;
        clk : in std_logic;
    	flush : in std_logic; --active low
    	op_code : in std_logic_vector(6 downto 0);
		funct7 : in std_logic_vector(6 downto 0);
		funct3 : in std_logic_vector(2 downto 0);
        op_class : out STD_LOGIC_VECTOR (4 downto 0);
        alu_opcode : out STD_LOGIC_VECTOR (3 downto 0);
        a_select : out STD_LOGIC;
        b_select : out STD_LOGIC;
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
        f_op : out std_logic; -- indicates that the operation using the fpu
        ml_op : out std_logic; -- indicates that the mlu is needed
        ml_opcode : out std_logic); -- opcode for the mlu to indicate whic operation needs to be performed
end decoder;

architecture Behavioral of decoder is
begin
process (rst, clk) begin
	if rst = '0' then 
		op_class <= (others => '0');
		alu_opcode  <= (others => '0');
		a_select <= '0';
		b_select <= '0'; 
		f_op <= '0';
        ml_op <= '0';
        ml_opcode <= '0';
		conditional_opcode  <= (others => '1');
--	elsif rising_edge(clk) and stall = '0' then
    elsif rising_edge(clk) then 
	   if flush = '1' then
            op_class <= (others => '0');
			alu_opcode  <= (others => '1');
			a_select <= '0';
			b_select <= '0'; 
			f_op <= '0';
            ml_op <= '0';
            ml_opcode <= '0';
			conditional_opcode  <= (others => '1');
	   else --flush, (stall) and rst not enabled
			conditional_opcode <= "111"; --default for when we dont have a branch instruction
			if op_code = "0000011" or op_code = "0100111" then -- load for int and floats
				op_class <= "00001";
				alu_opcode <= "0000"; -- add
				a_select <= '0';
				b_select <= '1';
				f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
				--funct3 <= "000"; --by default because we dont check if the instruction is b,w,q
				
			elsif  op_code="0100011" or op_code = "0000111" then --store for ints and floats
				op_class <= "00010";
				alu_opcode <= "0000"; -- add
				a_select <= '0';
				b_select <= '1';
				f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
				
			elsif op_code = "0010011" then --immediate
				alu_opcode <= "0000"; -- needs to be changed to have operations with immediates
				op_class <= "00100" ; 
				a_select <= '0';
				b_select <= '1';
				f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
				
			elsif op_code = "0110011" then --operation
				op_class <= "00100";
				a_select <= '0';
				b_select <= '0';
				f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
				if funct3 = "000" then
				    if funct7 = "0000000" then
						alu_opcode <= "0000"; --add
					elsif funct7 = "0100000" then
						alu_opcode <= "0001"; --sub
					elsif funct7 = "0000001" then 
						alu_opcode <= "0010"; --mul
					else
						alu_opcode <= "1111"; -- invalid operation
					end if;  --end if for funct7
				elsif funct3 = "001" then
				    if funct7 = "0000000" then -- sll
						alu_opcode <= "1101";
					else 
					   alu_opcode <= "1111"; -- invalid operation
					end if;  --end if for funct7
				elsif funct3 = "010" then -- set less than (slt) -- moveed to a different opcode
				    if funct7 = "0000000" then -- set less than
                        alu_opcode <= "0111";
				    elsif funct7 = "0000001" then -- set greater then
                        alu_opcode <= "1001";
				    elsif funct7 = "0000010" then -- set less than or equal to
                        alu_opcode <= "1000";
				    elsif funct7 = "0000011" then -- set greater than or equal to
                        alu_opcode <= "1010";
				    elsif funct7 = "0000100" then -- set if equal
				        alu_opcode <= "1011";
				    else 
				        alu_opcode <= "1111"; -- invalid operation
					end if;  --end if for funct7
					
--				elsif funct3 = "011" then  -- sltu -- moved to a different opcode
				
				elsif funct3 = "100" then 
				    if funct7 = "0000000" then -- xor
				        alu_opcode <= "0101";
				     elsif funct7 = "0000001" then -- div
				        alu_opcode <= "0110";
				     else 
				        alu_opcode <= "1111"; -- invalid operation
				     end if;
				elsif funct3 = "101" then -- shift right
				    alu_opcode <= "1110";
				    --funct7 = "0000000" then -- shift right logical (srl)
				    -- funct7 = "0100000" then  -- shift right arthmethic (sra)
				elsif funct3 = "110" then -- or
				    alu_opcode <= "0011";
				else -- funct3 = "111" -- and
				    alu_opcode <= "0100";
                end if;
			elsif op_code = "1100011" then --branch
				op_class <= "01000";
				a_select <= '1';
				b_select <= '1';
				conditional_opcode <= funct3;
				alu_opcode <= "0000"; -- add
				f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
                
			elsif op_code = "1101111" then --jump and link
                op_class <= "10000";
			    a_select <= '1';
			    b_select <= '1';
			    alu_opcode <= "0000"; -- add
				conditional_opcode<="110";
				f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
                
			elsif op_code = "0110111" then -- lui
			    op_class <= "00100";
			    alu_opcode <= "1100";
			    a_select <= '0';
			    b_select <= '1';
			    f_op <= '0';
                ml_op <= '0';
                ml_opcode <= '0';
                
			elsif op_code = "1010011" then -- f operations
			    a_select <= '0';
			    b_select <= '0';
			    f_op <= '1';
                ml_op <= '0';
                if funct3 = "111" then
                    if funct7 = "0000000" then -- fadd
                        alu_opcode <= "0000";
			        elsif funct7 = "0000100" then -- fsub
                        alu_opcode <= "0001";
			        elsif funct7 = "0001000" then -- fmul
                        alu_opcode <= "0010";
                    else
                        alu_opcode <= "1111";
			        end if; -- funct7
			    else
			        alu_opcode <= "1111";
			    end if; --funct3
			elsif op_code = "1010111" then -- ml operations
                a_select <= '0';
                b_select <= '0';
                f_op <= '0';
                ml_op <= '1';
                alu_opcode <= "1111";
                op_class <= "00100";
                
                if funct3 = "000" then -- mac
                    ml_opcode <= '0';
                elsif funct3 = "001" then -- leaky relu
                    ml_opcode <= '1';
                else
                    ml_op <= '0';
                    ml_opcode <= '0';
                end if;
			else 
			    op_class <= "00000";
			    a_select <= '0';
				b_select <= '0';
				f_op <= '0';
                ml_op <= '0';
				alu_opcode <= "1111";
				conditional_opcode<="111";
			end if; --opcode
	   end if;
	end if;
end process;
end Behavioral;