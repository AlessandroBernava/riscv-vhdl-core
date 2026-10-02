
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_pipeline.all;
use work.pkg_riskv_types.all;

entity fpga_top is
    port (
        res_n    : in  std_logic;
        clk      : in  std_logic;
        led_pass : out std_logic
        --   led_debug      : out std_logic_vector(3 downto 0)

    );
end entity fpga_top;

architecture rtl of fpga_top is
    signal clk_core   : std_logic;
    signal clk_locked : std_logic;
    signal res_core   : std_logic;
    signal res_req    : std_logic;
    signal res_pipe   : std_logic_vector(1 downto 0);

    signal dbg_pc       : word_t;
    signal dbg_instr    : word_t;
    signal dbg_pc_instr : word_t;
    -- dbg_reg_we  : out std_logic;
    --dbg_rd_addr : out reg_addr_t;
    signal   dbg_wr_data : word_t;

    signal   dbg_id_ex_we       : std_logic;
    signal   dbg_id_ex_rd       : reg_addr_t;
    signal   dbg_id_ex_rs1_addr : reg_addr_t;
    signal   dbg_id_ex_rs2_addr : reg_addr_t;
    signal   dbg_ex_mem_we      : std_logic;
    signal   dbg_ex_mem_rd      : reg_addr_t;
    signal   dbg_mem_wb_we      : std_logic;
    signal   dbg_mem_wb_rd      : reg_addr_t;

    signal   dbg_cu_we : std_logic;
    signal   dbg_cu_rd : reg_addr_t;

    signal   dbg_imm_ext_id_ex : word_t;
    signal   dbg_jump          : std_logic;
    signal   dbg_pctarget      : word_t;
    signal    dbg_pc4          : word_t;

    signal    dbg_stall : std_logic;

    signal   dbg_alu_result  : word_t;
    signal   dbg_byte_enable : std_logic_vector(3 downto 0);
    signal   dbg_mem_size    : std_logic_vector(1 downto 0);

    signal   dbg_mem_store_data : word_t;
    --   signal debug_bus            : std_logic_vector(127 downto 0);

    signal led_reg        : word_t;
    signal ila_pc         : word_t;
    signal ila_instr      : word_t;
    signal ila_mem_addr   : reg_addr_t;
    signal ila_mem_we     : std_logic;
    signal ila_store_data : word_t;

begin

    res_req <= not res_n or not clk_locked;

    -- RESET SYNCHRONIZER: per evitare metastabilita'

    res_sync : process (clk_core)
    begin
        if clk_core'event and clk = '1' then
            if res_req = '1' then
                res_req <= "11";
            else
                res_req(0) <= '0';
                res_req(1) <= res_req(0);
            end if;
        end if;
    end process res_sync;

    res_core <= res_req(1);

    rv32i_core_inst : entity work.rv32i_core
    port map (
        clk                => clk_core,
        res                => res_core,
        led_reg            => led_reg,
        dbg_pc             => dbg_pc,
        dbg_instr          => dbg_instr,
        dbg_pc_instr       => dbg_pc_instr,
        dbg_wr_data        => dbg_wr_data,
        dbg_id_ex_we       => dbg_id_ex_we,
        dbg_id_ex_rd       => dbg_id_ex_rd,
        dbg_id_ex_rs1_addr => dbg_id_ex_rs1_addr,
        dbg_id_ex_rs2_addr => dbg_id_ex_rs2_addr,
        dbg_ex_mem_we      => dbg_ex_mem_we,
        dbg_ex_mem_rd      => dbg_ex_mem_rd,
        dbg_cu_we          => dbg_cu_we,
        dbg_cu_rd          => dbg_cu_rd,
        dbg_imm_ext_id_ex  => dbg_imm_ext_id_ex,
        dbg_jump           => dbg_jump,
        dbg_pctarget       => dbg_pctarget,
        dbg_pc4            => dbg_pc4,
        dbg_stall          => dbg_stall,
        dbg_alu_result     => dbg_alu_result,
        dbg_byte_enable    => dbg_byte_enable,
        dbg_mem_size       => dbg_mem_size,
        dbg_mem_store_data => dbg_mem_store_data
    );

    -- MMIO

    led_pass <= led_reg(0);

    -- ILA Vivado

    ila_pc <= dbg_pc_instr;  -- pc allineato all'instr
    ila_instr <= dbg_instr;
    ila_mem_addr <= dbg_alu_result;
    ila_mem_we <= dbg_ex_mem_we;
    ila_store_data <= dbg_mem_store_data;

    ila_inst : entity work.ila_0
    port map (
        clk    => clk_core,
        probe0 => ila_pc,
        probe1 => ila_instr,
        probe2 => ila_mem_addr,
        probe3 => ila_mem_we,
        probe4 => ila_store_data
    );

    clk_wiz_inst : entity work.clk_wiz_0
    port map (
        clk_in1  => clk,
        reset    => res_n,
        clk_out1 => clk_core,
        locked   => clk_locked
    );
end architecture rtl;
