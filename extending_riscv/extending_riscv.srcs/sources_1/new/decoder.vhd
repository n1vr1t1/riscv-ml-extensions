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
		instruction : in std_logic_vector(31 downto 0);
        opclass : out STD_LOGIC_VECTOR (4 downto 0);
        operation_code : out STD_LOGIC_VECTOR (3 downto 0); -- used by alu, fpu and mlu
        a_select :out STD_LOGIC_VECTOR (1 downto 0);
        b_select : out STD_LOGIC_VECTOR (1 downto 0);
        conditional_opcode : out STD_LOGIC_VECTOR (2 downto 0);
		uncond_branch : out STD_LOGIC; -- indicates whether the instruction is an unconditional branch (jal, jalr)
        fpu_en : out std_logic; -- indicates that the operation using the fpu (floating point unit)
        vpu_en : out std_logic; -- indicates that the operation using the vpu (vector processing unit)
        vec_reg_en : out std_logic; -- indicates that the value needs to be saved in the vector register
        vecDM_en : out std_logic; -- indicates that the value is written to the data memory
        mlu_en : out std_logic;  -- indicates that the operation is using the mlu (machine learning unit)
		reduction_unit_en : out std_logic);
end decoder;

architecture Behavioral of decoder is
	signal funct6 : std_logic_vector(5 downto 0);
	signal opcode : std_logic_vector(6 downto 0);
	signal funct7 : std_logic_vector(6 downto 0);
	signal funct3 : std_logic_vector(2 downto 0);
	signal address_2 : std_logic_vector(4 downto 0);
begin
opcode <= instruction(6 downto 0);
funct3 <= instruction(14 downto 12);
funct7 <= instruction(31 downto 25);
funct6 <= instruction(31 downto 26);
address_2 <= instruction(24 downto 20);

process (rst, clk) begin
	if rst = '0' then 
		opclass <= (others => '0');
		operation_code  <= (others => '0');
		a_select <= "00";
		b_select <= "00";
		fpu_en <= '0';
		vpu_en <= '0';
        mlu_en <= '0';
        vec_reg_en <= '0';
        vecDM_en <= '0';
		conditional_opcode  <= (others => '1');
		reduction_unit_en <= '0';
		uncond_branch <= '0';
    elsif rising_edge(clk) then 
		if flush = '1' then
            opclass <= (others => '0');
			operation_code  <= (others => '1');
			a_select <= "00";
			b_select <= "00"; 
			fpu_en <= '0';
            vpu_en <= '0';
            mlu_en <= '0';
            vec_reg_en <= '0';
			uncond_branch <= '0';
            vecDM_en <= '0';
			conditional_opcode  <= (others => '1');
			reduction_unit_en <= '0';
	    else
			opclass <= "00100";
			conditional_opcode <= (others => '1'); -- default for when we dont have a branch instruction
			vecDM_en <= '0';
			vpu_en <= '0';
			fpu_en <= '0';
			mlu_en <= '0';
			vec_reg_en <= '0';
			uncond_branch <= '0';
			reduction_unit_en <= '0';
			case opcode is
				when "0000011" => -- int lw from memory
					opclass <= "00001";
					operation_code <= "0000";
					a_select <= "00";
					b_select <= "01";
				when "0000111" => -- float and vector load from memory
					opclass <= "00001";
					operation_code <= "0000";
					a_select <= "00";
					b_select <= "01"; -- for vle, the immediate is 0, and for flw the immediate is taken from the instruction
					if funct3 = "110" then -- vle32.v
					   vec_reg_en <= '1'; -- writes value into 1 out of 4 elements of destination vector register, the rest of the elements are not updated
					end if;
				when "0100011" => -- int store into memory
					opclass <= "00010";
					operation_code <= "0000"; -- add
					a_select <= "00";
					b_select <= "01";
				when "0100111" => -- store vector or float into memory
					opclass <= "00010";
					operation_code <= "0000"; -- add
					a_select <= "00";
					b_select <= "01";
					if funct3 = "110" then -- vse32.v
					   vecDM_en <= '1'; -- writes one element from the vector into DM
					end if;
				when "0010011" => -- immediate
					a_select <= "00";
					b_select <= "01";
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
					if funct7(5) = '1' then 
						-- sra is not implemented
						operation_code <= "0001"; -- sub
					elsif funct7(1) = '1' then -- adding new funct7 for set (except slt) and ml instructions
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
					elsif funct7(0) = '1' then 
						case funct3 is
							when "000" => operation_code <= "0010"; -- mul
							when "100" => operation_code <= "1001"; -- div
							when others => operation_code <= "1111"; -- invalid operation
						end case;
					else 
						case funct3 is
								when "000" => operation_code <= "0000"; -- add
								when "001" => operation_code <= "1101"; -- sll
								when "010" => operation_code <= "0011"; -- slt
								-- when "011" => -- set less than unsigned (not implemented)
								when "100" => operation_code <= "1000"; -- xor
								when "101" => operation_code <= "1110"; -- srl
								when "110" => operation_code <= "0110"; -- or
								when "111" => operation_code <= "0111"; -- and
								when others => operation_code <= "1111"; -- invalid operation
							end case;
					 end if;
				when "1100011" => -- branch
					opclass <= "01000";
					a_select <= "01";
					b_select <= "01";
					conditional_opcode <= funct3;
					operation_code <= "0000";
				when "1101111" => -- jump and link
					opclass <= "10000";
					a_select <= "01";
					b_select <= "01";
					operation_code <= "0000";
					conditional_opcode <= "000";
					uncond_branch <= '1';
				when "1100111" => -- jump and link register
					opclass <= "10000";
					a_select <= "00";
					b_select <= "01";
					operation_code <= "0000";
					uncond_branch <= '1';
					conditional_opcode <= "000";
				when "0110111" => -- lui
					operation_code <= "1100";
					a_select <= "00";
					b_select <= "01";
				when "1000011" => -- fmadd
					a_select <= "00";
					b_select <= "00";
					fpu_en <= '1';
					mlu_en <= '1';
					operation_code <= "0001";
				when "1010011" => -- float operations
					a_select <= "00";
					b_select <= "00";
					fpu_en <= '1';
					if funct7(6) = '1' then -- 1xxxxxx
						if funct7(5) = '1' then -- 11xxxxx
							if funct7(3) = '1' then -- 11x1xxx
								operation_code <= "0111"; -- fcvt.s.w
							else -- 11x0xxx
								operation_code <= "1000"; -- fcvt.w.s
							end if;
						else -- 10xxxxx
							if funct3(1) = '1' then -- x1x
								operation_code <= "0110"; -- feq
							elsif funct3(0) = '1' then -- x01
								operation_code <= "0011"; -- flt
							else -- x00
								operation_code <= "0100"; -- fgt
							end if; 
						end if;
					elsif funct7(4) = '1' then -- 001xxxx
						if funct3(0) = '1' then -- xx1
							operation_code <= "0100"; -- fmax
						else -- xx0
							operation_code <= "0011"; -- fmin
						end if;
					elsif funct7(3) = '1' then -- 0001xxx
							operation_code <= "0010"; -- fmul
					elsif funct7(2) = '1' then -- 00001xx
							operation_code <= "0001"; -- fsub
					elsif funct7(1) = '1' then -- 000001x
							mlu_en <= '1';
							operation_code <= "0010"; -- leaky relu
					else operation_code <= "0000"; -- fadd (0000000)
					end if;
				when "1010111" => -- vector operations
					vpu_en <= '1';
					vec_reg_en <= '1';
					a_select <= "10"; -- for vector operations, operand 2 is always from the vector register
					case funct6 is
						when "000000" =>  -- vadd and vredsum
							operation_code <= "0000"; -- add
							case funct3 is
								when "001" => -- vfadd.vv
									fpu_en <= '1';
									b_select <= "10";
								when "011" => -- vadd.vi
									b_select <= "01";
								when "100" => -- vadd.vx
									b_select <= "11";
								when "101" => -- vfadd.vf
									b_select <= "11";
									fpu_en <= '1';
								when "010" => -- vredsum.vs
									b_select <= "00";
									vpu_en <= '0';
									reduction_unit_en <= '1';
								when others => -- vadd.vv (000)
									b_select <= "10";
							end case;
						when "000001" =>
							b_select <= "00";
							vpu_en <= '0';
							reduction_unit_en <= '1';
							if funct3(1) = '1' then -- vfredusum.vs
								fpu_en <= '1';
								operation_code <= "0000";
							else -- vredand.vs
								operation_code <= "0001";
							end if;
						when "000010" =>  -- vsub
							operation_code <= "0001"; -- sub
							case funct3 is
								when "001" => -- vfsub.vv
									fpu_en <= '1';
									b_select <= "10";
								when "010" => -- vredor.vs
									b_select <= "00";
									vpu_en <= '0';
									reduction_unit_en <= '1';
									operation_code <= "0010";
								when "100" => -- vsub.vx
									b_select <= "11";
								when "101" => -- vfsub.vf
									b_select <= "11";
									fpu_en <= '1';
								when others => 
									b_select <= "10"; -- vsub.vv (000)
							end case;
						when "000011" =>  -- vred
							b_select <= "00";
							vpu_en <= '0';
							reduction_unit_en <= '1';
							if funct3(1) = '1' then -- vredxor (x1x)
								operation_code <= "0011";
							else -- vfredosum
								operation_code <= "0000";
								fpu_en <= '1';
							end if;
						when "100100" =>  -- vfmul
							fpu_en <= '1';
							operation_code <= "0010"; -- mul
							case funct3 is
								when "101" => -- vfmul.vf
									b_select <= "11";
								when others => b_select <= "10"; -- vfmul.vv (001)
							end case;
						when "000100" =>  -- vfmin (same as vmflt)
							fpu_en <= '1';
							operation_code <= "0011"; -- slt;
							case funct3 is
								when "101" => -- vfmin.vf
									b_select <= "11";
								when others => b_select <= "10"; -- vfmin.vv (001)
							end case;
						when "000101" =>  -- vmin (same as vmslt)
							operation_code <= "0011"; -- slt
							case funct3 is
								when "001" => -- vfredmin.vs
									b_select <= "00";
									fpu_en <= '1';
									operation_code <= "0001";
									vpu_en <= '0';
									reduction_unit_en <= '1';
								when "100" => -- vmin.vx
									b_select <= "11";
								when "010" => -- vredmin.vs
									b_select <= "00";
									operation_code <= "0100";
									vpu_en <= '0';
									reduction_unit_en <= '1';
								when others => b_select <= "10"; -- vmin.vv (000)
							end case;
						when "000111" =>  -- vmax (same as vmsgt)
							operation_code <= "1010"; -- sgt
							case funct3 is
								when "001" => --vfredmax.vs
									b_select <= "00";
									fpu_en <= '1';
									operation_code <= "0010";
									vpu_en <= '0';
									reduction_unit_en <= '1';
								when "100" => -- vmax.vx
									b_select <= "11";
								when "010" => -- vredmax.vs
									b_select <= "00";
									operation_code <= "0101";
									vpu_en <= '0';
									reduction_unit_en <= '1';
								when others => b_select <= "10"; -- vmax.vv (000)
							end case;
						when "000110" =>  -- vfmax (same as vmfgt)
							fpu_en <= '1';
							operation_code <= "0100";
							case funct3 is
								when "101" => -- vfmax.vf
									b_select <= "11";
								when others => b_select <= "10"; -- vfmax.vv (001)
							end case;
						when "011011" => -- vslt
							operation_code <= "0011"; -- set if less than
							case funct3 is
								when "001" => -- vmflt.vv
									b_select <= "10";
									fpu_en <= '1';
								when "100" => -- vmslt.vx
									b_select <= "11";
								when "101" => -- vmflt.vf
									b_select <= "11";
									fpu_en <= '1';
								when others => 
									b_select <= "10"; -- vmslt.vv (000)
							end case;
						when "011101" => -- vmsle & vmfgt
							operation_code <= "0100";
							case funct3 is
								when "011" => -- vmsle.vi
									b_select <= "01";
								when "100" => -- vmsle.vx
									b_select <= "11";
								when "101" => -- vmfgt.vf
									operation_code <= "1001";
									b_select <= "11";
									fpu_en <= '1';
								when others => 
									b_select <= "10";  -- vmsle.vv (000)
							end case;
						when "011111" => -- vmsgt
							case funct3 is
								when "011" => -- vmsgt.vi
									b_select <= "01";
									operation_code <= "1011";
								when "100" => -- vmsgt.vx
									b_select <= "11";
									operation_code <= "1011";
								when "101" => -- vmfge.vf
									b_select <= "11";
									fpu_en <= '1';
									operation_code <= "0100";
								when others => 
									operation_code <= "1111";
									b_select <= "00";
							end case;
						when "011000" => -- eq
							case funct3 is
								when "001" => -- vmfeq.vv
									operation_code <= "0110";
									b_select <= "10";
									fpu_en <= '1';
								when "011" => -- vmseq.vi
									operation_code <= "0101";
									b_select <= "01";
								when "100" =>  -- vmseq.vx
									operation_code <= "0101";
									b_select <= "11";
								when "101" =>  -- vmfeq.vf
									operation_code <= "0110";
									b_select <= "11";
									fpu_en <= '1';
								when others => -- vmseq.vv (000)
									b_select <= "10";
									operation_code <= "0101";
							end case;
						when "011001" => -- vmfle
							operation_code <= "0101";
							fpu_en <= '1';
							case funct3 is
								when "101" => -- vmfle.vf
									b_select <= "11";
								when others => -- vmfle.vv (001)
									b_select <= "10";
							end case;
						when "001001" => -- vand
							operation_code <= "0111";
							case funct3 is
								when "011" => -- vand.vi
									b_select <= "01";
								when "100" => -- vand.vx
									b_select <= "11";
								when others => -- vand.vv
									b_select <= "10";
							end case;
						when "001010" => -- vor
							operation_code <= "0110";
							case funct3 is
								when "011" => -- vor.vi
									b_select <= "01";
								when "100" => -- vor.vx
									b_select <= "11";
								when others => -- vor.vv (000)
									b_select <= "10";
							end case;
						when "001011" => -- vxor
							operation_code <= "1000";
							case funct3 is
								when "011" => -- vxor.vi
									b_select <= "01";
								when "100" => -- vxor.vx
									b_select <= "11";
								when others => -- vxor.vv (000)
									b_select <= "10";
							end case;
						when "100001" => -- vdiv
							operation_code <= "1001";
							case funct3 is
								when "110" => -- vdiv.vx 
									b_select <= "11";
								when others => -- vdiv.vv (010)
									b_select <= "10";
							end case;
						when "100101" => -- vsll & vmul
							case funct3 is
								when "010" => -- vmul.vv
									b_select <= "10";
									operation_code <= "0010";
								when "011" => -- vsll.vi
									b_select <= "01";
									operation_code <= "1101";
								when "100" => -- vsll.vx
									b_select <= "11";
									operation_code <= "1101";
								when "110" => -- vmul.vx
									b_select <= "11";
									operation_code <= "0010";
								when others => -- vsll.vv (000)
									b_select <= "10";
									operation_code <= "1101";
							end case;
						when "101000" => -- vsrl
							operation_code <= "1110";
							case funct3 is
								when "011" => -- vsrl.vi
									b_select <= "01";
								when "100" => -- vsrl.vx
									b_select <= "11";
								when others => -- vsrl.vv (000)
									b_select <= "10";
							end case;
						when "101101" => -- vmacc
							mlu_en <= '1';
							operation_code <= "0001";
							case funct3 is
								when "110" => -- vmacc.vx (takes addend from vector register and multiplier from scalar register)
									b_select <= "11";
								when others => -- vmacc.vv (010)
									b_select <= "10";
							end case;
						when "101100" => -- vfmacc 
							mlu_en <= '1';
							operation_code <= "0001"; 
							fpu_en <= '1';
							case funct3 is
								when "101" => -- vfmacc.vf (takes addend from vector register and multiplier from scalar register)
									b_select <= "11";
								when others => -- vfmacc.vv (001)
									b_select <= "10";
							end case;
						when "010010" => -- vfcvt
							fpu_en <= '1';
							b_select <= "10";
							if address_2(1) = '1' then -- xxx1x
							-- signed integer to float
								operation_code <= "0111"; -- fcvt.s.w
							else -- xxx0x
							-- float to signed integer
								operation_code <= "1000"; -- fcvt.w.s
							end if;
						when others => 
							b_select <= "00";
							operation_code <= "1111";
					end case;
				when others =>
					opclass <= "00000";
					a_select <= "00";
					b_select <= "00";
					operation_code <= "1111";
			end case;
		end if; -- flush
	end if; -- rst, clk
end process;
end Behavioral;