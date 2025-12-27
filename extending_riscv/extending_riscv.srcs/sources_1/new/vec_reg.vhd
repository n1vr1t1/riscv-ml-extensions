library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vec_reg is
  Port (rst : in std_logic; -- active low
        clk : in std_logic;
        en : in std_logic; -- active low
        is_flt : in std_logic;
        vd_data_in : std_logic_vector ( 127 downto 0 );
        vd1_in : in std_logic_vector( 4 downto 0 );
        vd2_in : in std_logic_vector ( 3 downto 0 );
        v1 : in std_logic_vector( 4 downto 0 );
        v2 : in std_logic_vector( 4 downto 0 );
        v1_data : out std_logic_vector ( 127 downto 0 );
        v2_data : out std_logic_vector ( 127 downto 0 );
        is_v1_flt : out std_logic;
        is_v2_flt : out std_logic
  );
end vec_reg;

architecture Behavioral of vec_reg is
    type vec_file_type is array ( 0 to 31 ) of std_logic_vector( 127 downto 0 );
    signal vector_reg_file : vec_file_type;
    signal element_data_type : std_logic_vector ( 31 downto 0 );
begin

reading_process : process ( rst, clk ) begin
    if rst = '0' then
        v1_data <= ( others => '0' );
        v2_data <= ( others => '0' );
    else
        if rising_edge(clk) then 
            if en = '0' then
                v1_data <= vector_reg_file( to_integer( unsigned( v1 )));
                v2_data <= vector_reg_file( to_integer( unsigned( v2 )));
            else 
                v1_data <= ( others => '0' );
                v2_data <= ( others => '0' );
            end if;
        end if;
    end if;
end process;

writing_process : process ( clk ) begin
    if rising_edge( clk ) then
        if vd2_in(0) = '0' then
            vector_reg_file( to_integer( unsigned( vd1_in )))( 31 downto 0 ) <= vd_data_in(31 downto 0);
        end if;
        if vd2_in(1) = '0' then
            vector_reg_file( to_integer( unsigned( vd1_in )))( 63 downto 32 ) <= vd_data_in(63 downto 32);
        end if;
        if vd2_in(2) = '0' then
            vector_reg_file( to_integer( unsigned( vd1_in )))( 95 downto 64 ) <= vd_data_in(95 downto 64);
        end if;
        if vd2_in(3) = '0' then
            vector_reg_file( to_integer( unsigned( vd1_in )))( 127 downto 96 ) <= vd_data_in(127 downto 96);
        end if;
    end if;
end process;


end Behavioral;
