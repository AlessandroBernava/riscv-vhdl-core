library ieee;
library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_register_file is
end entity tb_register_file;

architecture rtl of tb_register_file is
    signal   clk_t           : std_logic;
    signal     res_t         : std_logic;
    signal     we_t          : std_logic;
    signal     rs1_addr_i_t  : reg_addr_t;
    signal    rs2_addr_i_t   : reg_addr_t;
    signal    rd_addr_i_t    : reg_addr_t;
    signal    write_data_i_t : word_t;
    signal    rs1_data_o_t   : word_t;
    signal    rs2_data_o_t   : word_t;

begin

    dut : entity work.register_file
    port map (
        clk          => clk_t,
        res          => res_t,
        we           => we_t,
        rs1_addr_i   => rs1_addr_i_t,
        rs2_addr_i   => rs2_addr_i_t,
        rd_addr_i    => rd_addr_i_t,
        write_data_i => write_data_i_t,
        rs1_data_o   => rs1_data_o_t,
        rs2_data_o   => rs2_data_o_t
    );

    clk : process is
    begin
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';
        wait for 5 ns;
        clk_t <= '0';
        wait for 5 ns;
        clk_t <= '1';

        wait;
    end process clk;

    stim : process is
    begin
        res_t <= '0';
        we_t <= '0';

        rs1_addr_i_t <= (others => '0');
        rs2_addr_i_t <= (0 => '1', others => '0');
        rd_addr_i_t <= (2 => '1', others => '0');
        wait for 10 ns;
        report "rs1_data_o = " & to_hstring(rs1_data_o_t) severity note;
        report "rs2_data_o = " & to_hstring(rs2_data_o_t) severity note;
        wait for 10 ns;
        we_t <= '1';
        rs1_addr_i_t <= (others => '0');
        rd_addr_i_t <= "00011";
        write_data_i_t <= x"ABCA09FF";

        wait for 10 ns;
        we_t <= '0';
        rs2_addr_i_t <= "00011";
        wait for 10 ns;
        assert rs2_data_o_t = x"ABCA09FF"
        report "FAIL scrittura/lettura reg3: got " & to_hstring(rs2_data_o_t)
        severity error;

        wait for 10 ns;
        we_t <= '1';
        rd_addr_i_t <= REG_X0;
        write_data_i_t <= x"DDDDDDDD";
        wait for 10 ns;

        rs1_addr_i_t <= REG_X0;
        wait for 10 ns;

        assert rs1_data_o_t = x"00000000"
        report "FAIL lettura reg0: got " & to_hstring(rs1_data_o_t)
        severity error;
        wait for 10 ns;
        we_t <= '1';
        rd_addr_i_t <= "00101";
        write_data_i_t <= x"ABCA09FF";

        wait for 10 ns;
        we_t <= '1';
        rd_addr_i_t <= "00101";
        rs2_addr_i_t <= "00101";
        write_data_i_t <= x"DDDDDDDD";

        wait until rising_edge(clk_t);

        wait for 1 ns;
        wait for 10 ns;
        assert rs2_data_o_t = x"DDDDDDDD"
        report "FAIL scrittura reg3: got , if DDDDDDD, it forwarded nevertheless the we = 0 " & to_hstring(rs2_data_o_t)
        severity error;

        wait for 10 ns;
        we_t <= '1';
        rd_addr_i_t <= "00101";
        write_data_i_t <= x"AAAAAAAA";
        rs2_addr_i_t <= "00101";
        wait for 10 ns;
        assert rs2_data_o_t = x"AAAAAAAA"
        report "FAIL scrittura reg3: got ,it has not forwarded" & to_hstring(rs2_data_o_t)
        severity error;

        wait for 10 ns;
        rs2_addr_i_t <= "00101";
        rs1_addr_i_t <= "00011";
        wait for 10 ns;
        assert rs2_data_o_t = x"AAAAAAAA"
        report "FAIL scrittura reg3: got " & to_hstring(rs2_data_o_t)
        severity error;
        assert rs1_data_o_t = x"ABCA09FF"
        report "FAIL scrittura reg3: got " & to_hstring(rs1_data_o_t)
        severity error;

        res_t <= '1';
        wait for 20 ns;
        assert rs2_data_o_t = x"00000000"
        report "FAIL scrittura reg3: got ,it has not resetted" & to_hstring(rs2_data_o_t)
        severity error;
        assert rs1_data_o_t = x"00000000"
        report "FAIL scrittura reg3: got ,it has not resetted" & to_hstring(rs1_data_o_t)
        severity error;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture rtl;
