
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_branch_jump_unit is
end entity tb_branch_jump_unit;

architecture tb of tb_branch_jump_unit is
    signal  opc_i_t     : std_logic_vector(6 downto 0);
    signal   f3_i_t     : std_logic_vector(2 downto 0);
    signal   zero_i_t   : std_logic;
    signal    data1_i_t : word_t;
    signal    data2_i_t : word_t;
    signal   jump_o_t   : std_logic;

begin

    dut : entity work.branch_jump_unit
    port map (
        opc_i   => opc_i_t,
        f3_i    => f3_i_t,
        zero_i  => zero_i_t,
        data1_i => data1_i_t,
        data2_i => data2_i_t,
        jump_o  => jump_o_t
    );

    stim : process is
    begin

        opc_i_t <= opc_branch;
        f3_i_t <= "110";
        zero_i_t <= '0';
        data1_i_t <= x"FFFFFFFF";
        data2_i_t <= x"00000001";

        wait for 10 ns;
        report " jump got " & std_logic'image(jump_o_t)
        severity note;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
