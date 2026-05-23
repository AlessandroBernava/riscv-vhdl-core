
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_pipeline.all;
use work.pkg_riskv_types.all;

entity tb_control_unit is
end entity tb_control_unit;

architecture tb of tb_control_unit is

    signal     instr_i_t       : word_t;
    signal    rs1_addr_o_t     : reg_addr_t;
    signal    rs2_addr_o_t     : reg_addr_t;
    signal    rd_addr_o_t      : reg_addr_t;
    signal    imm_type_o_t     : instr_type_t;
    signal    f3_o_t           : std_logic_vector(2 downto 0);
    signal    f7b_o_t          : std_logic;
    signal     alu_op_t        : std_logic_vector(1 downto 0);
    signal    alu_src_a_o_t    : std_logic_vector(1 downto 0);
    signal    alu_src_b_o_t    : std_logic;
    signal    mem_read_o_t     : std_logic;                     -- per mem
    signal    mem_write_o_t    : std_logic;
    signal   mem_size_o_t      : std_logic_vector(1 downto 0);
    signal    mem_unsigned_o_t : std_logic;
    signal    reg_write_o_t    : std_logic;                     -- per wb
    signal   result_src_o_t    : std_logic_vector(1 downto 0);

begin

    dut : entity work.control_unit
    port map (
        instr_i        => instr_i_t,
        rs1_addr_o     => rs1_addr_o_t,
        rs2_addr_o     => rs2_addr_o_t,
        rd_addr_o      => rd_addr_o_t,
        imm_type_o     => imm_type_o_t,
        f3_o           => f3_o_t,
        f7b_o          => f7b_o_t,
        alu_op         => alu_op_t,
        alu_src_a_o    => alu_src_a_o_t,
        alu_src_b_o    => alu_src_b_o_t,
        mem_read_o     => mem_read_o_t,
        mem_write_o    => mem_write_o_t,
        mem_size_o     => mem_size_o_t,
        mem_unsigned_o => mem_unsigned_o_t,
        reg_write_o    => reg_write_o_t,
        result_src_o   => result_src_o_t
    );

    stim : process is
    begin
        instr_i_t <= x"02022283";
        wait for 10 ns;

        -- assert rs1_addr_o_t = "00001"
        report " rs1_addr_o_t got " & to_bstring(rs1_addr_o_t)
        severity error;

        --assert  rs2_addr_o_t = "00010"
        report " rs2_addr_o_t got " & to_bstring(rs2_addr_o_t)
        severity error;

        --  assert  rd_addr_o_t = "00011"
        report " rd_addr_o_t got " & to_bstring(rd_addr_o_t)
        severity error;

        --assert  imm_type_o_t = R_TYPE
        report "  imm_type_o_t got " & instr_type_t'image(imm_type_o_t)
        severity error;

        -- assert f3_o_t = "000"
        report " f3_o_t got " & to_bstring(f3_o_t)
        severity error;

        --  f7b_o_t = "0000000"
        -- report "FAIL f7b_o_t"
        -- severity error;

        -- assert  alu_op_t = "10"
        report " alu_op_t got " & to_bstring(alu_op_t)
        severity error;

        -- assert  alu_src_a_o_t = "00"
        report " alu_src_a_o_t got " & to_bstring(alu_src_a_o_t)
        severity error;

        -- assert  alu_src_b_o_t = '0'
        report " alu_src_b_o_t got " & std_logic'image(alu_src_b_o_t)
        severity error;

        -- assert  mem_read_o_t = '0'
        report " mem_read_o_tv got " & std_logic'image(mem_read_o_t)
        severity error;

        --  assert  mem_write_o_t = '0'
        report " mem_write_o_t got " & std_logic'image(mem_write_o_t)
        severity error;

        -- assert  mem_size_o_t = "00"
        report " mem_size_o_t got " & to_bstring(mem_size_o_t)
        severity error;

        --assert  mem_unsigned_o_t = '0'
        report " mem_unsigned_o_t got " & std_logic'image(mem_unsigned_o_t)
        severity error;

        -- assert  reg_write_o_t = '1'
        report " reg_write_o_t got " & std_logic'image(reg_write_o_t)
        severity error;

        -- assert  result_src_o_t = "00"
        report " result_src_o_t got " & to_bstring(result_src_o_t)
        severity error;

        report "*** ALL TESTS DONE ***" severity note;
        wait;
    end process stim;

end architecture tb;
