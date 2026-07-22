
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_instruction_memory is
end entity tb_instruction_memory;

architecture tb of tb_instruction_memory is

    signal   clk_t      : std_logic;
    signal  res_t       : std_logic;
    signal  flush_t     : std_logic;
    signal stall_t      : std_logic;
    signal   pc_t       : word_t;
    signal pc4_t        : word_t;
    signal   instr_o_t  : word_t;
    constant clk_period : time := 10 ns;

begin

    dut : entity work.instruction_memory
    port map (
        clk     => clk_t,
        res_i   => res_t,
        flush_i => flush_t,
        stall_i => stall_t,
        pc_i    => pc_t,
        pc4_o   => pc4_t,
        instr_o => instr_o_t
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

        pc_t <= (others => '0');
        res_t <= '0';
        flush_t <= '0';
        stall_t <= '0';
        wait for 10 ns;
        assert instr_o_t = x"00500093"
        report "FAIL lettura PC instr 0: got " & to_hstring(instr_o_t);
        pc_t <= x"00000004";
        res_t <= '0';
        flush_t <= '0';
        stall_t <= '1';
        wait for 10 ns;

        assert instr_o_t = x"00300113"
        report "FAIL lettura PC instr 1 : got " & to_hstring(instr_o_t);

        pc_t <= x"00000008";
        stall_t <= '0';
        wait for 10 ns;
        assert instr_o_t = x"002081B3"
        report "FAIL lettura PC instr 2: got " & to_hstring(instr_o_t);

        pc_t <= x"00000010";
        wait for 10 ns;
        assert instr_o_t = x"00000013"
        report "FAIL lettura PC instr NOP: got " & to_hstring(instr_o_t);

        report "*** ALL TESTS DONE ***"
        severity note;
        wait;

    end process stim;

end architecture tb;
