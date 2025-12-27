-------------------------------------------------
-- add path from comparator that gives out 1 if the condition is true, else 0 for code checks (NO) 
-- The alu gives back the value that satisfies the condition
-- add if block for immediate operations

-- Notes: 
-- 1. For flw and fsw, the float bit is not activated because we are writing to the normal register file 
--    and the address is an int, therefore only the alu is used
-- 2. Stall can be uncommented if we are implementing it for any reason
-- 3. ml opcode is  1000001

-- To do:
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    Port (rst : in std_logic;
--        stall : in std_logic;
        clk : in std_logic;
    	flush : in std_logic; --active low
    	opcode : in std_logic_vector(6 downto 0);
		funct7 : in std_logic_vector(6 downto 0);
		funct3 : in std_logic_vector(2 downto 0);
        opclass : out STD_LOGIC_VECTOR (4 downto 0);
        operation_code : out STD_LOGIC_VECTOR (3 downto 0); -- used by alu, fpu and mlu
        a_select : out STD_LOGIC;
        b_select : out STD_LOGIC;
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
        fpu_en : out std_logic; -- indicates that the operation using the fpu (floating point unit)
        vpu_en : out std_logic; -- indicates that the operation using the vpu (vector processing unit)
        vec_reg_en : out std_logic; -- indicates that the value needs to be saved in the vector register
        mlu_en : out std_logic); -- indicates that the operation is using the mlu (machine learning unit)
end decoder;

architecture Behavioral of decoder is
	signal funct6 : std_logic_vector(5 downto 0);
begin
funct6 <= funct7(6 downto 1);
process (rst, clk) begin
	if rst = '0' then 
		opclass <= (others => '0');
		operation_code  <= (others => '0');
		a_select <= '0';
		b_select <= '0'; 
		fpu_en <= '0';
		vpu_en <= '0';
        mlu_en <= '0';
        vec_reg_en <= '0';
		conditional_opcode  <= (others => '1');
    elsif rising_edge(clk) then 
		if flush = '1' then
            opclass <= (others => '0');
			operation_code  <= (others => '1');
			a_select <= '0';
			b_select <= '0'; 
			fpu_en <= '0';
            vpu_en <= '0';
            mlu_en <= '0';
            vec_reg_en <= '0';
			conditional_opcode  <= (others => '1');
	    else
			conditional_opcode <= "111"; -- default for when we dont have a branch instruction
			case opcode is
				when "0000011" | "0000111" => -- load from memory
					opclass <= "00001";
					operation_code <= "0000"; -- add
					a_select <= '0';
					b_select <= '1';
					vpu_en <= '0'; -- does not use the values from the vector register therefore the vpu does not need to be activated
					fpu_en <= '0';
					mlu_en <= '0';
					if funct3 = "110" then -- condition to load from memory into the vector register 
				-- neither ints nor floats make use of 110 for the funct3 value, 
				--- so we assume that it can only be associated to a vector instruction
						vec_reg_en <= '1';
					else -- the check for b,w,q is not done in this implementation
						vec_reg_en <= '0';
					end if;
				when "0100011" | "0100111" => -- store into memory
					opclass <= "00010";
					operation_code <= "0000"; -- add
					a_select <= '0';
					b_select <= '1'; -- always 1 because the second value is taken from the immediate generator
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '0'; -- vector register is not written
				when "0010011" => -- immediate
					operation_code <= "0000"; -- could be changed to have operations with immediates
					opclass <= "00100";
					a_select <= '0';
					b_select <= '1';
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '0';
				when "0110011" => -- operation
					opclass <= "00100";
					a_select <= '0';
					b_select <= '0';
					fpu_en <= '0';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '0';
					case funct3 is
						when "000" =>
							case funct7 is
								when "0000000" =>
									operation_code <= "0000"; -- add
								when "0100000" =>
									operation_code <= "0001"; -- sub
								when "0000001" =>
									operation_code <= "0010"; -- mul
								when others =>
									operation_code <= "1111"; -- invalid operation
							end case;
						when "001" =>
							if funct7 = "0000000" then -- sll
								operation_code <= "1101";
							else 
							   operation_code <= "1111"; -- invalid operation
							end if;
						when "010" =>
							case funct7 is
								when "0000000" => -- set less than
									operation_code <= "0011";
								when "0000001" => -- set greater then
									operation_code <= "1011";
								when "0000010" => -- set less than or equal to
									operation_code <= "0100";
								when "0000011" => -- set greater than or equal to
									operation_code <= "1010";
								when "0000100" => -- set if equal
									operation_code <= "0101";
								when others =>
									operation_code <= "1111"; -- invalid operation
							end case;
						-- when "011" => --sltu -- not implemented?
						when "100" => -- xor
							case funct7 is
								when "0000000" => -- xor
									operation_code <= "1000";
								when "0000001" => -- div
									operation_code <= "1001";
								when others =>
									operation_code <= "1111"; -- invalid operation
							end case;
						when "101" => -- shift right
							operation_code <= "1110"; -- srl and sra both mapped to same code
							--funct7 = "0000000" then -- shift right logical (srl)
				    		-- funct7 = "0100000" then  -- shift right arthmethic (sra)
						when "110" => -- or
							operation_code <= "0110";
						when others => -- "111" -- and
							operation_code <= "0111";
					end case;
				when "1100011" => -- branch
					opclass <= "01000";
					a_select <= '1';
					b_select <= '1';
					conditional_opcode <= funct3;
					operation_code <= "0000";
					vpu_en <= '0';
					vec_reg_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
				when "1101111" => -- jump and link
					opclass <= "10000";
					a_select <= '1';
					b_select <= '1';
					operation_code <= "0000";
					conditional_opcode <= "110";
					vpu_en <= '0';
					vec_reg_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
				when "0110111" => -- lui
					opclass <= "00100";
					operation_code <= "1100";
					a_select <= '0';
					b_select <= '1';
					fpu_en <= '0';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '0';
				when "1010011" => -- float operations
					opclass <= "00100";
					a_select <= '0';
					b_select <= '0';
					fpu_en <= '1';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '0';
					case funct3 is
						when "111" => 
							case funct7 is
								when "0000000" => -- fadd
									operation_code <= "0000";
								when "0000100" => -- fsub
									operation_code <= "0001";
								when "0001000" => -- fmul
									operation_code <= "0010";
								when others =>
									operation_code <= "1111";
							end case;
						when "000" => 
							case funct7 is
								when "1110000" => -- int to float
									operation_code <= "0110";
								when "1111000" => -- float to int
									operation_code <= "0111";
								when "1010000" => -- fle
									operation_code <= "0100"; 
								when others =>
									operation_code <= "1111";
							end case;
						when "010" => -- feq 
							operation_code <= "0101";
						when "001" => -- flt
							operation_code <= "0011";
						others =>
							operation_code <= "1111";
					end case;
				when "1000001" => -- ml operations
					a_select <= '0';
					b_select <= '0';
					fpu_en <= '0';
					mlu_en <= '1';
					vpu_en <= '0';
					vec_reg_en <= '0';
					opclass <= "00100";
					case funct3 is
						when "000" => -- mac
							operation_code <= "0000";
						when "001" => -- leaky relu
							operation_code <= "0001";
						when others =>
							mlu_en <= '0';
							operation_code <= "1111";
					end case;
				when "1010111" => -- vector operations
					vpu_en <= '1';
					vec_reg_en <= '1';
					opclass <= "00100";
					conditional_opcode <= "111";
					a_select <= '0';
					b_select <= '0';
					case funct3 is 
						when "000" | "100" => -- vector-vector (int)/ vector-scalar (int)
							fpu_en <= '0';
							mlu_en <= '0';
							case funct6 is
								when "000000" => operation_code <= "0000"; -- vadd.vv
								when "000010" => operation_code <= "0001"; -- vsub.vv
								when "011011" => operation_code <= "0011"; -- vslt.vv
								when "011101" => operation_code <= "0100"; -- vsle.vv
								when "011111" => operation_code <= "1011"; -- vsgt.vv
								when "011000" => operation_code <= "0101"; -- veq.vv
								when "001001" => operation_code <= "0111"; -- vand.vv
								when "001010" => operation_code <= "0110"; -- vor.vv
								when "001011" => operation_code <= "1000"; -- vxor.vv
								when "100001" => operation_code <= "1001"; -- vdiv.vv
								when "100101" => operation_code <= "1101"; -- vsll.vv
								when "101000" => operation_code <= "1110"; -- vsrl.vv
								when "101101" => -- vmacc.vv
									mlu_en <= '1';
									operation_code <= "0000";
								when others => operation_code <= "1111";
							end case;
						when "001" | "101" then -- vector-vector (float)
							fpu_en <= '1';
							mlu_en <= '0';
							case funct6 is
								when "000000" => operation_code <= "0000"; -- vfadd.vv / vfadd.vf
								when "000010" => operation_code <= "0001"; -- vfsub.vv / vfsub.vf
								when "100100" => operation_code <= "0010"; -- vfmul.vv / vfmul.vf
								when "000100" => operation_code <= "0011"; -- vfmin.vv / vfmin.vf (same as vmflt)
								when "000110" => operation_code <= "0100"; -- vfmax.vv / vfmax.vf (same as vmfgt)
								when "011000" => operation_code <= "0110"; -- vmfeq.vv / vmfeq.vf
								when "011011" => operation_code <= "0011"; -- vmflt.vv / vmflt.vf
								when "011001" => operation_code <= "0101"; -- vmfle.vv / vmfle.vf
								when "011101" => operation_code <= "0100"; -- vmfgt.vv / vmfgt.vf
								when "101100" => -- vfmacc.vv / vfmacc.vf
									mlu_en <= '1';
									operation_code <= "0000"; 
								when others => operation_code <= "1111";
							end case;
						when "010" | "110" then -- vmul.vv/vmul.vx (funct7 = "1001010")
							fpu_en <= '0';
							mlu_en <= '0';
							operation_code <= "0010";
						when "011" then -- vector-immediate
							fpu_en <= '0';
							mlu_en <= '0';
							b_select <= '1';
							case funct6 is
								when "000000" => operation_code <= "0000"; -- vadd.vi
								when "000011" => operation_code <= "0001"; -- vrsub.vi 
								when "001001" => operation_code <= "0111"; -- vand.vi
								when "001010" => operation_code <= "0110"; -- vor.vi
								when "001011" => operation_code <= "1000"; -- vxor.vi
								when "011000" => operation_code <= "0101"; -- veq.vi
								when "101000" => operation_code <= "1110"; -- vsrl.vi
								when others => operation_code <= "1111";
							end case;
						when others => -- invalid instruction
						opclass <= "00000";
						vpu_en <= '0';						
						fpu_en <= '0';
						mlu_en <= '0';
						operation_code <= "1111";
					end case;
				when others =>
					opclass <= "00000";
					a_select <= '0';
					b_select <= '0';
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					operation_code <= "1111";
					conditional_opcode <= "111";
			end case;
		end if;
	else 
		opclass <= "00000";
		a_select <= '0';
		b_select <= '0';
		vpu_en <= '0';
		fpu_en <= '0';
        mlu_en <= '0';
		operation_code <= "1111";
		conditional_opcode<="111";
	end if;
end process;
end Behavioral;