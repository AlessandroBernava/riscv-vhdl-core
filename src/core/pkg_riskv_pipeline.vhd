library ieee;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

package pkg_riskv_pipeline is

    type if_id_reg_t is record
        pc       : word_t;
        pc4      : word_t;
        instr_if : word_t;
    end record;

    type id_ex_reg_t is record
        -- indirizzi registri
        rs1_addr : reg_addr_t;
        rs2_addr : reg_addr_t;
        rd_addr  : reg_addr_t;
        -- dati
        pc       : word_t;                        --propagati
        pc4      : word_t;
        rs1_data : word_t;                        --prodotti in id
        rs2_data : word_t;
        imm_ext  : word_t;
        f3       : std_logic_vector(2 downto 0);
        f7b      : std_logic;
        opcode   : std_logic_vector(6 downto 0);
        -- controllo
        alu_op    : std_logic_vector(1 downto 0);  -- per ex
        alu_src_A : std_logic_vector(1 downto 0);
        alu_src_B : std_logic;
        isRtype   : std_logic;

        mem_read     : std_logic;                     --per mem
        mem_write    : std_logic;
        mem_size     : std_logic_vector(1 downto 0);
        mem_unsigned : std_logic;

        reg_write  : std_logic;                     -- per wb
        result_src : std_logic_vector(1 downto 0);  -- 00 ALU 01 memoria (load) 11 pc+4
    end record;

    type ex_mem_reg_t is record
        -- indirizzi registri

        rs2_addr : reg_addr_t;  -- per forwarding store in mem(aggiungere)
        rd_addr  : reg_addr_t;  -- passa per forwarding in mem: se c'e un hazard su rs2(l'istruzione prima scrive su rs2) il valore viene aggiornato - segnale che passa:write_data

        -- dati
        pc         : word_t;                        --propagati
        pc4        : word_t;
        alu_result : word_t;                        -- prodotto in ex
        rs2_data   : word_t;
        opcode     : std_logic_vector(6 downto 0);
        -- controllo
        mem_read     : std_logic;                     --per mem
        mem_write    : std_logic;
        mem_size     : std_logic_vector(1 downto 0);
        mem_unsigned : std_logic;

        reg_write  : std_logic;                     -- per wb
        result_src : std_logic_vector(1 downto 0);  -- 00 ALU 01 memoria (load) 11 pc+4
    end record;

    type mem_wb_reg_t is record

        -- indirizzi registri
        rd_addr : reg_addr_t;

        -- dati
        pc4        : word_t;  --propagati
        alu_result : word_t;  -- prodotto in ex - serve per scrivere il registr (R/I TYPE) o per formattare il dato per la load
        -- (addr_low_i => mem_wb.alu_result(1 downto 0))

        --   mem_data   : word_t; gestita direttamente dalla memeoria sincrona
        --mem_load_data : word_t;

        -- controllo
        mem_size     : std_logic_vector(1 downto 0);  -- per load_formatter
        mem_unsigned : std_logic;

        reg_write  : std_logic;                     -- per wb
        result_src : std_logic_vector(1 downto 0);  -- 00 ALU 01 memoria (load) 11 pc+4
    end record;

    -- costanti di reset registri

    constant ID_EX_REG_RESET : id_ex_reg_t := (
        rs1_addr     => (others => '0'),
        rs2_addr     => (others => '0'),
        rd_addr      => (others => '0'),
        pc           => (others => '0'),
        pc4          => (others => '0'),
        rs1_data     => (others => '0'),
        rs2_data     => (others => '0'),
        imm_ext      => (others => '0'),
        alu_op       => (others => '0'),
        f3           => (others => '0'),
        f7b          => '0',
        isRtype      => '0',
        opcode       => (others => '0'),
        alu_src_A    => (others => '0'),
        alu_src_B    => '0',
        mem_read     => '0',
        mem_write    => '0',
        mem_size     => (others => '0'),
        mem_unsigned => '0',
        reg_write    => '0',
        result_src   => (others => '0')
    );

    constant EX_MEM_REG_RESET : ex_mem_reg_t := (
        rs2_addr     => (others => '0'),
        rd_addr      => (others => '0'),
        pc           => (others => '0'),
        pc4          => (others => '0'),
        rs2_data     => (others => '0'),
        opcode       => (others => '0'),
        alu_result   => (others => '0'),
        mem_read     => '0',
        mem_write    => '0',
        mem_size     => (others => '0'),
        mem_unsigned => '0',
        reg_write    => '0',
        result_src   => (others => '0')
    );

    constant MEM_WB_REG_RESET : mem_wb_reg_t := (
        rd_addr    => (others => '0'),
        pc4        => (others => '0'),
        alu_result => (others => '0'),
        --mem_data   => (others => '0'),
        mem_size     => (others => '0'),
        mem_unsigned => '0',
        reg_write    => '0',
        result_src   => (others => '0')
    );

end package pkg_riskv_pipeline;
