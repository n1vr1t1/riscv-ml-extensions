
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity seven_segment_driver is
    generic (
        size : integer := 20
    );
    Port (
        clock : in std_logic;
        reset : in std_logic;
        digit0 : in std_logic_vector( 3 downto 0 );
        digit1 : in std_logic_vector( 3 downto 0 );
        digit2 : in std_logic_vector( 3 downto 0 );
        digit3 : in std_logic_vector( 3 downto 0 );
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic;
        AN : out std_logic_vector( 3 downto 0 )
    );

end seven_segment_driver;

architecture Behavioral of seven_segment_driver is

    -- We will use a counter to derive the frequency for the displays
    -- Clock is 100 MHz, we use 3 bits to address the display, so we count every
    -- size - 3 bits. To get ~100 Hz per digit, we need 20 bits, so that we divide
    -- by 2^20.
    signal flick_counter : unsigned( size - 1 downto 0 );
    -- The digit is temporarily stored here
    signal digit : std_logic_vector( 3 downto 0 );
    -- Collect the values of the cathodes here
    signal cathodes : std_logic_vector( 7 downto 0 );

begin
process (reset, clock) begin
    -- Divide the clock
    if reset = '0' then
            flick_counter <= (others => '0');
        elsif rising_edge(clock) then
            flick_counter <= flick_counter + 1;
    end if;
end process;
process (flick_counter) begin
    -- Select the anode
    if flick_counter(size - 1 downto size - 2) = "00" then
        AN <= "1110";
        digit <= digit0;
    elsif flick_counter(size - 1 downto size - 2) = "01" then
        AN <= "1101";
        digit <= digit1;
    elsif flick_counter(size - 1 downto size - 2) = "10" then
        AN <= "1011";
        digit <= digit2;
    else
        AN <= "0111" ;
        digit <= digit3;
    end if;
end process;
process (digit) begin
    -- Decode the digit
    if digit = "0000" then
        cathodes <= "11000000";  -- Display 0
    elsif digit = "0001" then
        cathodes <= "11111001";  -- Display 1
    elsif digit = "0010" then
        cathodes <= "10100100";  -- Display 2
    elsif digit = "0011" then
        cathodes <= "10110000";  -- Display 3
    elsif digit = "0100" then
        cathodes <= "10011001";  -- Display 4
    elsif digit = "0101" then
        cathodes <= "10010010";  -- Display 5
    elsif digit = "0110" then
        cathodes <= "10000010";  -- Display 6
    elsif digit = "0111" then
        cathodes <= "11111000";  -- Display 7
    elsif digit = "1000" then
        cathodes <= "10000000";  -- Display 8
    elsif digit = "1001" then
        cathodes <= "10010000";  -- Display 9
    elsif digit = "1010" then
        cathodes <= "10001000";  -- Display A
    elsif digit = "1011" then
        cathodes <= "10000011";  -- Display B
    elsif digit = "1100" then
        cathodes <= "11000110";  -- Display C
    elsif digit = "1101" then
        cathodes <= "10100001";  -- Display D
    elsif digit = "1110" then
        cathodes <= "10000110";  -- Display E
    else
        cathodes <= "10001110";  -- Display F (when others)
    end if;
end process;
DP <= cathodes( 7 );
CG <= cathodes( 6 );
CF <= cathodes( 5 );
CE <= cathodes( 4 );
CD <= cathodes( 3 );
CC <= cathodes( 2 );
CB <= cathodes( 1 );
CA <= cathodes( 0 );

end Behavioral;