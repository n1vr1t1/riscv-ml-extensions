library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity immediate_generator is
    Port (rst : in std_logic;
          clk : in std_logic;
--          stall : in std_logic;
          flush : in std_logic; --active low
          opcode : in STD_LOGIC_VECTOR( 6 downto 0 );
          funct3 : in STD_LOGIC_VECTOR( 2 downto 0 );
          immediate : out STD_LOGIC_VECTOR( 31 downto 0 ));
end immediate_generator;

architecture Behavioral of immediate_generator is
begin
process ( rst, clk )
begin
	if rst = '0' then 
		immediate <= ( others => '0' );
	elsif rising_edge( clk ) then
        if flush = '0' then
	        case opcode is
	            when "0010011" => -- immediate
	                if funct3 = "001" or funct3 = "101" then -- srli, slli
                        immediate( 4 downto 0 ) <= instruction( 24 downto 20 ); 
                        immediate( 31 downto 5 ) <= ( others => '0' );
                    else
                        immediate( 11 downto 0 ) <= instruction( 31 downto 20 ); 
                        immediate( 31 downto 12 ) <= ( others => instruction( 31 ));
                    end if;
	            when "0100011" => -- store (normal) 
	               immediate( 10 downto 5 ) <= instruction( 30 downto 25 );
                   immediate( 4 downto 0 ) <= instruction( 11 downto 7 );
                   immediate( 31 downto 11 ) <= ( others => instruction( 31 ));
	            when "0100111" => -- vector and float store
                    if funct3 = "010" then -- fsw
                        immediate( 10 downto 5 ) <= instruction( 30 downto 25 );
                        immediate( 4 downto 0 ) <= instruction( 11 downto 7 );
                        immediate( 31 downto 11 ) <= ( others => instruction( 31 ));
                    else -- vector store does not have immediate in the instruction, so immediate is 0, to prevent unneeded memory offset
                        immediate <= ( others => '0' );
                    end if;
	            when "0000011" => -- load
	               immediate( 10 downto 0 ) <= instruction( 30 downto 20 ); 
                   immediate( 31 downto 11 ) <= ( others=>instruction( 31 ));
	            when "0000111" => -- vector load and flw
                    if funct3 = "010" then -- flw
                        immediate( 10 downto 0 ) <= instruction( 30 downto 20 ); 
                        immediate( 31 downto 11 ) <= ( others => instruction( 31 ));
                    else -- for other instructions, assuming the default 0 immediate this is because for vlm.v,
	                    -- we are assuming that the value in the normal register does not need to be operated on to get the correct memory location
                        immediate <= ( others => '0' );
                    end if;
	            when "1100011" => -- branch
	                immediate( 0 ) <= '0';
                    immediate( 4 downto 1 ) <= instruction( 11 downto 8 );
                    immediate( 10 downto 5 ) <= instruction( 30 downto 25 );
                    immediate( 11 ) <= instruction( 7 );
                    immediate( 31 downto 12 ) <= ( others => instruction( 31 ));
	            when "1101111" => -- jump and link
                    immediate( 0 ) <= '0';
                    immediate( 10 downto 1 ) <= instruction( 30 downto 21 );
                    immediate( 11 ) <= instruction( 20 );
                    immediate( 19 downto 12 ) <= instruction( 19 downto 12 );
                    immediate( 31 downto 20 ) <= ( others => instruction( 31 ));
                when "1100111" => -- jalr
                    immediate( 10 downto 0 ) <= instruction( 30 downto 20 ); 
                    immediate( 31 downto 11 ) <= ( others => instruction( 31 )); 
	            when "0110111" => -- lui
                    immediate( 31 downto 12 ) <= instruction( 31 downto 12 );
                    immediate( 11 downto 0 ) <= ( others => '0' );
                when "1010111" => -- vector immediate
                    immediate( 4 downto 0 ) <= instruction( 19 downto 15 );
                    immediate( 31 downto 5 ) <= ( others => '0' );
	            when others => immediate <= ( others => '0' );
	       end case;
        else 
            immediate <= ( others => '0' );
        end if;
    end if;
end process;
end Behavioral;