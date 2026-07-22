
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_data_memory is
end entity  tb_data_memory;

architecture tb of tb_data_memory is

    signal   clk_t         : std_logic;
    signal  res_t          : std_logic;
    signal  mem_read_i_t   : std_logic;
    signal  mem_write_i_t  : std_logic;
    signal  addr_i_t       : word_t;
    signal  write_data_i_t : word_t;
    signal       data_o_t  : word_t;
    signal byte_enable_t   : std_logic_vector(3 downto 0);
    constant clk_period    : time := 10 ns;

begin

    dut : entity work.data_memory
    port map (
        clk           => clk_t,
        res_i         => res_t,
        mem_read_i    => mem_read_i_t,
        mem_write_i   => mem_write_i_t,
        addr_i        => addr_i_t,
        write_data_i  => write_data_i_t,
        byte_enable_i => byte_enable_t,
        data_o        => data_o_t
    );

    clk_gen : process is
    begin

        clk_t <= '0';
        wait for clk_period / 2;
        clk_t <= '1';
        wait for clk_period / 2;

    end process  clk_gen;

    stim : process is
    begin
        res_t <= '0';
        mem_read_i_t <= '1';
        mem_write_i_t <= '1';
        addr_i_t <= x"000002FF";
        write_data_i_t <= x"AABCDEF1";
        byte_enable_t <= "1001";
        wait for 10 ns;

        report " data out got " & to_hstring(data_o_t)
        severity note;

        res_t <= '0';
        mem_read_i_t <= '1';
        mem_write_i_t <= '1';
        addr_i_t <= x"000001FF";
        write_data_i_t <= x"02220001";

        wait for 10 ns;

        report " data out got " & to_hstring(data_o_t)
        severity note;

        res_t <= '0';
        mem_read_i_t <= '1';
        mem_write_i_t <= '1';
        addr_i_t <= x"000001FF";
        write_data_i_t <= x"00000005";

        wait for 10 ns;

        report " data out got " & to_hstring(data_o_t)
        severity note;

        res_t <= '0';
        mem_read_i_t <= '1';
        mem_write_i_t <= '1';
        addr_i_t <= x"000002FF";
        byte_enable_t <= "1101";
        write_data_i_t <= x"ABCDEF56";

        wait for 10 ns;

        report " data out got " & to_hstring(data_o_t)
        severity note;

        res_t <= '0';
        mem_read_i_t <= '1';
        mem_write_i_t <= '1';
        addr_i_t <= x"000002FF";
        write_data_i_t <= x"AAAAAAAA";
        byte_enable_t <= "0010";

        wait for 10 ns;
        report " data out got " & to_hstring(data_o_t)
        severity note;

        res_t <= '0';
        mem_read_i_t <= '1';
        mem_write_i_t <= '0';
        addr_i_t <= x"000002FF";
        write_data_i_t <= x"00000005";

        wait for 10 ns;

        report " data out got " & to_hstring(data_o_t)
        severity note;

        report "*** ALL TESTS DONE ***"
        severity note;
        wait;

    end process stim;

end architecture tb;
