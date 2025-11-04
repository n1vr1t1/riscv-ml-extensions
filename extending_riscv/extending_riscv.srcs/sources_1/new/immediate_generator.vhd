library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity immediate_generator is
    Port (rst : in std_logic;
          clk : in std_logic;
--          stall : in std_logic;
          flush : in std_logic; --active low
          opcode : in STD_LOGIC_VECTOR (6 downto 0);
          funct3 : in STD_LOGIC_VECTOR (2 downto 0);
          instruction : in STD_LOGIC_VECTOR (31 downto 7); -- reduce the instruction signal to exclude opcode part
          immediate : out STD_LOGIC_VECTOR (31 downto 0));
end immediate_generator;

architecture Behavioral of immediate_generator is
begin
process ( rst, clk ) begin
	if rst = '0' then 
		immediate <= (others => '0');
	elsif rising_edge( clk ) then 
	   if flush = '0' then
	       case opcode is
	           when "0010011" => -- immediate
	               case funct3 is
                       when "000" =>
                           immediate( 11 downto 0 ) <= instruction( 31 downto 20 ); 
                           immediate( 31 downto 12 ) <= ( others => instruction(31) );
                       when others => 
                           immediate( 4 downto 0 ) <= instruction( 24 downto 20 ); 
                           immediate( 31 downto 5 ) <= ( others => '0' );
                    end case;
	           when "0100011" => -- store (normal)
	               immediate(10 downto 5) <= instruction(30 downto 25);
                   immediate(4 downto 0) <= instruction(11 downto 7);
                   immediate(31 downto 11) <= ( others => instruction(31) );
	           when "0100111" => -- fsw
	               immediate(10 downto 5) <= instruction(30 downto 25);
                   immediate(4 downto 0) <= instruction(11 downto 7);
                   immediate(31 downto 11) <= ( others => instruction(31) );
	           when "0000011" => -- load
	               immediate(10 downto 0) <= instruction(30 downto 20); 
                   immediate(31 downto 11) <= (others=>instruction(31));
	           when "0000111" => -- flw
	               immediate(10 downto 0) <= instruction(30 downto 20); 
                   immediate(31 downto 11) <= (others=>instruction(31));
	           when "1100011" => -- branch
	               immediate(0) <= '0';
                   immediate(4 downto 1) <= instruction(11 downto 8);
                   immediate(10 downto 5) <= instruction(30 downto 25);
                   immediate(11) <= instruction(7);
                   immediate(31 downto 12) <= ( others => instruction(31) );
	           when "1101111" => -- jump and link
	               immediate(0) <= '0';
                   immediate(10 downto 1) <= instruction(30 downto 21);
                   immediate(11) <= instruction(20);
                   immediate(19 downto 12) <= instruction(19 downto 12);
                   immediate(31 downto 20) <= ( others => instruction(31) );
	           when "0110111" => -- lui
	               immediate( 31 downto 12 ) <= instruction( 31 downto 12 );
                   immediate( 11 downto 0 ) <= (others => '0');
	           when others => immediate <= ( others => '0' );
	       end case;
--            if opcode = "0010011" then --immediate
--                if funct3 = "000" then
--                    immediate( 11 downto 0 ) <= instruction( 31 downto 20 ); 
--                    immediate( 31 downto 12 ) <= ( others => instruction(31) );
--                else --funct3 = "001" or funct3 = "101" for srli and slli
--                    immediate( 4 downto 0 ) <= instruction( 24 downto 20 ); 
--                    immediate( 31 downto 5 ) <= ( others => '0' );
--                end if;
--            elsif opcode = "0100011" or opcode = "0100111" then --store or fsw
--                immediate(10 downto 5) <= instruction(30 downto 25);
--                immediate(4 downto 0) <= instruction(11 downto 7);
--                immediate(31 downto 11) <= ( others => instruction(31) );
--            elsif opcode = "0000011" or opcode = "0000111" then --load or flw
--                immediate(10 downto 0) <= instruction(30 downto 20); 
--                immediate(31 downto 11) <= (others=>instruction(31));
--            elsif opcode = "1100011" then --branch
--                immediate(0) <= '0';
--                immediate(4 downto 1) <= instruction(11 downto 8);
--                immediate(10 downto 5) <= instruction(30 downto 25);
--                immediate(11) <= instruction(7);
--                immediate(31 downto 12) <= ( others => instruction(31) );
--            elsif opcode = "1101111" then --jump
--                immediate(0) <= '0';
--                immediate(10 downto 1) <= instruction(30 downto 21);
--                immediate(11) <= instruction(20);
--                immediate(19 downto 12) <= instruction(19 downto 12);
--                immediate(31 downto 20) <= ( others => instruction(31) );
--            elsif opcode = "0110111" then -- lui
--                immediate( 31 downto 12 ) <= instruction( 31 downto 12 );
--                immediate( 11 downto 0 ) <= (others => '0');
--            else 
--                immediate <= ( others => '0' );
--            end if;
       else 
            immediate <= ( others => '0' );
       end if;
    end if;
end process;
end Behavioral;