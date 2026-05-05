library ieee;
  use ieee.numeric_std.all;
  use ieee.std_logic_1164.all;

entity constants_example is
  port (
    clk   : in    std_logic;
    reset : in    std_logic;
    sel   : in    std_logic_vector(1 downto 0);
    data  : out   std_logic_vector(31 downto 0)
  );
end entity constants_example;

architecture rtl of constants_example is

  CONSTANT c_zero  : std_logic_vector(31 downto 0) := x"00000000";
  CONSTANT c_one   : std_logic_vector(31 downto 0) := x"00000001";
  CONSTANT c_nop   : std_logic_vector(31 downto 0) := x"00000013";
  CONSTANT c_magic : std_logic_vector(31 downto 0) := x"deadbeef";

  signal reg_data : std_logic_vector(31 downto 0);

begin

  u_process_1 : process (clk, reset) is
  begin

    if (reset = '1') then
      reg_data <= (others => '0');
    elsif (clk'EVent and clk = '1') then

      case sel is

        when "00" =>

          reg_data <= c_zero;

        when "01" =>

          reg_data <= c_one;

        when "10" =>

          reg_data <= c_nop;

        when others =>

          reg_data <= c_magic;

      end case;

    end if;

  end process u_process_1;

  data <= reg_data;

end architecture rtl;
