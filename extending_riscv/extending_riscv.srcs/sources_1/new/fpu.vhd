library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

entity fpu is
  Port (fp : in std_logic;
        opcode : in STD_LOGIC_VECTOR (1 downto 0);
        operand_1 : in STD_LOGIC_VECTOR (31 downto 0);
        operand_2 : in STD_LOGIC_VECTOR (31 downto 0);
        output : out STD_LOGIC_VECTOR (31 downto 0));
end fpu;

architecture Behavioral of fpu is

  -- Correct IEEE 754 to real conversion
    function flt_to_real( x : std_logic_vector( 31 downto 0 ) ) return real is
        variable sign      : real;
        variable exponent  : integer;
        variable frac      : real;
        variable div : real;
        variable result    : real;
    begin
        exponent := to_integer(unsigned(x(30 downto 23)));
        frac := 1.0;
        div := 0.5;
        
        if exponent = 0 or exponent = 255 then
            result := 0.0;
            return result;
        end if;
        
        for i in 0 to 22 loop
            if x(22 - i) = '1' then
                frac := frac + div;
            end if;
            div := div / 2.0;
        end loop;
        
        if x(31) = '1' then
            sign := -1.0;
        else
            sign := 1.0;
        end if;
        
        result := sign * frac * (2.0 ** real(exponent - 127));
        
        frac := 0.0;
        return result;
    end function;

    -- Correct real to IEEE 754 conversion (normal numbers only)
    function real_to_flt( x : real ) return std_logic_vector is
        variable result   : std_logic_vector(31 downto 0) := (others => '0');
        variable exp     : integer;
        variable mant    : real;
        variable mant_int : integer;
--        constant MANT_MAX : real    := 2.0 - (1.0 / real(2 ** (23)));
    begin
        if x < 0.0 then
            result(31) := '1';
            mant := -x;
        else
            result(31) := '0';
            mant := x;
        end if;
        
        if mant = 0.0 then
            result(30 downto 0) := (others => '0');
        else
            while mant < 1.0 loop
              exp  := exp - 1;
              mant := mant * 2.0;
            end loop;
            while mant > 2.0 loop
              exp  := exp + 1;
              mant := mant / 2.0;
            end loop;
    
            mant := mant - 1.0;
            mant_int := integer(mant * real(2 ** (23)));  -- implicit round-to-nearest
            result(22 downto 0) := std_logic_vector(to_unsigned(mant_int, 23));
    
            exp := exp + 127;
            result(30 downto 23) := std_logic_vector(to_unsigned(exp, 8));
        end if;

        return result;
    end function;

begin

process (fp, opcode, operand_1, operand_2)
    variable A_fp, B_fp, result_fp : real;
begin
    if fp ='1' then 
        A_fp := flt_to_real(operand_1);
        B_fp := flt_to_real(operand_2);
        case opcode is
            when "00" =>
                result_fp := A_fp + B_fp;
            when "01" => 
                result_fp := A_fp - B_fp;
            when "10" =>
                result_fp := A_fp * B_fp;
            when others => 
                result_fp := 0.0;
        end case;
--        if opcode = "00" then -- add
--            result_fp := A_fp + B_fp;
--        elsif opcode = "01" then -- sub
--            result_fp := A_fp - B_fp;
--        elsif opcode = "10" then --mul
--            result_fp := A_fp * B_fp;
--        else
--            result_fp := 0.0;
--        end if;
        output <= real_to_flt(result_fp);
     else
        output <= ( others => '0' );
    end if;
end process;

end Behavioral;