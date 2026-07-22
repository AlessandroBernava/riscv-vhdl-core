
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_immediate_generator is
end entity tb_immediate_generator;

architecture tb of tb_immediate_generator is

    signal type_t      : instr_type_t;
    signal    instr_t  : word_t;
    signal     imm_o_t : word_t;

begin

    dut : entity work.immediate_generator
    port map (
        type_i  => type_t,
        instr_i => instr_t,
        imm_o   => imm_o_t
    );

    stim : process is
    begin
        -- I
        type_t <= I_TYPE;
        instr_t <= x"00500093";
        wait for 10 ns;
        assert imm_o_t = x"00000005"
        report "FAIL TYPE I immediate: got " & to_hstring(imm_o_t);

        --S
        type_t <= S_TYPE;
        instr_t <= x"0020A423";
        wait for 10 ns;
        assert imm_o_t = x"00000008"
        report "FAIL TYPE S immediate: got " & to_hstring(imm_o_t);

        --B
        type_t <= B_TYPE;
        instr_t <= x"FE1FF0E3";   -- beq x1, x1, -4  (esempio realistico)
        wait for 10 ns;
        assert imm_o_t = x"FFFFFFFC"
        report "FAIL TYPE B negative immediate: got " & to_hstring(imm_o_t);

        -- U
type_t  <= B_TYPE;
instr_t <= x"00408063";   -- beq x1, x0, 8  (offset +8 byte)
wait for 10 ns;
assert imm_o_t = x"00000008"
    report "FAIL TYPE B positive immediate: got " & to_hstring(imm_o_t);

        --J
        type_t <= J_TYPE;
        instr_t <= x"FF1FF0EF";   -- jal x1, -16  (esempio di J con offset negativo)
        wait for 10 ns;
        assert imm_o_t = x"FFFFFFF0"
        report "FAIL TYPE J negative immediate: got " & to_hstring(imm_o_t);

        --R

        type_t <= R_TYPE;
        instr_t <= x"002081B3";
        wait for 10 ns;
        assert imm_o_t = x"00000000"
        report "FAIL TYPE R immediate: got " & to_hstring(imm_o_t);

        report "*** ALL TESTS DONE ***"
        severity note;

        wait;
    end process stim;

end architecture tb;
