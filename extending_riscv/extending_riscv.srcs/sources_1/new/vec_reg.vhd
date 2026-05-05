library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vec_reg is
    Port( rst : in std_logic; -- active low
        clk : in std_logic;
        we : in std_logic; -- write enable for vector load and operations
        vd_data : std_logic_vector ( 127 downto 0 ); -- data to be written to vector register
        vd : in std_logic_vector( 4 downto 0 ); -- destination of the vector register
        vec_element : in std_logic_vector ( 3 downto 0 ); -- indicates which elements to be written
        v1 : in std_logic_vector( 4 downto 0 ); -- source vector register 1
        v2 : in std_logic_vector( 4 downto 0 ); -- source vector register 2
        v3 : in std_logic_vector( 4 downto 0 ); -- source vector register 3
        v1_data : out std_logic_vector ( 127 downto 0 ); -- output data of source vector register 1
        v2_data : out std_logic_vector ( 127 downto 0 ); -- output data of source vector register 2
        v3_data : out std_logic_vector ( 127 downto 0 )); -- output data of source vector register 3
end vec_reg;

architecture Behavioral of vec_reg is
    type vec_file_type is array ( 0 to 31 ) of std_logic_vector( 127 downto 0 );
    signal vector_reg_file : vec_file_type;
begin

reading_process : process ( rst, clk ) begin
    if rst = '0' then
        v1_data <= ( others => '0' );
        v2_data <= ( others => '0' );
        v3_data <= ( others => '0' );
    else
        if rising_edge( clk ) then 
            v1_data <= vector_reg_file( to_integer( unsigned( v1 )));
            v2_data <= vector_reg_file( to_integer( unsigned( v2 )));
            v3_data <= vector_reg_file( to_integer( unsigned( v3 )));
        end if;
    end if;
end process;

writing_process : process ( vd, vec_element, vd_data, we ) begin
    if we = '1' then
        if vec_element(0) = '1' then
            vector_reg_file( to_integer( unsigned( vd )))( 31 downto 0 ) <= vd_data(31 downto 0);
        end if;
        if vec_element(1) = '1' then
            vector_reg_file( to_integer( unsigned( vd )))( 63 downto 32 ) <= vd_data(63 downto 32);
        end if;
        if vec_element(2) = '1' then
            vector_reg_file( to_integer( unsigned( vd )))( 95 downto 64 ) <= vd_data(95 downto 64);
        end if;
        if vec_element(3) = '1' then
            vector_reg_file( to_integer( unsigned( vd )))( 127 downto 96 ) <= vd_data(127 downto 96);
        end if;
    end if;
end process;

end Behavioral;
