
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
    signal ila_mem_addr   : word_t;
    signal ila_mem_we     : std_logic;
    signal ila_store_data : word_t;

    component ila_0
    port (
        clk : in std_logic;

        probe0 : in std_logic_vector(31 downto 0);
        probe1 : in std_logic_vector(31 downto 0);
        probe2 : in std_logic_vector(31 downto 0);
        probe3 : in std_logic_vector(0 downto 0);
        probe4 : in std_logic_vector(31 downto 0)
    );
end component;

component clk_wiz_0
port
(-- Clock in ports
    -- Clock out ports
    clk_out1 : out    std_logic;
    -- Status and control signals
    reset   : in  std_logic;
    locked  : out std_logic;
    clk_in1 : in  std_logic
);
end component  ;

begin

res_req <= not res_n or not clk_locked;--

-- RESET SYNCHRONIZER: per evitare metastabilita'

res_sync : process (clk_core)
begin
    if clk_core'event and clk_core = '1' then
        if res_req = '1' then
            res_pipe <= "11";
        else
            res_pipe(0) <= '0';
            res_pipe(1) <= res_pipe(0);
        end if;
    end if;
end process res_sync;

res_core <= res_pipe(1);

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

ila_inst : ila_0
port map (
    clk       => clk_core,
    probe0    => ila_pc,
    probe1    => ila_instr,
    probe2    => ila_mem_addr,
    probe3(0) => ila_mem_we,
    probe4    => ila_store_data
);

clk_wiz_inst : clk_wiz_0
port map (
    clk_in1  => clk,
    reset    => not res_n,  -- il clk wiz ha reset active high (?)
    clk_out1 => clk_core,
    locked   => clk_locked
);

-- ILA Vivado

ila_pc <= dbg_pc_instr;  -- pc allineato all'instr
ila_instr <= dbg_instr;
ila_mem_addr <= dbg_alu_result;
ila_mem_we <= dbg_ex_mem_we;
ila_store_data <= dbg_mem_store_data;

end architecture rtl;
