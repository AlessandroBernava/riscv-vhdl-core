
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_pipeline.all;
use work.pkg_riskv_types.all;

entity rv32i_core is
    port (
        res        : in  std_logic;
        clk        : in  std_logic;
        misaligned : out std_logic;

        dbg_pc    : out word_t;
        dbg_instr : out word_t;
        -- dbg_reg_we  : out std_logic;
        --dbg_rd_addr : out reg_addr_t;
        dbg_wr_data : out word_t;

        dbg_id_ex_we  : out std_logic;
        dbg_id_ex_rd  : out reg_addr_t;
        dbg_ex_mem_we : out std_logic;
        dbg_ex_mem_rd : out reg_addr_t;
        dbg_mem_wb_we : out std_logic;
        dbg_mem_wb_rd : out reg_addr_t;

        dbg_cu_we : out std_logic;
        dbg_cu_rd : out reg_addr_t;

        dbg_imm_ext_id_ex : out word_t;
        dbg_jump          : out std_logic;
        dbg_pctarget      : out word_t;
        dbg_pc4           : out word_t;

        dbg_stall : out std_logic;

        dbg_alu_result  : out word_t;
        dbg_byte_enable : out std_logic_vector(3 downto 0);
        dbg_mem_size    : out std_logic_vector(1 downto 0)
    );
end entity rv32i_core;

architecture rtl of rv32i_core is

    signal id_ex      : id_ex_reg_t;
    signal id_ex_new  : id_ex_reg_t;
    signal ex_mem     : ex_mem_reg_t;
    signal ex_mem_new : ex_mem_reg_t;
    signal mem_wb     : mem_wb_reg_t;
    signal mem_wb_new : mem_wb_reg_t;

    signal alu_ctrl         : std_logic_vector(3 downto 0);
    signal alu_op_a         : word_t;
    signal alu_op_b         : word_t;
    signal alu_result       : word_t;
    signal alu_result_zero  : std_logic;
    signal flush            : std_logic;
    signal instr            : word_t;
    signal instr_type       : instr_type_t;                  -- in input ad immediate generator
    signal byte_enable      : std_logic_vector(3 downto 0);
    signal mem_wb_load_data : word_t;
    signal forwardA         : std_logic_vector(1 downto 0);  -- controllo del forwarding
    signal forwardB         : std_logic_vector(1 downto 0);  -- controllo del forwarding
    signal rs1_forwarded    : word_t;                        -- rs1 dopo eventuale forwarding
    signal rs2_forwarded    : word_t;                        -- rs2 dopo eventuale forwarding
    signal stall            : std_logic;
    -- signal opcode           : std_logic_vector(6 downto 0);
    -- signal rs1_addr         : reg_addr_t;
    -- signal rs2_addr         : reg_addr_t;
    --signal rd_addr          : reg_addr_t;
    signal pc  : word_t;
    signal pc4 : word_t;
    -- signal id_ex_pc         : word_t; ridondante
    signal wb_load_data : word_t;
    signal jump         : std_logic;
    signal pc_target    : word_t;
    signal write_data   : word_t;     -- fare mux  controllato da mem_wb.result_src
    -- signal rs1_data         : word_t;
    -- signal rs2_data         : word_t;
    signal mem_store_data             : word_t;
    signal misaligned_store           : std_logic;
    signal misaligned_load            : std_logic;
    signal misaligned_store_effective : std_logic;
    signal misaligned_load_effective  : std_logic;
    signal is_load_wb                 : std_logic;

begin
    alu_ctrl_inst : entity work.alu_ctrl
    port map (
        aluop_i    => id_ex.alu_op,
        f3_i       => id_ex.f3,
        f7b_i      => id_ex.f7b,
        isrtype    => id_ex.isrtype,
        alu_ctrl_o => alu_ctrl
    );

    alu_inst : entity work.alu
    port map (
        a_i      => alu_op_a,
        b_i      => alu_op_b,
        alu_op_i => alu_ctrl,
        result_o => alu_result,
        zero_o   => alu_result_zero
    );

    branch_jump_unit_inst : entity work.branch_jump_unit
    port map (
        opc_i   => id_ex.opcode,
        f3_i    => id_ex.f3,
        zero_i  => alu_result_zero,
        data1_i => rs1_forwarded,    -- attenzione, se si usa id_ex.rs1_data, errore branch/jump in presenza di forwarding
        data2_i => rs2_forwarded,
        jump_o  => jump
    );

    control_unit_inst : entity work.control_unit
    port map (
        instr_i        => instr,
        rs1_addr_o     => id_ex_new.rs1_addr,
        rs2_addr_o     => id_ex_new.rs2_addr,
        rd_addr_o      => id_ex_new.rd_addr,
        imm_type_o     => instr_type,
        f3_o           => id_ex_new.f3,
        f7b_o          => id_ex_new.f7b,
        isrtype_o      => id_ex_new.isRtype,
        alu_op_o       => id_ex_new.alu_op,
        alu_src_a_o    => id_ex_new.alu_src_a,
        alu_src_b_o    => id_ex_new.alu_src_b,
        mem_read_o     => id_ex_new.mem_read,
        mem_write_o    => id_ex_new.mem_write,
        mem_size_o     => id_ex_new.mem_size,
        mem_unsigned_o => id_ex_new.mem_unsigned,
        reg_write_o    => id_ex_new.reg_write,
        result_src_o   => id_ex_new.result_src,
        opcode_o       => id_ex_new.opcode
    );

    data_memory_inst : entity work.data_memory
    port map (
        clk           => clk,
        res_i         => res,
        mem_read_i    => ex_mem.mem_read,
        mem_write_i   => ex_mem.mem_write,
        addr_i        => ex_mem.alu_result,  -- connettere alu result anche a mem_wb_new.alu_result
        write_data_i  => mem_store_data,
        byte_enable_i => byte_enable,        --byte enable segnale prodotto dalla store unit
        data_o        => mem_wb_load_data    -- dato in wb che viene formattato e messo nel registro in caso di load
    );

    forwarding_unit_inst : entity work.forwarding_unit
    port map (
        rs1_addr_i      => id_ex.rs1_addr,
        rs2_addr_i      => id_ex.rs2_addr,
        rd_mem_i        => ex_mem.rd_addr,
        reg_write_mem_i => ex_mem.reg_write,
        rd_wb_i         => mem_wb.rd_addr,
        reg_write_wb_i  => mem_wb.reg_write,
        forwardA_o      => forwardA,          --controlla mux in ex che produce aluopB, vedere appunti
        forwardB_o      => forwardB
    );

    hazard_detection_unit_inst : entity work.hazard_detection_unit
    port map (
        opc_ex_mem_i => ex_mem.opcode,
        rs1_addr_i   => id_ex.rs1_addr,
        rs2_addr_i   => id_ex.rs2_addr,
        rd_addr_i    => ex_mem.rd_addr,
        stall_o      => stall
    );

    immediate_generator_inst : entity work.immediate_generator
    port map (
        type_i  => instr_type,
        instr_i => instr,
        imm_o   => id_ex_new.imm_ext
    );

    instruction_memory_inst : entity work.instruction_memory
    port map (
        clk     => clk,
        res_i   => res,
        flush_i => flush,
        stall_i => stall,
        pc_i    => pc,
        pc_o    => id_ex_new.pc,
        pc4_o   => pc4,
        instr_o => instr
    );

    load_unit_inst : entity work.load_unit
    port map (
        data_i           => mem_wb_load_data,
        mem_unsigned_i   => mem_wb.mem_unsigned,
        mem_size_i       => mem_wb.mem_size,
        addr_low_i       => mem_wb.alu_result(1 downto 0),
        formatted_data_o => wb_load_data,
        misaligned_o     => misaligned_load
    );

    program_counter_inst : entity work.program_counter
    port map (
        clk         => clk,
        res_i       => res,
        stall_i     => stall,
        pc_sel_i    => jump,
        pc_target_i => pc_target,
        pc_o        => pc
    );

    register_file_inst : entity work.register_file
    port map (
        clk          => clk,
        res          => res,
        we           => mem_wb.reg_write,
        rs1_addr_i   => id_ex_new.rs1_addr,
        rs2_addr_i   => id_ex_new.rs2_addr,
        rd_addr_i    => mem_wb.rd_addr,
        write_data_i => write_data,
        rs1_data_o   => id_ex_new.rs1_data,
        rs2_data_o   => id_ex_new.rs2_data
    );

    store_unit_inst : entity work.store_unit
    port map (
        data_i           => ex_mem.rs2_data,
        mem_size_i       => ex_mem.mem_size,
        addr_low_i       => ex_mem.alu_result(1 downto 0),
        formatted_data_o => mem_store_data,
        byte_enable_o    => byte_enable,
        misaligned_o     => misaligned_store
    );

    is_load_wb <= '1' when mem_wb.result_src = "01" else '0';

    misaligned_load_effective <= misaligned_load  and is_load_wb;
    misaligned_store_effective <= misaligned_store;  -- solo dallo stadio MEM

    misaligned <= misaligned_store_effective or misaligned_load_effective;

    flush <= jump;   -- aggiornare in caso di logica di flush piu' complessa

    id_ex_reg : process (clk) is
    begin
        if (clk'event and clk = '1') then
            if (res = '1') then
                id_ex <= ID_EX_REG_RESET;
            elsif (stall = '0') then      -- scambiare flush e stall, prima deve esservi stall
                if (flush = '1') then
                    id_ex <= ID_EX_REG_RESET;
                else
                    id_ex <= id_ex_new;

                end if;
            end if;
        end if;
    end process id_ex_reg;

    -- EX/MEM e MEM/WB non gestiscono stall ne' flush:
    -- lo stall congela solo PC e IF/ID inserendo una bolla in ID/EX,
    -- le istruzioni gia' in EX/MEM e MEM/WB devono completare normalmente.
    -- Il flush annulla solo le istruzioni errate in IF e ID (dopo un branch taken),
    -- non quelle gia' avanzate oltre EX che hanno gia' prodotto risultati corretti
    -- edit: lo stall deve essere gestito

    ex_mem_reg : process (clk) is
    begin
        if (clk'event and clk = '1') then
            if (res = '1') then
                ex_mem <= EX_MEM_REG_RESET;
            elsif (stall = '1') then
                ex_mem <= EX_MEM_REG_RESET;
            else
                ex_mem <= ex_mem_new;
            end if;
        end if;
    end process ex_mem_reg;

    mem_wb_reg : process (clk) is
    begin
        if (clk'event and clk = '1') then
            if (res = '1') then
                mem_wb <= MEM_WB_REG_RESET;
            else
                mem_wb <= mem_wb_new;
            end if;
        end if;
    end process mem_wb_reg;

    ex_mem_new.alu_result <= alu_result;

    pc_target <= std_logic_vector(unsigned(id_ex.pc) + unsigned(id_ex.imm_ext)) --mux pc target
    when id_ex.opcode = OPC_BRANCH else
    alu_result and x"FFFFFFFE" when id_ex.opcode = OPC_JALR else
    alu_result;

    -- mux pre alu in ex
    rs1_forwarded <= id_ex.rs1_data when forwardA = "00" else
    ex_mem.alu_result               when forwardA = "01" else
    write_data;

    rs2_forwarded <= id_ex.rs2_data when forwardB = "00" else
    ex_mem.alu_result               when forwardB = "01" else      -- errore: se ho una load non devo prendere il risultato  da
    write_data;

    alu_op_a <= id_ex.pc             when id_ex.alu_src_a = "01" else
    (others => '0')                  when id_ex.alu_src_a = "10" else
    rs1_forwarded;

    alu_op_b <= rs2_forwarded when id_ex.alu_src_b = '0' else
    id_ex.imm_ext;

    -- mux in wb
    write_data <= mem_wb.alu_result when mem_wb.result_src = "00" else
    wb_load_data                    when mem_wb.result_src = "01" else           -- dato formattato per la load, mem_wb_load_data e' quello non formattato
    mem_wb.pc4;

    -- collegamenti diretti tra registri

    --  id_ex_new.pc <= id_ex_pc; id_ex_pc e ridondante
    id_ex_new.pc4 <= pc4;
    -- id_ex_new.opcode <= opcode; ridondante

    ex_mem_new.rs2_addr <= id_ex.rs2_addr;
    ex_mem_new.rd_addr <= id_ex.rd_addr;
    ex_mem_new.pc <= id_ex.pc;
    ex_mem_new.pc4 <= id_ex.pc4;
    ex_mem_new.rs2_data <= rs2_forwarded;    -- attenzione: id_ex:rs2_data e' sbagliato in caso di forwarding
    ex_mem_new.mem_read <= id_ex.mem_read;
    ex_mem_new.mem_size <= id_ex.mem_size;
    ex_mem_new.mem_unsigned <= id_ex.mem_unsigned;
    ex_mem_new.mem_write <= id_ex.mem_write;
    ex_mem_new.reg_write <= id_ex.reg_write;
    ex_mem_new.result_src <= id_ex.result_src;
    ex_mem_new.opcode <= id_ex.opcode;

    mem_wb_new.rd_addr <= ex_mem.rd_addr;
    mem_wb_new.alu_result <= ex_mem.alu_result;
    mem_wb_new.pc4 <= ex_mem.pc4;
    mem_wb_new.mem_size <= ex_mem.mem_size;
    mem_wb_new.mem_unsigned <= ex_mem.mem_unsigned;
    mem_wb_new.reg_write <= ex_mem.reg_write;
    mem_wb_new.result_src <= ex_mem.result_src;

    -- debug

    dbg_pc <= pc;
    dbg_instr <= instr;
    --dbg_reg_we <= mem_wb.reg_write;
    -- dbg_rd_addr <= mem_wb.rd_addr;
    dbg_wr_data <= write_data;

    dbg_id_ex_we <= id_ex.reg_write;
    dbg_id_ex_rd <= id_ex.rd_addr;
    dbg_ex_mem_we <= ex_mem.reg_write;
    dbg_ex_mem_rd <= ex_mem.rd_addr;
    dbg_mem_wb_we <= mem_wb.reg_write;
    dbg_mem_wb_rd <= mem_wb.rd_addr;

    dbg_cu_we <= id_ex_new.reg_write;
    dbg_cu_rd <= id_ex_new.rd_addr;
    -- nota sul presunto sfasamento tra reg_write e rd_addr in simulazione:
    -- All'avvio, la prima istruzione che entra in pipeline dopo il reset e' una NOP
    -- (addi x0, x0, 0), per cui la CU genera correttamente reg_write='1' e rd=x0
    -- (le istruzioni fetchate durante il reset sono  anch'esse NOP ma i registri di pipeline
    -- con res = '1' azzerano tutti i valori).
    -- Questo fa sembrare reg_write in anticipo di un ciclo rispetto a rd_addr,
    -- ma e' solo un effetto visivo: i due segnali viaggiano negli stessi registri
    -- di pipeline e vengono campionati sullo stesso fronte, e il reg_write a 1
    -- e' correttamente quello della prima NOP dopo il reset. La scrittura su x0
    -- viene comunque ignorata dal Register File per specifica RISC-V.

    dbg_imm_ext_id_ex <= id_ex.imm_ext;
    dbg_jump <= jump;
    dbg_pctarget <= pc_target;
    dbg_pc4 <= pc4;

    dbg_stall <= stall;

    dbg_alu_result <= ex_mem.alu_result;
    dbg_byte_enable <= byte_enable;

    dbg_mem_size <= mem_wb.mem_size;

end architecture rtl;
