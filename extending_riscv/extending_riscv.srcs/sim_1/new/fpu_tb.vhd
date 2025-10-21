----------------------------------------------------------------------
-- does not do operations with nan, inf or subnormals
-- assumes the input is 0.0 if any of the above numbers are detected
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpu_tb is
end fpu_tb;

architecture Behavioral of fpu_tb is
    component fpu is
        Port (fp : in  std_logic;
            opcode : in  STD_LOGIC_VECTOR (1 downto 0);
            operand_1 : in  STD_LOGIC_VECTOR (31 downto 0);
            operand_2 : in  STD_LOGIC_VECTOR (31 downto 0);
            output : out STD_LOGIC_VECTOR (31 downto 0)
          );
    end component;

signal fp_tb : std_logic;
signal opcode_tb : std_logic_vector(1 downto 0);
signal operand_1_tb : std_logic_vector(31 downto 0);
signal operand_2_tb : std_logic_vector(31 downto 0);
signal output_tb : std_logic_vector(31 downto 0);

begin
    uut: fpu
        port map (fp => fp_tb,
            opcode => opcode_tb,
            operand_1 => operand_1_tb,
            operand_2 => operand_2_tb,
            output => output_tb
        );

    process begin
    
        fp_tb <= '0';
        opcode_tb <= "11"; -- add
        operand_1_tb <= x"00000000"; -- 1.0
        operand_2_tb <= x"00000000"; -- 2.0
        wait for 10 ns;
        
        fp_tb <= '1';
        opcode_tb <= "00"; -- add
        operand_1_tb <= x"40e80000"; -- 7.25
        operand_2_tb <= x"40900000"; -- 4.5
        -- result = x"413c0000" = 11.75
        wait for 10 ns;

        opcode_tb <= "01"; -- sub
        -- result = x"40200000" = 2.75
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"42028000" = 32.625
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"c0200000"; -- -2.5
        operand_2_tb <= x"40d80000"; -- 6.75
        -- result = x"40880000" = 4.25
        wait for 10 ns;

        opcode_tb <= "01"; -- sub
        -- result = x"c1200000" = -9.25
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"c1880000" = -16.875
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"3e200000"; -- 0.15625
        operand_2_tb <= x"3eb00000"; -- 0.34375
        -- result = x"3f000000" = 0.5
        wait for 10 ns;

        opcode_tb <= "01"; -- sub
        -- result = x"be400000" = -0.1875
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"3d5b0000" = 0.0537109375
        wait for 10 ns;
        
        opcode_tb <= "00"; -- add
        operand_1_tb <= x"3F800000"; -- 1.0
        operand_2_tb <= x"40000000"; -- 2.0
        -- result = x"40400000" = 3.0
        wait for 10 ns;

        opcode_tb <= "01"; -- sub
        -- result = x"bf800000"
        
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"3f800000"
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"40400000"; -- 3.0
        operand_2_tb <= x"40000000"; -- 2.0
        -- result = x"40a00000"
        wait for 10 ns;
        
        opcode_tb <= "01"; -- sub
        -- result = x"3f800000"
        
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"40e00000"
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"3F800000"; -- 1.0
        operand_2_tb <= x"C0400000"; -- -3.0
        -- result = x"c0000000"
        wait for 10 ns;
        
        opcode_tb <= "01"; -- sub
        -- result = x"40800000"
        
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"c0600000"
        wait for 10 ns;
        
        opcode_tb <= "00"; -- add
        operand_1_tb <= x"C1000000"; -- -8.0
        operand_2_tb <= x"C0A00000"; -- -5.0
        -- result = x"c1500000"
        wait for 10 ns;
        
        opcode_tb <= "01"; -- sub
        -- result = x"c0400000"
        
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"42500000"
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"C0A00000"; -- -5.0
        operand_2_tb <= x"40400000"; -- 3.0
        -- result = x"c0000000"
        wait for 10 ns;
        
        opcode_tb <= "01"; -- sub
        -- result = x"c1000000"
        
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"c1780000"
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"00000000"; -- 0.0
        operand_2_tb <= x"00000000"; -- 0.0
        -- result = x"00000000"
        wait for 10 ns;

        opcode_tb <= "01"; -- sub
        -- result = x"80000000"
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        -- result = x"00000000"
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"7f7fffff"; -- max normal
        operand_2_tb <= x"7f7fffff"; -- max normal
        -- result = x"7f800000" -- +Inf
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"ff7fffff"; -- min negative normal
        operand_2_tb <= x"ff7fffff"; -- min negative normal
        -- result = x"ff800000" -- -Inf (overflow)
        wait for 10 ns;

        opcode_tb <= "10"; -- mul
        operand_1_tb <= x"7f7fffff"; -- max normal
        operand_2_tb <= x"40000000"; -- 2.0
        -- result = x"7f800000" -- +Inf (overflow)
        wait for 10 ns;

        opcode_tb <= "00"; -- add
        operand_1_tb <= x"7f800000"; -- +Inf
        operand_2_tb <= x"ff800000"; -- -Inf
        -- result = x"00000000" -- (should be NaN, but your FPU sets to 0.0)
        wait for 10 ns;

        opcode_tb <= "01"; -- sub
        operand_1_tb <= x"80000000"; -- -0.0
        operand_2_tb <= x"00000000"; -- +0.0
        -- result = x"80000000" -- -0.0
        wait for 10 ns;

        opcode_tb <= "11"; -- invalid
        wait for 10 ns;
        wait;
    end process;

end Behavioral;
