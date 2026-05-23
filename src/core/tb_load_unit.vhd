library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_load_unit is
end entity tb_load_unit;

architecture tb of tb_load_unit is
    signal   data_i_t          : word_t;
    signal   mem_unsigned_i_t  : std_logic;
    signal  mem_size_i_t       : std_logic_vector(1 downto 0);
    signal    addr_low_i_t     : std_logic_vector(1 downto 0);
    signal  formatted_data_o_t : word_t;
    signal misaligned_o_t      : std_logic;

begin

    dut : entity work.load_unit
    port map (
        data_i           => data_i_t,
        mem_unsigned_i   => mem_unsigned_i_t,
        mem_size_i       => mem_size_i_t,
        addr_low_i       => addr_low_i_t,
        formatted_data_o => formatted_data_o_t,
        misaligned_o     => misaligned_o_t
    );

    stim : process is
    begin
        data_i_t <= x"ABCDEF71";
        mem_unsigned_i_t <= '1';
        mem_size_i_t <= "00";
        addr_low_i_t <= "11";

        wait for 10 ns;

        report " formatted load data got " & to_hstring(formatted_data_o_t)
        severity note;
        report " misaligned got " & std_logic'image(misaligned_o_t)
        severity note;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
