
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_program_counter is
end entity tb_program_counter;

architecture tb of tb_program_counter is

    signal clk_t        : std_logic;
    signal res_t        : std_logic;
    signal  stall_t     : std_logic;
    signal  pc_sel_t    : std_logic;
    signal  pc_target_t : word_t;
    signal  pc_o_t      : word_t;
    constant clk_period : time := 10 ns;

begin

    dut : entity work.program_counter
    port map (
        clk         => clk_t,
        res_i       => res_t,
        stall_i     => stall_t,
        pc_sel_i    => pc_sel_t,
        pc_target_i => pc_target_t,
        pc_o        => pc_o_t
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
        --reset
        res_t <= '1';
        pc_sel_t <= '0';
        pc_target_t <= x"EEAAEEAA";

        wait for clk_period;
        assert pc_o_t = x"00000000"
        report "FAIL reset PC: got " & to_hstring(pc_o_t);
        -- aggiornamento pc+4
        res_t <= '0';
        stall_t <= '0';

        wait for clk_period;

        assert pc_o_t = x"00000004"
        report "FAIL PC+4: got " & to_hstring(pc_o_t);

        -- stall
        res_t <= '0';
        stall_t <= '1';

        wait for clk_period;

        assert pc_o_t = x"00000004"
        report "FAIL stall: got " & to_hstring(pc_o_t);

        -- branch/jump
        res_t <= '0';
        stall_t <= '0';
        pc_sel_t <= '1';

        wait for clk_period;

        assert pc_o_t = x"EEAAEEAA"
        report "FAIL branch/jump: got " & to_hstring(pc_o_t);

        report "*** ALL TESTS DONE ***"
        severity note;
        wait;

    end process stim;

end architecture tb;
