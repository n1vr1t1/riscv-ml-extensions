-------------------------------------------------
-- Notes: 
-- 1. For flw and fsw, the float bit is not activated because we are writing to the normal register file 
--    and the address is an int, therefore only the alu is used to calculate the address which is an int
-- 2. ml opcode is 1000001
-- 3. vector operations 1010111, vector load 0000111, vector store 0100111
---------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    Port (rst : in std_logic;
--        stall : in std_logic;
        clk : in std_logic;
    	flush : in std_logic; -- active low
    	opcode : in std_logic_vector(6 downto 0);
		funct7 : in std_logic_vector(6 downto 0);
		funct3 : in std_logic_vector(2 downto 0);
        opclass : out STD_LOGIC_VECTOR (4 downto 0);
        operation_code : out STD_LOGIC_VECTOR (3 downto 0); -- used by alu, fpu and mlu
        a_select :out STD_LOGIC_VECTOR (1 downto 0);
        b_select : out STD_LOGIC_VECTOR (1 downto 0);
		c_select : out std_logic;
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
        fpu_en : out std_logic; -- indicates that the operation using the fpu (floating point unit)
        vpu_en : out std_logic; -- indicates that the operation using the vpu (vector processing unit)
        vec_reg_en : out std_logic; -- indicates that the value needs to be saved in the vector register
        vec_data_mem_en : out std_logic; -- indicates that the value is written to the data memory
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
		a_select <= "00";
		b_select <= "00";
		c_select <= '0';
		fpu_en <= '0';
		vpu_en <= '0';
        mlu_en <= '0';
        vec_reg_en <= '0';
        vec_data_mem_en <= '0';
		conditional_opcode  <= (others => '1');
    elsif rising_edge(clk) then 
		if flush = '1' then
            opclass <= (others => '0');
			operation_code  <= (others => '1');
			a_select <= "00";
			b_select <= "00"; 
			c_select <= '0';
			fpu_en <= '0';
            vpu_en <= '0';
            mlu_en <= '0';
            vec_reg_en <= '0';
            vec_data_mem_en <= '0';
			conditional_opcode  <= (others => '1');
	    else -- normal operations (without flush)
			opclass <= "00100";
			conditional_opcode <= (others => '1'); -- default for when we dont have a branch instruction
			c_select <= '0'; -- default for non-vector instructions -> taking the value from the register file 
			vec_data_mem_en <= '0';
			case opcode is
				when "0000011" => -- load from memory to register file
					opclass <= "00001";
					operation_code <= "0000"; -- add
					a_select <= "00";
					b_select <= "01"; -- for vle, the immediate is 0, and for flw the immediate is taken from the instruction
					vpu_en <= '0'; -- does not use the values from the vector register therefore the vpu does not need to be activated
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '0';
				when "0000111" => -- load from memory to vector register
					opclass <= "00001";
					operation_code <= "0000"; -- add
					a_select <= "00";
					b_select <= "01"; -- for vle, the immediate is 0, and for flw the immediate is taken from the instruction
					vpu_en <= '0'; -- does not use the values from the vector register therefore the vpu does not need to be activated
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '1';
				when "0100011" => -- store into memory
					opclass <= "00010";
					operation_code <= "0000"; -- add
					a_select <= "00";
					b_select <= "01"; -- always 1 because the second value is taken from the immediate generator
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '0';
				when "0100111" => -- store into memory from vector register
					opclass <= "00010";
					operation_code <= "0000"; -- add
					a_select <= "00";
					b_select <= "01"; -- always 1 because the second value is taken from the immediate generator
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '0'; -- vector register is not written
					vec_data_mem_en <= '1'; -- indicates that the value needs to be written to data memory from vector register
				when "0010011" => -- immediate
					a_select <= "00";
					b_select <= "01";
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					vec_reg_en <= '0';
					case funct3 is 
						when "000" => operation_code <= "0000"; -- addi
						when "001" => operation_code <= "1101"; -- slli
						when "010" => operation_code <= "0011"; -- slti
						-- when "011" => -- sltiu (not implemented)
						when "100" => operation_code <= "1000"; -- xori
						when "101" => operation_code <= "1110"; -- srli
						when "110" => operation_code <= "0110"; -- ori
						when "111" => operation_code <= "0111"; -- andi
						when others => operation_code <= "0000"; -- add by default
					end case;
				when "0110011" => -- operation
					a_select <= "00";
					b_select <= "00";
					fpu_en <= '0';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '0';
					case funct7 is
						when "0000000" =>
							case funct3 is
								when "000" => operation_code <= "0000"; -- add
								when "001" => operation_code <= "1101"; -- sll
								when "010" => operation_code <= "0011"; -- set less than
								-- when "011" => -- set less than unsigned (not implemented)
								when "100" => operation_code <= "1000"; -- xor
								when "101" => operation_code <= "1110"; -- srl
								when "110" => operation_code <= "0110"; -- or
								when "111" => operation_code <= "0111"; -- and
								when others => operation_code <= "1111"; -- invalid operation
							end case;
						when "0000001" =>
							case funct3 is
								when "000" => operation_code <= "0010"; -- mul
								when "100" => operation_code <= "1001"; -- div
								when others => operation_code <= "1111"; -- invalid operation
							end case;
						when "0000010" =>
							case funct3 is
								when "000" => operation_code <= "0001"; -- set less than and equal
								when "001" => operation_code <= "0001"; -- set if equal
								when "010" => operation_code <= "0001"; -- set great than or equal
								when "011" => operation_code <= "0001"; -- set greater then
								when "100" => -- macc/madd
									mlu_en <= '1';
									operation_code <= "0001"; 
								when "101" => -- leaky relu
									mlu_en <= '1';
									operation_code <= "0010"; 
								when others => operation_code <= "1111"; -- invalid operation
							end case;
						when "0100000" =>
							operation_code <= "0001"; -- sub
						when others =>
							operation_code <= "1111"; -- invalid operation
					end case;
				when "1100011" => -- branch
					opclass <= "01000";
					a_select <= "01";
					b_select <= "01";
					conditional_opcode <= funct3;
					operation_code <= "0000";
					vpu_en <= '0';
					vec_reg_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
				when "1101111" => -- jump and link
					opclass <= "10000";
					a_select <= "01";
					b_select <= "01";
					operation_code <= "0000";
					conditional_opcode <= "110";
					vpu_en <= '0';
					vec_reg_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
				when "1100111" => -- jump and link register
					opclass <= "10000";
					a_select <= "00";
					b_select <= "01";
					operation_code <= "0000";
					conditional_opcode <= "110";
					vpu_en <= '0';
					vec_reg_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
				when "0110111" => -- lui
					operation_code <= "1100";
					a_select <= "00";
					b_select <= "01";
					fpu_en <= '0';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '0';
				when "1000011" => -- fmadd
					a_select <= "00";
					b_select <= "00";
					fpu_en <= '1';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '1';
					operation_code <= "0001";
				when "1010011" => -- float operations
					a_select <= "00";
					b_select <= "00";
					fpu_en <= '1';
					vpu_en <= '0';
					vec_reg_en <= '0';
					mlu_en <= '0';
					case funct7 is
						when "0000000" => operation_code <= "0000"; -- fadd
						when "0000010" => -- leaky relu
							mlu_en <= '1';
							operation_code <= "0010";
						when "0000100" => operation_code <= "0001"; -- fsub
						when "0001000" => operation_code <= "0010"; -- fmul
						when "0010100" =>
							if funct3(0) = '1' then -- 001
								operation_code <= "0100"; -- fmax
							else
								operation_code <= "0011"; -- fmin
							end if;
						when "1010000" =>
							if funct3(1) = '1' then -- 010
								operation_code <= "0110"; -- feq
							elsif funct3(0) = '1' then -- 001
								operation_code <= "0011"; -- flt
							else
								operation_code <= "0100"; -- fgt
							end if;
						when "1110000" => operation_code <= "0111"; -- fmv.x.w (int to float)
						when "1101000" => operation_code <= "0111"; -- fcvt.s.w
						when "1111000" => operation_code <= "1000"; -- fmv.w.x (float to int)
						when "1100000" => operation_code <= "1000"; -- fcvt.w.s
						when others => operation_code <= "1111";
					end case;
				when "1010111" => -- vector operations
					vpu_en <= '1';
					mlu_en <= '0';
					vec_reg_en <= '1';
					b_select <= "10"; -- for vector operations, operand 2 is always from the vector register
					c_select <= '1'; -- takes the value from the vector register
					case funct6 is
						when "000000" =>  -- vadd
							operation_code <= "0000"; -- add
							case funct3 is
								when "000" => -- vadd.vv
									fpu_en <= '0';
									a_select <= "10";
								when "001" => -- vfadd.vv
									fpu_en <= '1';
									a_select <= "10";
								when "011" => -- vadd.vi
									fpu_en <= '0';
									a_select <= "11";
								when "100" => -- vadd.vx
									fpu_en <= '0';
									a_select <= "00";
								when "101" => -- vfadd.vf
									a_select <= "00";
									fpu_en <= '1';
								when others => 
									a_select <= "00";
									fpu_en <= '0';
							end case;
						when "000010" =>  -- vsub
							operation_code <= "0001"; -- sub
							case funct3 is
								when "000" => -- vsub.vv
									fpu_en <= '0';
									a_select <= "10";
								when "001" => -- vfsub.vv
									fpu_en <= '1';
									a_select <= "10";
								when "100" => -- vsub.vx
									a_select <= "00";
									fpu_en <= '0';
								when "101" => -- vfsub.vf
									a_select <= "00";
									fpu_en <= '1';
								when others => 
									a_select <= "00";
									fpu_en <= '0';
							end case;
						when "100100" =>  -- vfmul
							fpu_en <= '1';
							operation_code <= "0010"; -- mul
							case funct3 is
								when "001" => -- vfmul.vv
									a_select <= "10";
								when "101" => -- vfmul.vf
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "000100" =>  -- vfmin (same as vmflt)
							fpu_en <= '1';
							operation_code <= "0011"; -- slt;
							case funct3 is
								when "001" => -- vfmin.vv
									a_select <= "10";
								when "101" => -- vfmin.vf
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "000101" =>  -- vmin
							fpu_en <= '0';
							operation_code <= "0011"; -- slt
							case funct3 is
								when "000" => -- vmin.vv
									a_select <= "10";
								when "100" => -- vmin.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "000111" =>  -- vmax
							fpu_en <= '0';
							operation_code <= "1010"; -- sgt
							case funct3 is
								when "000" => -- vmax.vv
									a_select <= "10";
								when "100" => -- vmax.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "000110" =>  -- vfmax (same as c)
							fpu_en <= '1';
							operation_code <= "0100";
							case funct3 is
								when "001" => -- vfmax.vv
									a_select <= "10";
								when "101" => -- vfmax.vf
									a_select <= "00";
								when others => operation_code <= "1111";
							end case;
						when "011011" => -- lt
							operation_code <= "0011"; --set if less then
							case funct3 is
								when "000" => -- vmslt.vv
									a_select <= "10";
									fpu_en <= '0';
								when "001" => -- vmflt.vv
									a_select <= "10";
									fpu_en <= '1';
								when "100" => -- vmslt.vx
									a_select <= "00";
									fpu_en <= '0';
								when "101" => -- vmflt.vf
									a_select <= "00";
									fpu_en <= '1';
								when others => 
									a_select <= "00";
									fpu_en <= '0';
							end case;
						when "011101" => -- vmsle & vmfgt
							operation_code <= "0100";
							case funct3 is
								when "000" => -- vmsle.vv
									a_select <= "10";
									fpu_en <= '0';
								when "011" => -- vmsle.vi
									a_select <= "11";
									fpu_en <= '0';
								when "100" => -- vmsle.vx
									a_select <= "00";
									fpu_en <= '0';
								when "101" => -- vmfgt.vf
									a_select <= "00";
									fpu_en <= '1';
								when others => 
									a_select <= "00";
									fpu_en <= '0';
							end case;
						-- when "011100" => -- ne
						-- 	fpu_en <= '1';
						-- 	case funct3 is
						-- 		when "001" => -- vmfne.vv
						-- 			a_select <= "10";
						-- 		when "101" => -- vmfne.vf
						-- 			a_select <= "00";
						-- 		when others => operation_code <= "1111";
						-- 	end case;
						when "011111" => -- vmsgt
							fpu_en <= '0';
							case funct3 is
								when "011" => -- vmsgt.vi
									a_select <= "11";
									operation_code <= "1011";
								when "100" => -- vmsgt.vx
									a_select <= "00";
									operation_code <= "1011";
								-- when "101" => -- vmfge.vf
								-- 	a_select <= "10";
								-- 	fpu_en <= '1';
								-- 	operation_code <= "0100";
								when others => operation_code <= "1111";
							end case;
						when "011000" => -- eq
							case funct3 is
								when "000" => -- vmseq.vv
									a_select <= "10";
									operation_code <= "0101";
									fpu_en <= '0';
								when "001" => -- vmfeq.vv
									operation_code <= "0110";
									a_select <= "10";
									fpu_en <= '1';
								when "011" => -- vmseq.vi
									operation_code <= "0101";
									a_select <= "11";
									fpu_en <= '0';
								when "100" =>  -- vmseq.vx
									operation_code <= "0101";
									a_select <= "00";
									fpu_en <= '0';
								when "101" =>  -- vmfeq.vf
									operation_code <= "0110";
									a_select <= "00";
									fpu_en <= '1';
								when others => 
									a_select <= "00";
									fpu_en <= '0';
									operation_code <= "1111";
							end case;
						when "011001" => -- vmfle
							operation_code <= "0101";
							fpu_en <= '1';
							case funct3 is
								-- when "000" => -- vmsne.vv 
								-- 	a_select <= "10";
								-- 	fpu_en <= '0';
								when "001" => -- vmfle.vv
									a_select <= "10";
									-- fpu_en <= '1';
								-- when "011" => -- vmsne.vi
								-- 	a_select <= "11";
								-- 	fpu_en <= '0';
								-- when "100" => -- vmsne.vx
								-- 	a_select <= "00";
								-- 	fpu_en <= '0';
								when "101" => -- vmfle.vf
									a_select <= "00";
									-- fpu_en <= '1';
								when others => a_select <= "00";
							end case;
						when "001001" => -- vand
							fpu_en <= '0';
							operation_code <= "0111";
							case funct3 is
								when "000" => -- vand.vv
									a_select <= "10";
								when "011" => -- vand.vi
									a_select <= "11";
								when "100" => -- vand.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "001010" => -- vor
							fpu_en <= '0';
							operation_code <= "0110";
							case funct3 is
								when "000" =>  -- vor.vv
									a_select <= "10";
								when "011" => -- vor.vi
									a_select <= "11";
								when "100" => -- vor.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "001011" => -- vxor
							fpu_en <= '0';
							operation_code <= "1000";
							case funct3 is
								when "000" => -- vxor.vv
									a_select <= "10";
								when "011" => -- vxor.vi
									a_select <= "11";
								when "100" => -- vxor.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "100001" => -- vdiv
							fpu_en <= '0';
							operation_code <= "1001";
							case funct3 is
								when "010" => -- vdiv.vv
									a_select <= "10";
								when "110" => -- vdiv.vx 
									a_select <= "00";
								when others => operation_code <= "1111";
							end case;
						when "100101" => -- vsll & vmul
							fpu_en <= '0';
							case funct3 is
								when "000" => -- vsll.vv
									a_select <= "10";
									operation_code <= "1101";
								when "010" => -- vmul.vv
									a_select <= "10";
									operation_code <= "0010";
								when "011" => -- vsll.vi
									a_select <= "11";
									operation_code <= "1101";
								when "100" => -- vsll.vx
									a_select <= "00";
									operation_code <= "1101";
								when "110" => -- vmul.vx
									a_select <= "00";
									operation_code <= "0010";
								when others => 
									a_select <= "00";
									operation_code <= "1111";
							end case;
						when "101000" => -- vsrl
							fpu_en <= '0';
							operation_code <= "1110";
							case funct3 is
								when "000" => -- vsrl.vv
									a_select <= "10";
								when "011" => -- vsrl.vi
									a_select <= "11";
								when "100" => -- vsrl.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "101101" => -- vmacc
							fpu_en <= '0';
							mlu_en <= '1';
							operation_code <= "0001";
							case funct3 is
								when "010" => -- vmacc.vv
									a_select <= "10";
								when "110" => -- vmacc.vx
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when "101100" => -- vfmacc 
							mlu_en <= '1';
							operation_code <= "0000"; 
							fpu_en <= '1';
							case funct3 is
								when "001" => -- vfmacc.vv
									a_select <= "10";
								when "101" => -- vfmacc.vf
									a_select <= "00";
								when others => a_select <= "00";
							end case;
						when others => 
							fpu_en <= '0';
							a_select <= "00";
							operation_code <= "1111";
					end case;
				when others =>
					opclass <= "00000";
					a_select <= "00";
					b_select <= "00";
					vpu_en <= '0';
					fpu_en <= '0';
					mlu_en <= '0';
					operation_code <= "1111";
			end case;
		end if; -- flush
	end if;
end process;
end Behavioral;