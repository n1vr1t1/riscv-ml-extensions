library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity register_file is
  port (rst : in std_logic;
    clk : in std_logic;
    -- en : in std_logic; -- active low
    r1 : in std_logic_vector( 4 downto 0 ); -- Source 1 address
    r2 : in std_logic_vector( 4 downto 0 ); -- Source 2 address
    r3 : in std_logic_vector( 4 downto 0 ); -- Source 3 address
    rd_in : in std_logic_vector( 4 downto 0 ); -- Destination address for writing
    rd_data_in : in std_logic_vector( 31 downto 0 ); -- Destination data for writing
    we : in std_logic;-- write enable
    r1_data : out std_logic_vector( 31 downto 0 ); -- Register value of source 1
    r2_data : out std_logic_vector( 31 downto 0 ); -- Register value of source 2
    r3_data : out std_logic_vector( 31 downto 0 ) -- Register value of source 3
  );
end register_file;

architecture Behavioral of register_file is

  -- Define the register file. 32 registers, each 32-bit wide
  type reg_file_type is array ( 0 to 31 ) of std_logic_vector( 31 downto 0 );
  signal reg_file : reg_file_type;

begin
-- Reading process
reading :  process ( rst, clk ) begin
    if rst = '0' then 
        r1_data <= (others => '0');
        r2_data <= (others => '0');
        r3_data <= (others => '0');
    elsif rising_edge( clk ) then
        r1_data <= reg_file( to_integer( unsigned( r1 ) ) );
        r2_data <= reg_file( to_integer( unsigned( r2 ) ) );
        r3_data <= reg_file( to_integer( unsigned( r3 ) ) );
  	end if;
end process;
-- Writing process
writing : process ( rst, we, rd_in, rd_data_in ) begin 
    if rst = '0' then 
        reg_file( 0 ) <= ( others => '0' ); -- default value of x0 is 0, and it cannot be changed
    else
        if we = '1' then
            if rd_in /= "00000" then
--                 reg_file( 0 ) <= ( others => '0' );
--            else
                reg_file( to_integer( unsigned( rd_in ) ) ) <= rd_data_in; -- check if != works
            end if;
        end if;
    end if;
end process;
end Behavioral;