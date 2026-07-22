
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_alu_ctrl is
end entity tb_alu_ctrl;

architecture tb of tb_alu_ctrl is
    signal  aluop_i_t    : std_logic_vector(1 downto 0);
    signal    f3_i_t     : std_logic_vector(2 downto 0);
    signal   f7b_i_t     : std_logic;
    signal   isrtype_t   : std_logic;
    signal  alu_ctrl_o_t : std_logic_vector(3 downto 0);

begin

    dut : entity work.alu_ctrl
    port map (
        aluop_i    => aluop_i_t,
        f3_i       => f3_i_t,
        f7b_i      => f7b_i_t,
        isrtype    => isrtype_t,
        alu_ctrl_o => alu_ctrl_o_t
    );

    stim : process is
    begin
        -- load
        aluop_i_t <= "10";
        f3_i_t <= "101";
        f7b_i_t <= '1';
        isrtype_t <= '0';
        wait for 10 ns;
        report " alu_ctrl_o_t got " & to_bstring(alu_ctrl_o_t)
        severity note;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
