/*
    Questo package definisce i tipi di dati e le costanti utilizzati nel progetto RISC-V. In particolare, include:
    - La definizione del tipo word_t come un vettore di 32 bit, che rappresenta una parola di dati.
    - Le costanti per gli opcode delle istruzioni RISC-V, che identificano il tipo di operazione da eseguire.
    - Le costanti per i codici ALU, che identificano univocamente l'operazione logico-aritmetica che l'ALU deve eseguire, facilitando la decodifica hardware nell'ALU Decoder.
*/

library ieee;
use ieee.std_logic_1164.all;

package pkg_riskv_types is

    subtype word_t is std_logic_vector(31 downto 0);
    subtype reg_addr_t is std_logic_vector(4 downto 0);
    type reg_file_t is array (31 downto 0) of word_t;

    constant INSTR_MEM_SIZE : integer := 1024;
    type instr_mem_t is array (0 to INSTR_MEM_SIZE -1) of word_t;

    constant DMEM_SIZE : integer := 1024;
    type data_mem_t is array (0 to DMEM_SIZE -1) of word_t;

    constant REG_X0    : reg_addr_t := "00000";
    constant INSTR_NOP : word_t := x"00000013";

    type instr_type_t is (R_TYPE, I_TYPE, S_TYPE, B_TYPE, U_TYPE, J_TYPE);

    -- opcodes
    constant opc_load   : std_logic_vector(6 downto 0) := "0000011";
    constant opc_op_imm : std_logic_vector(6 downto 0) := "0010011";
    constant opc_auipc  : std_logic_vector(6 downto 0) := "0010111";
    constant opc_store  : std_logic_vector(6 downto 0) := "0100011";
    constant opc_op     : std_logic_vector(6 downto 0) := "0110011";
    constant opc_lui    : std_logic_vector(6 downto 0) := "0110111";
    constant opc_branch : std_logic_vector(6 downto 0) := "1100011";
    constant opc_jal    : std_logic_vector(6 downto 0) := "1101111";
    constant opc_jalr   : std_logic_vector(6 downto 0) := "1100111";

    -- ALU Code (bit(30) & funct3): Identifica univocamente l'operazione logico-aritmetica (R-Type e I-Type) che l'ALU deve eseguire.   Questo permette di ottenere una decodifica hardware estremamente efficiente nell'ALU Decoder (semplice cablaggio).In questo modo sfruttiamo la codifica nativa dell'ISA (filtrata leggermente, forzando bit30 a 0 quando non serve).

    constant alu_add  : std_logic_vector(3 downto 0) := "0000";  -- bit 3 e' 0 per distinguere ADD da SUB
    constant alu_sub  : std_logic_vector(3 downto 0) := "1000";  -- bIT 3 e' 1 per distinguere SUB da ADD
    constant alu_sll  : std_logic_vector(3 downto 0) := "0001";  -- Shift Left Logical
    constant alu_slt  : std_logic_vector(3 downto 0) := "0010";  -- Set Less Than (signed)
    constant alu_sltu : std_logic_vector(3 downto 0) := "0011";  -- Set Less Than Unsigned (unsigned)
    constant alu_xor  : std_logic_vector(3 downto 0) := "0100";  -- XOR
    constant alu_srl  : std_logic_vector(3 downto 0) := "0101";  -- Shift Right Logical (bit alto 0 per distinguere da SRA)
    constant alu_sra  : std_logic_vector(3 downto 0) := "1101";  -- Shift Right Arithmetic (bit alto 1 per distinguere da SRL)
    constant alu_or   : std_logic_vector(3 downto 0) := "0110";  -- OR
    constant alu_and  : std_logic_vector(3 downto 0) := "0111";  -- AND

    -- RISC-V Funct3 Constants (3 bit)

    -- Aritmetiche/Logiche (usate con OPC_OP e OPC_OP_IMM) usate con OPC_OP / OPC_OP_IMM solo se si vuole decodifica esplicita, non necessarie con encoding diretto ALUCTRL = bit30 & funct3
    constant f3_add_sub : std_logic_vector(2 downto 0) := "000";
    constant f3_sll     : std_logic_vector(2 downto 0) := "001";
    constant f3_slt     : std_logic_vector(2 downto 0) := "010";
    constant f3_sltu    : std_logic_vector(2 downto 0) := "011";
    constant f3_xor     : std_logic_vector(2 downto 0) := "100";
    constant f3_srl_sra : std_logic_vector(2 downto 0) := "101";
    constant f3_or      : std_logic_vector(2 downto 0) := "110";
    constant f3_and     : std_logic_vector(2 downto 0) := "111";

    -- Salti Condizionati (usate con OPC_BRANCH)
    constant f3_beq  : std_logic_vector(2 downto 0) := "000";
    constant f3_bne  : std_logic_vector(2 downto 0) := "001";
    constant f3_blt  : std_logic_vector(2 downto 0) := "100";
    constant f3_bge  : std_logic_vector(2 downto 0) := "101";
    constant f3_bltu : std_logic_vector(2 downto 0) := "110";
    constant f3_bgeu : std_logic_vector(2 downto 0) := "111";

    -- Memoria (usate con OPC_LOAD e OPC_STORE)
    constant f3_byte   : std_logic_vector(2 downto 0) := "000";  -- LB, SB
    constant f3_half   : std_logic_vector(2 downto 0) := "001";  -- LH, SH
    constant f3_word   : std_logic_vector(2 downto 0) := "010";  -- LW, SW
    constant f3_byte_u : std_logic_vector(2 downto 0) := "100";  -- LBU
    constant f3_half_u : std_logic_vector(2 downto 0) := "101";  -- LHU

    -- Organizzazione della memoria
    constant DATA_BASE_ADDRESS : word_t := x"00001100";

end package pkg_riskv_types;

/*
esempio alu decoder: process(ALUOp, funct3, bit30, is_R_type)
    variable use_bit30 : std_logic;
begin
    -- Capiamo se dobbiamo usare il bit 30 o forzarlo a zero
    -- Lo usiamo se e' R-Type, OPPURE se e' I-Type ma e' uno shift (funct3 = "101")
    if (is_R_type = '1' or funct3 = "101") then
        use_bit30 := bit30;
    else
        use_bit30 := '0'; -- Nelle ADDI, ANDI ecc. forziamo a 0 per non far danni!
    end if;

    -- Il classico MUX dell'ALU Decoder
    if (ALUOp = "00") then
        -- LOAD, STORE, AUIPC, LUI, JAL, JALR -> Forza Addizione
        ALU_CTRL <= ALU_ADD; ("0000")

    elsif (ALUOp = "01") then
        -- BRANCH -> Forza Sottrazione
        ALU_CTRL <= ALU_SUB; ("1000")

    elsif (ALUOp = "10") then
        -- OP o OP-IMM -> Incolla il bit 30 (filtrato) con funct3
        ALU_CTRL <= use_bit30 & funct3;
    end if;
end process;
*/
