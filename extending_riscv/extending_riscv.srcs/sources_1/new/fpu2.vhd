library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fpu2 is
  Port (
    fp        : in  std_logic;
    opcode    : in  STD_LOGIC_VECTOR (1 downto 0);
    operand_1 : in  STD_LOGIC_VECTOR (31 downto 0);
    operand_2 : in  STD_LOGIC_VECTOR (31 downto 0);
    output    : out STD_LOGIC_VECTOR (31 downto 0)
  );
end fpu2;

architecture Behavioral of fpu2 is
begin
process(fp, opcode, operand_1, operand_2)
    variable s1, s2        : std_logic;
    variable e1, e2        : integer;
    variable m1_24, m2_24  : unsigned(23 downto 0);
    variable result_sign   : std_logic;
    variable result_exp    : integer range -1024 to 1024;
    variable aligned_a, aligned_b : unsigned(48-1 downto 0);
    variable sum_sub       : signed(48 downto 0);
    variable prod48        : unsigned(47 downto 0);
    variable out_mant23    : unsigned(22 downto 0);
    variable out_word      : std_logic_vector(31 downto 0);
    variable exp_diff      : integer;
    variable i             : integer;
  begin
    out_word := (others => '0');

    if fp = '1' then
      s1 := operand_1(31);
      s2 := operand_2(31);
      e1 := to_integer(unsigned(operand_1(30 downto 23)));
      e2 := to_integer(unsigned(operand_2(30 downto 23)));

      -- if exponent=0, operand is treated as 0
      if e1 = 0 then
        m1_24 := (others => '0');
      else
        m1_24 := "1" & unsigned(operand_1(22 downto 0));
      end if;

      if e2 = 0 then
        m2_24 := (others => '0');
      else
        m2_24 := "1" & unsigned(operand_2(22 downto 0));
      end if;

      case opcode is
        when "00" =>
          if (m1_24 = 0 and e1 = 0) then
            out_word := operand_2;
          elsif (m2_24 = 0 and e2 = 0) then
            out_word := operand_1;
          else
            aligned_a(23 downto 0) := (others => '0');
            aligned_b(23 downto 0) := (others => '0');
            aligned_a(47 downto 24) := resize(m1_24, 24);
            aligned_b(47 downto 24) := resize(m2_24, 24);

            exp_diff := e1 - e2;
            if exp_diff > 0 then
              if exp_diff >= 48 then
                aligned_b := (others => '0');
              else
                aligned_b := shift_right(aligned_b, exp_diff);
              end if;
              result_exp := e1;
            elsif exp_diff < 0 then
              if -exp_diff >= 48 then
                aligned_a := (others => '0');
              else
                aligned_a := shift_right(aligned_a, -exp_diff);
              end if;
              result_exp := e2;
            else
              result_exp := e1;
            end if;

            if s1 = s2 then
              sum_sub := signed('0' & aligned_a) + signed('0' & aligned_b);
              result_sign := s1;
            else
              if aligned_a >= aligned_b then
                sum_sub := signed('0' & aligned_a) - signed('0' & aligned_b);
                result_sign := s1;
              else
                sum_sub := signed('0' & aligned_b) - signed('0' & aligned_a);
                result_sign := s2;
              end if;
            end if;

            if sum_sub = 0 then
              out_word := (others => '0');
            else
              if sum_sub(48) = '1' then
                sum_sub := shift_right(sum_sub, 1);
                result_exp := result_exp + 1;
              else
                for i in 0 to 46 loop
                  exit when sum_sub(47) = '1';
                  sum_sub := shift_left(sum_sub, 1);
                  result_exp := result_exp - 1;
                end loop;
              end if;

              out_mant23 := unsigned(sum_sub(46 downto 24));
              if result_exp <= 0 then
                -- underflow -> zero (flush-to-zero)
                out_word := (others => '0');
              elsif result_exp >= 255 then
                -- overflow -> inf
                out_word := (others => '0');
                out_word(31) := result_sign;
                out_word(30 downto 23) := (others => '1'); -- exp=255
              else
                out_word(31) := result_sign;
                out_word(30 downto 23) := std_logic_vector(to_unsigned(result_exp, 8));
                out_word(22 downto 0) := std_logic_vector(out_mant23);
              end if;
            end if;
          end if;


        when "01" =>
          s2 := not s2;
          if (m1_24 = 0 and e1 = 0) then
            out_word := operand_2;
            out_word(31) := not operand_2(31);
          elsif (m2_24 = 0 and e2 = 0) then
            out_word := operand_1;
          else
            aligned_a := (others => '0');
            aligned_b := (others => '0');
            aligned_a(47 downto 24) := resize(m1_24, 24);
            aligned_b(47 downto 24) := resize(m2_24, 24);

            exp_diff := e1 - e2;
            if exp_diff > 0 then
              if exp_diff >= 48 then
                aligned_b := (others => '0');
              else
                aligned_b := shift_right(aligned_b, exp_diff);
              end if;
              result_exp := e1;
            elsif exp_diff < 0 then
              if -exp_diff >= 48 then
                aligned_a := (others => '0');
              else
                aligned_a := shift_right(aligned_a, -exp_diff);
              end if;
              result_exp := e2;
            else
              result_exp := e1;
            end if;

            if s1 = s2 then
              sum_sub := signed('0' & aligned_a) + signed('0' & aligned_b);
              result_sign := s1;
            else
              if aligned_a >= aligned_b then
                sum_sub := signed('0' & aligned_a) - signed('0' & aligned_b);
                result_sign := s1;
              else
                sum_sub := signed('0' & aligned_b) - signed('0' & aligned_a);
                result_sign := s2;
              end if;
            end if;

            if sum_sub = 0 then
              out_word := (others => '0');
            else
              if sum_sub(48) = '1' then
                sum_sub := shift_right(sum_sub, 1);
                result_exp := result_exp + 1;
              else
                for i in 0 to 48-2 loop
                  exit when sum_sub(48-1) = '1';
                  sum_sub := shift_left(sum_sub, 1);
                  result_exp := result_exp - 1;
                end loop;
              end if;

              if result_exp <= 0 then
                out_word := (others => '0');
              elsif result_exp >= 255 then
                out_word := (others => '0');
                out_word(31) := result_sign;
                out_word(30 downto 23) := (others => '1'); -- inf
              else
                out_mant23 := unsigned(sum_sub(48-2 downto 48-24));
                out_word(31) := result_sign;
                out_word(30 downto 23) := std_logic_vector(to_unsigned(result_exp, 8));
                out_word(22 downto 0) := std_logic_vector(out_mant23);
              end if;
            end if;
          end if;

        when "10" =>  -- multiply
          if (m1_24 = 0 or m2_24 = 0) then
            out_word := (others => '0');
          else
            result_sign := s1 xor s2;
            prod48 := m1_24 * m2_24;
            result_exp := e1 + e2 - 127;

            if prod48(47) = '1' then
              prod48 := shift_right(prod48, 1);
              result_exp := result_exp + 1;
            end if;

            out_mant23 := prod48(46 downto 24);

            if result_exp <= 0 then
              out_word := (others => '0');
            elsif result_exp >= 255 then
              out_word := (others => '0');
              out_word(31) := result_sign;
              out_word(30 downto 23) := (others => '1');
            else
              out_word(31) := result_sign;
              out_word(30 downto 23) := std_logic_vector(to_unsigned(result_exp, 8));
              out_word(22 downto 0) := std_logic_vector(out_mant23);
            end if;
          end if;

        when others =>
          out_word := (others => '0');

      end case;

    else
      out_word := (others => '0');
    end if;

    -- drive output
    output <= out_word;
  end process;

end Behavioral;
