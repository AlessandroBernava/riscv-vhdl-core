library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_hazard_detection_unit is
end entity tb_hazard_detection_unit;

architecture tb of tb_hazard_detection_unit is
    signal opc_id_ex_i_t : std_logic_vector(6 downto 0);  --collegato con id_ex.opc
    signal  rs1_addr_i_t : reg_addr_t;                    --collegare a if_id.rs1_addr
    signal  rs2_addr_i_t : reg_addr_t;                    --collegare a if_id.rs2_addr
    signal  rd_addr_i_t  : reg_addr_t;                    -- collegare a id_ex.rd_addr
    signal  stall_o_t    : std_logic;

begin

    dut : entity work.hazard_detection_unit
    port map (
        opc_id_ex_i => opc_id_ex_i_t,
        rs1_addr_i  => rs1_addr_i_t,
        rs2_addr_i  => rs2_addr_i_t,
        rd_addr_i   => rd_addr_i_t,
        stall_o     => stall_o_t
    );

    stim : process is
    begin
        rs1_addr_i_t <= "00011";
        rs2_addr_i_t <= "00111";
        rd_addr_i_t <= "00111";
        opc_id_ex_i_t <= opc_load;

        wait for 10 ns;

        report " stall  out got " & std_logic'image(stall_o_t)
        severity note;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
