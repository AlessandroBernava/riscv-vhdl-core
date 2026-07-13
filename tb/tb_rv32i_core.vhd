
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_rv32i_core is
end entity  tb_rv32i_core;

architecture tb of tb_rv32i_core is

    signal   res_t        : std_logic;
    signal   clk_t        : std_logic;
    signal   misaligned_t : std_logic;

    signal dbg_pc_t     : word_t;
    signal dbg_instr_t  : word_t;
    signal dbg_reg_we_t : std_logic;
    signal dbg_rd_t     : std_logic_vector(4 downto 0);
    signal dbg_data_t   : word_t;

    signal dbg_id_ex_we_t   : std_logic;
    signal dbg_id_ex_rd_t   : reg_addr_t;
    signal dbg_ex_mem_we_t  : std_logic;
    signal dbg_ex_mem_rd_t  : reg_addr_t;
    signal  dbg_mem_wb_we_t : std_logic;
    signal dbg_mem_wb_rd_t  : reg_addr_t;

    signal dbg_cu_we_t : std_logic;
    signal dbg_cu_rd_t : reg_addr_t;

    signal dbg_imm_ext_id_ex_t : word_t;
    signal      dbg_jump_t     : std_logic;
    signal   dbg_pctarget_t    : word_t;
    signal   dbg_pc4_t         : word_t;

    signal dbg_stall_t : std_logic;      -- debug load+use / stall

    signal dbg_alu_result_t  : word_t;
    signal dbg_byte_enable_t : std_logic_vector(3 downto 0);

    signal dbg_mem_size_t   : std_logic_vector(1 downto 0);
    signal dbg_misaligned_t : std_logic;

    signal dbg_id_ex_rs1_addr_t : reg_addr_t;
    signal dbg_id_ex_rs2_addr_t : reg_addr_t;

    constant ESC    : string := character'val(27) & "[";
    constant RED    : string := ESC & "31m";
    constant GREEN  : string := ESC & "32m";
    constant YELLOW : string := ESC & "33m";
    constant BLUE   : string := ESC & "34m";
    constant RESET  : string := ESC & "0m";

    constant clk_period : time := 10 ns;

begin

    dut : entity work.rv32i_core
    port map (
        res        => res_t,
        clk        => clk_t,
        misaligned => misaligned_t,

        dbg_pc    => dbg_pc_t,
        dbg_instr => dbg_instr_t,
        -- dbg_reg_we  => dbg_reg_we_t,
        --  dbg_rd_addr => dbg_rd_t,
        dbg_wr_data => dbg_data_t,

        dbg_id_ex_we  => dbg_id_ex_we_t,
        dbg_id_ex_rd  => dbg_id_ex_rd_t,
        dbg_ex_mem_we => dbg_ex_mem_we_t,
        dbg_ex_mem_rd => dbg_ex_mem_rd_t,
        dbg_mem_wb_we => dbg_mem_wb_we_t,
        dbg_mem_wb_rd => dbg_mem_wb_rd_t,

        dbg_cu_we => dbg_cu_we_t,
        dbg_cu_rd => dbg_cu_rd_t,

        dbg_imm_ext_id_ex => dbg_imm_ext_id_ex_t,
        dbg_jump          => dbg_jump_t,
        dbg_pctarget      => dbg_pctarget_t,
        dbg_pc4           => dbg_pc4_t,

        dbg_stall => dbg_stall_t,

        dbg_alu_result  => dbg_alu_result_t,
        dbg_byte_enable => dbg_byte_enable_t,

        dbg_mem_size => dbg_mem_size_t,

        dbg_id_ex_rs1_addr => dbg_id_ex_rs1_addr_t,
        dbg_id_ex_rs2_addr => dbg_id_ex_rs2_addr_t
    );

    clk_gen : process is
    begin

        clk_t <= '0';
        wait for clk_period / 2;
        clk_t <= '1';
        wait for clk_period / 2;

    end process  clk_gen;

    stim : process is
    begin
        res_t <= '1';
        wait for CLK_PERIOD * 3;
        res_t <= '0';

        wait for CLK_PERIOD * 30_000;

        -- Stampa stato finale
        report "Simulazione completata" severity note;
        std.env.stop;
        wait;

    end process stim;

    -- stampa ad ogni clock cosa succede

    monitor : process
    alias regs_tb is
        << signal dut.register_file_inst.reg : reg_file_t >>;
        alias alu_tb is
        << signal dut.alu_inst.a_i : word_t >>;
        alias alu2_tb is
        << signal dut.alu_inst.b_i : word_t >>;

        alias mem_tb is
        << signal dut.data_memory_inst.mem : data_mem_t >>;

        alias forwardA_tb is
        << signal dut.forwardA : std_logic_vector(1 downto 0) >>;

        alias forwardB_tb is
        << signal dut.forwarding_unit_inst.forwardB_o : std_logic_vector(1 downto 0) >>;

        alias AluSrcA_tb is
        << signal dut.control_unit_inst.alu_src_a_o : std_logic_vector(1 downto 0) >>;

        alias rs1_forwarded_tb is
        << signal dut.rs1_forwarded : word_t>>;

        --   alias id_ers1data_tb is
        -- << signal dut.id_ex.rs1_data : word_t >>;

    begin

        wait until rising_edge(clk_t);
        wait for 1 ns;
        if res_t = '0'  or res_t = '1' then
            /*
            report "PC=" & to_hstring(dbg_pc_t) &
            " INSTR=" & to_hstring(dbg_instr_t) &
            " WE=" & std_logic'image(dbg_reg_we_t) &
            " RD=x" & to_hstring("000" & dbg_rd_t) &
            " DATA=" & to_hstring(dbg_data_t)
            severity note; */
            report
            GREEN & "PC="  & to_hstring(dbg_pc_t) & RESET& YELLOW & " INSTR = " & to_hstring(dbg_instr_t) & RESET &
            " | ID/EX WE=" & std_logic'image(dbg_id_ex_we_t) &
            " RD=" & to_bstring(dbg_id_ex_rd_t) &
            " Rs1=" & to_bstring(dbg_id_ex_rs1_addr_t) &
            " Rs2=" & to_bstring(dbg_id_ex_rs2_addr_t) &
            " | EX/MEM WE=" & std_logic'image(dbg_ex_mem_we_t) &
            " RD=" & to_bstring(dbg_ex_mem_rd_t) &
            " | MEM/WB WE=" & std_logic'image(dbg_mem_wb_we_t) &
            " RD=" & to_bstring(dbg_mem_wb_rd_t) &
            " | WR_DATA=" & to_hstring(dbg_data_t) &
            " cu we=" & std_logic'image(dbg_cu_we_t) &
            " cu rd=" & to_hstring(dbg_cu_rd_t) &
            " imm_ext ID_EX=" & to_hstring(dbg_imm_ext_id_ex_t) &
            " jump=" & std_logic'image(dbg_jump_t) &
            " pc target=" & to_hstring(dbg_pctarget_t) &
            " pc+4=" & to_hstring(dbg_pc4_t) &
            " stall=" & std_logic'image(dbg_stall_t) &
            " alu_result=" & to_hstring(dbg_alu_result_t) &
            " byte enable=" & to_bstring(dbg_byte_enable_t) &
            " mem size=" & to_bstring(dbg_mem_size_t) &
            " misaligned=" & std_logic'image(misaligned_t) &
            " forwardA=" & to_bstring(forwardA_tb) &
            " forwardB=" & to_bstring(forwardB_tb) &
            " AluSrcA=" & to_bstring(AluSrcA_tb) &
            " rs1_forwarded=" & to_hstring(rs1_forwarded_tb)
            --  " id_ex_rs1data=" & to_hstring(id_ers1data_tb)
            severity note;

        end if;

        report " alu op 1: " & to_hstring(alu_tb)
        severity note;

        report " alu op 2: " & to_hstring(alu2_tb)
        severity note;

        report  RED & "  [REGS]" &  RESET & " x1=" & to_hstring(regs_tb(1)) &
        "  x2=" & to_hstring(regs_tb(2)) &
        "  x3=" & to_hstring(regs_tb(3)) &
        "  x4=" & to_hstring(regs_tb(4)) &
        "  x5=" & to_hstring(regs_tb(5)) &
        "  x6=" & to_hstring(regs_tb(6)) &
        "  x7=" & to_hstring(regs_tb(7)) &
        "  x8=" & to_hstring(regs_tb(8)) &
        "  x9=" & to_hstring(regs_tb(9)) &
        "  x10=" & to_hstring(regs_tb(10)) &
        "  x11=" & to_hstring(regs_tb(11)) &
        "  x12=" & to_hstring(regs_tb(12)) &
        "  x13=" & to_hstring(regs_tb(13)) &
        "  x14=" & to_hstring(regs_tb(14)) &
        "  x15=" & to_hstring(regs_tb(15)) &
        "  x16=" & to_hstring(regs_tb(16)) &
        "  x17=" & to_hstring(regs_tb(17))
        severity note;

        report "data_mem_tb(40) = 0x" & to_hstring(mem_tb(40))
        severity note;

        report "data_mem_tb(41) = 0x" & to_hstring(mem_tb(41))
        severity note;

        report "data_mem_tb(42) = 0x" & to_hstring(mem_tb(42))
        severity note;
        report "data_mem_tb(43) = 0x" & to_hstring(mem_tb(43))
        severity note;
        report "data_mem_tb(44) = 0x" & to_hstring(mem_tb(44))
        severity note;
        report "data_mem_tb(45) = 0x" & to_hstring(mem_tb(45))
        severity note;
        report "data_mem_tb(46) = 0x" & to_hstring(mem_tb(46))
        severity note;
        report "data_mem_tb(47) = 0x" & to_hstring(mem_tb(47))
        severity note;
        report "data_mem_tb(48) = 0x" & to_hstring(mem_tb(48))
        severity note;
        report "data_mem_tb(49) = 0x" & to_hstring(mem_tb(49))
        severity note;

        report "data_mem_tb(0065) = 0x" & to_hstring(mem_tb(65))
        severity note;

        report "data_mem_tb(1000) = 0x" & to_hstring(mem_tb(1000))
        severity note;

        report "data_mem_tb(999) = 0x" & to_hstring(mem_tb(999))
        severity note;

        report "data_mem_tb(998) = 0x" & to_hstring(mem_tb(998))
        severity note;

        report "data_mem_tb(997) = 0x" & to_hstring(mem_tb(997))
        severity note;

        report "data_mem_tb(996) = 0x" & to_hstring(mem_tb(996))
        severity note;

        report "data_mem_tb(995) = 0x" & to_hstring(mem_tb(995))
        severity note;

    end process monitor;
end architecture tb;

-- DEBUG NOTE:
--  Procedura usata per trovare il bug sul branch / ALU_SRC_B:
--
--  1) Osservazione del sintomo:
--     - Alcune istruzioni di branch (BEQ/BNE) si comportavano in modo
--       apparentemente "invertito" (salto quando non dovevano e viceversa).
--     - Il comportamento dipendeva dai registri coinvolti (es. beq x3,x7
--       diverso da bne x2,x5), quindi non era un errore banale sull'opcode.
--
--  2) Raccolta dati con il monitor:
--     - Ho aggiunto stampe di debug per PC, istruzione, jump, zero,
--       valori dei registri, ecc. per vari cicli di clock.
--     - Ho verificato che il flag zero della ALU fosse sempre coerente
--       con il risultato della sottrazione (zero = '1' solo se il risultato
--       era 0). Questo mi ha permesso di escludere la ALU e la
--       branch_jump_unit come causa primaria.
--
--  3) Ipotesi sul problema:
--     - Se zero e' giusto ma il branch prende decisioni sbagliate, allora
--       il confronto deve essere fatto sui dati sbagliati (operandi errati
--       in ingresso alla ALU), non sulla logica BEQ/BNE.
--
--  4) Verifica degli operandi:
--     - Ho iniziato a stampare gli ingressi della ALU (in particolare
--       alu_op_a e alu_op_b dopo il forwarding).
--     - Ho osservato che alu_op_b risultava SEMPRE uguale a 8,
--       indipendentemente dai registri che mi aspettavo (rs2, immediato).
--       Questo indicava chiaramente un problema nel mux degli operandi B
--       o nel segnale di controllo ALUSRCB.
--
--  5) Risalita alla sorgente del controllo:
--     - Partendo da alu_op_b ho risalito il percorso:
--       forwarding -> mux B della ALU -> segnale id_ex.alusrcb ->
--       uscita alu_src_b_o della control unit.
--     - Nella control unit ho trovato la riga:
--
--           alu_src_b_o <= '0' when opcode = OPC_OP else
--                           '1';
--
--       che forzava ALUSRCB = '1' (immediato) per TUTTE le istruzioni
--       diverse dalle R-type, incluse le branch (OPC_BRANCH).
--       Di conseguenza, per le branch la ALU confrontava rs1 con
--       l'immediato invece che con rs2, e il flag zero risultava corretto
--       rispetto a rs1 - imm, ma sbagliato rispetto a rs1 - rs2.
--
--  6) Correzione:
--     - Ho modificato la logica della CU in modo che per le branch
--       (OPC_BRANCH) ALUSRCB valga '0', usando quindi rs2 come
--       operando B della ALU:
--
--           alu_src_b_o <= '0' when (opcode = OPC_OP or opcode = OPC_BRANCH) else
--                           '1';
--
--     - Dopo la correzione, alu_op_b non e' piu' fisso a 8, le branch
--       confrontano effettivamente rs1 e rs2, e BEQ/BNE si comportano
--       correttamente in tutti i casi di prova.
