library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity load_unit is
    port (
        data_i           : in  word_t;
        mem_unsigned_i   : in  std_logic;
        mem_size_i       : in  std_logic_vector(1 downto 0);
        formatted_data_o : out word_t
    );
end entity load_unit;

architecture rtl of load_unit is

begin

    formatting : process (all) is
    begin
        if mem_unsigned_i = '1' then
            if mem_size_i = "00" then
                formatted_data_o <= (31 downto 8 => '0') & data_i(7 downto 0);
            elsif mem_size_i = "01" then
                formatted_data_o <= (31 downto 16 => '0') & data_i(15 downto 0);
            else
                formatted_data_o <= data_i;
            end if;
        else
            if mem_size_i = "00" then
                formatted_data_o <= (31 downto 8 => data_i(7)) & data_i(7 downto 0);
            elsif mem_size_i = "01" then
                formatted_data_o <= (31 downto 16 => data_i(15)) & data_i(15 downto 0);
            else
                formatted_data_o <= data_i;

            end if;
        end if;
    end process formatting;

end architecture rtl;
