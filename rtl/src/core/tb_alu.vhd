
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_alu is
end entity tb_alu;

architecture tb of tb_alu is

    signal a_t, b_t : word_t;
    signal alu_op_t : std_logic_vector(3 downto 0);
    signal result_t : word_t;
    signal zero_t   : std_logic;

begin

    dut : entity work.alu
    port map (
        a_i      => a_t,
        b_i      => b_t,
        alu_op_i => alu_op_t,
        result_o => result_t,
        zero_o   => zero_t
    );

    stim : process is
    begin
        a_t <= (others => '0');
        b_t <= (others => '0');
        alu_op_t <= ALU_ADD;
        wait for 10 ns;
        a_t <= x"00000005";
        b_t <= x"00000002";
        alu_op_t <= ALU_ADD;

        wait for 10 ns;
        assert result_t = x"00000007"
        report "FAIL ADD 5+2"
        severity error;
        assert zero_t = '0'
        report "FAIL ADD zero flag"
        severity error;
        wait for 10 ns;

        a_t <= x"00000005";
        b_t <= x"00000005";
        alu_op_t <= ALU_SUB;

        wait for 10 ns;
        assert result_t = x"00000000"
        report "FAIL SUB 5-5"
        severity error;
        assert zero_t = '1'
        report "FAIL SUB zero flag"
        severity error;

        a_t <= x"00000005";
        b_t <= x"00000005";
        alu_op_t <= ALU_SUB;

        wait for 10 ns;
        assert result_t = x"00000000"
        report "FAIL SUB 5-5"
        severity error;
        assert zero_t = '1'
        report "FAIL SUB zero flag"
        severity error;

        a_t <= x"00000000";
        b_t <= x"FFFFFFFF";
        alu_op_t <= ALU_SUB;

        wait for 10 ns;
        assert result_t = x"00000001"
        report "FAIL SUB 0-1"
        severity error;
        assert zero_t = '0'
        report "FAIL SUB zero flag"
        severity error;

        a_t <= x"00000000";
        b_t <= x"00000001";
        alu_op_t <= ALU_SUB;

        wait for 10 ns;
        assert result_t = x"FFFFFFFF"
        report "FAIL SUB 0-1"
        severity error;
        assert zero_t = '0'
        report "FAIL SUB zero flag"
        severity error;

        a_t <= x"F0F0F0FF";
        b_t <= x"0F0F0F0F";
        alu_op_t <= ALU_AND;

        wait for 10 ns;
        assert result_t = x"0000000F"
        report "FAIL AND"
        severity error;

        a_t <= x"FFFFFFFF";
        b_t <= x"0000001F";
        alu_op_t <= ALU_SLL;

        wait for 10 ns;
        assert result_t = x"80000000"
        report "FAIL SLL"
        severity error;

        a_t <= x"80000000";
        b_t <= x"00000003";
        alu_op_t <= ALU_SRA;

        wait for 10 ns;
        assert result_t = x"F0000000"
        report "FAIL SRA"
        severity error;

        a_t <= x"FFFFFFFF";
        b_t <= x"00000001";
        alu_op_t <= ALU_SLT;

        wait for 10 ns;
        assert result_t = x"00000001"
        report "FAIL SLT"
        severity error;
        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
