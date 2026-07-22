library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_forwarding_unit is
end entity tb_forwarding_unit;

architecture tb of tb_forwarding_unit is
    signal rs1_addr_i_t      : reg_addr_t;                    --collegare a id_ex.rs1_addr
    signal rs2_addr_i_t      : reg_addr_t;                    --collegare a id_ex.rs2_addr
    signal rd_mem_i_t        : reg_addr_t;                    --collegare a ex_mem.rd_addr
    signal reg_write_mem_i_t : std_logic;
    signal rd_wb_i_t         : reg_addr_t;                    --collegare a mem_wb.rd_addr
    signal reg_write_wb_i_t  : std_logic;
    signal  forwardA_o_t     : std_logic_vector(1 downto 0);  --00 no forward, 01 da ex/mem, 01 da mem/ wb  controlla mux prima del mux alu_src_A
    signal  forwardB_o_t     : std_logic_vector(1 downto 0);

begin

    dut : entity work.forwarding_unit
    port map (
        rs1_addr_i      => rs1_addr_i_t,
        rs2_addr_i      => rs2_addr_i_t,
        rd_mem_i        => rd_mem_i_t,
        reg_write_mem_i => reg_write_mem_i_t,
        rd_wb_i         => rd_wb_i_t,
        reg_write_wb_i  => reg_write_wb_i_t,
        forwardA_o      => forwardA_o_t,
        forwardB_o      => forwardB_o_t
    );

    stim : process is
    begin
        rs1_addr_i_t <= "00011";
        rs2_addr_i_t <= "00011";
        rd_mem_i_t <= "00111";
        reg_write_mem_i_t <= '1';
        rd_wb_i_t <= "00111";
        reg_write_wb_i_t <= '1';

        wait for 10 ns;

        report " forward A out got " & to_bstring(forwardA_o_t)
        severity note;

        report " forward B out got " & to_bstring(forwardB_o_t)
        severity note;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
