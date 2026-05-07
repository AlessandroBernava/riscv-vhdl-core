
library ieee;
use ieee.std_logic_1164.all;

package pkg_riskv_types is

    subtype word_t is std_logic_vector(31 downto 0);
    --opcodes
    constant OPC_LOAD   : std_logic_vector(6 downto 0) := "0000011";
    constant OPC_OP_IMM : std_logic_vector(6 downto 0) := "0010011";
    constant OPC_AUIPC  : std_logic_vector(6 downto 0) := "0010111";
    constant OPC_STORE  : std_logic_vector(6 downto 0) := "0100011";
    constant OPC_OP     : std_logic_vector(6 downto 0) := "0110011";
    constant OPC_LUI    : std_logic_vector(6 downto 0) := "0110111";
    constant OPC_BRANCH : std_logic_vector(6 downto 0) := "1100011";
    constant OPC_JAL    : std_logic_vector(6 downto 0) := "1101111";
    constant OPC_JALR   : std_logic_vector(6 downto 0) := "1100111";

    -- ALU Code (bit(30) & funct3): Identifica univocamente l'operazione logico-aritmetica (R-Type e I-Type) che l'ALU deve eseguire.   Questo permette di ottenere una decodifica hardware estremamente efficiente nell'ALU Decoder (semplice cablaggio).In questo modo sfruttiamo la codifica nativa dell'ISA (filtrata leggermente, forzando bit30 a 0 quando non serve).

    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0000";  -- bit 3 è 0 per distinguere ADD da SUB
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "1000";  -- bIT 3 è 1 per distinguere SUB da ADD
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0001";  -- Shift Left Logical
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "0010";  -- Set Less Than (signed)
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "0011";  -- Set Less Than Unsigned (unsigned)
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100";  -- XOR
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0101";  -- Shift Right Logical (bit alto 0 per distinguere da SRA)
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "1101";  -- Shift Right Arithmetic (bit alto 1 per distinguere da SRL)
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0110";  -- OR
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0111";  -- AND
    -- ==========================================
    -- RISC-V Funct3 Constants (3 bit)
    -- ==========================================
    -- Aritmetiche/Logiche (usate con OPC_OP e OPC_OP_IMM) usate con OPC_OP / OPC_OP_IMM solo se si vuole decodifica esplicita, non necessarie con encoding diretto ALUCTRL = bit30 & funct3
    constant F3_ADD_SUB : std_logic_vector(2 downto 0) := "000";
    constant F3_SLL     : std_logic_vector(2 downto 0) := "001";
    constant F3_SLT     : std_logic_vector(2 downto 0) := "010";
    constant F3_SLTU    : std_logic_vector(2 downto 0) := "011";
    constant F3_XOR     : std_logic_vector(2 downto 0) := "100";
    constant F3_SRL_SRA : std_logic_vector(2 downto 0) := "101";
    constant F3_OR      : std_logic_vector(2 downto 0) := "110";
    constant F3_AND     : std_logic_vector(2 downto 0) := "111";

    -- Salti Condizionati (usate con OPC_BRANCH)
    constant F3_BEQ  : std_logic_vector(2 downto 0) := "000";
    constant F3_BNE  : std_logic_vector(2 downto 0) := "001";
    constant F3_BLT  : std_logic_vector(2 downto 0) := "100";
    constant F3_BGE  : std_logic_vector(2 downto 0) := "101";
    constant F3_BLTU : std_logic_vector(2 downto 0) := "110";
    constant F3_BGEU : std_logic_vector(2 downto 0) := "111";

    -- Memoria (usate con OPC_LOAD e OPC_STORE)
    constant F3_BYTE   : std_logic_vector(2 downto 0) := "000";  -- LB, SB
    constant F3_HALF   : std_logic_vector(2 downto 0) := "001";  -- LH, SH
    constant F3_WORD   : std_logic_vector(2 downto 0) := "010";  -- LW, SW
    constant F3_BYTE_U : std_logic_vector(2 downto 0) := "100";  -- LBU
    constant F3_HALF_U : std_logic_vector(2 downto 0) := "101";  -- LHU

end package pkg_riskv_types;

/*
    Questo package definisce i tipi di dati e le costanti utilizzati nel progetto RISC-V. In particolare, include:
    - La definizione del tipo word_t come un vettore di 32 bit, che rappresenta una parola di dati.
    - Le costanti per gli opcode delle istruzioni RISC-V, che identificano il tipo di operazione da eseguire.
    - Le costanti per i codici ALU, che identificano univocamente l'operazione logico-aritmetica che l'ALU deve eseguire, facilitando la decodifica hardware nell'ALU Decoder.
*/
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
/*
