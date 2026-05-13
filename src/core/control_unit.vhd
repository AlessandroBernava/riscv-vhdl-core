
library ieee;

library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_pipeline.all;
use work.pkg_riskv_types.all;

entity control_unit is
    port (
        instr_i        : in  word_t;
        rs1_addr_o     : out reg_addr_t;
        rs2_addr_o     : out reg_addr_t;
        rd_addr_o      : out reg_addr_t;
        imm_type_o     : out instr_type_t;
        f3_o           : out std_logic_vector(2 downto 0);
        f7b_o          : out std_logic;
        isRtype_o      : out std_logic;
        alu_op         : out std_logic_vector(1 downto 0);
        alu_src_a_o    : out std_logic_vector(1 downto 0);
        alu_src_b_o    : out std_logic;
        mem_read_o     : out std_logic;                     -- per mem
        mem_write_o    : out std_logic;
        mem_size_o     : out std_logic_vector(1 downto 0);
        mem_unsigned_o : out std_logic;
        reg_write_o    : out std_logic;                     -- per wb
        result_src_o   : out std_logic_vector(1 downto 0)
    );
end entity control_unit;

architecture rtl of control_unit is

    signal opcode : std_logic_vector(6 downto 0);

begin

    opcode <= instr_i(6 downto 0);
    --f3     <= instr_i(14 downto 12);

    rs1_addr_o <= instr_i(19 downto 15);
    rs2_addr_o <= instr_i(24 downto 20);
    rd_addr_o <= instr_i(11 downto 7);
    imm_type_o <= R_TYPE when opcode = opc_op else
    I_TYPE               when (opcode = opc_op_imm or opcode = opc_load) else
    S_TYPE               when opcode = opc_store else
    B_TYPE               when opcode = opc_branch else
    U_TYPE               when (opcode = opc_lui or opcode = opc_auipc) else
    J_TYPE;
    f3_o <= instr_i(14 downto 12);
    f7b_o <= instr_i(30);
    isRtype_o <= '1' when opcode = opc_op else
    '0';
    alu_op <= "00" when (opcode = opc_load or opcode = opc_store or opcode = opc_auipc or opcode = opc_jal or opcode = opc_jalr or opcode = opc_lui) else
    "01"           when opcode = opc_branch else
    "10";
    alu_src_a_o <= "01" when opcode = opc_jal or opcode = opc_auipc else
    "10"                when opcode = opc_lui else
    "00";
    alu_src_b_o <= '0' when opcode = opc_op else                                             -- 0 rs2 (r type) , 1 imm
    '1';
    mem_read_o <= '1' when opcode = opc_load else
    '0';
    mem_write_o <= '1' when opcode = opc_store else
    '0';
    reg_write_o <= '0' when opcode = opc_branch or opcode = opc_store else
    '1';
    result_src_o <= "00" when opcode = opc_op_imm or opcode = opc_op or opcode = opc_auipc or opcode = opc_lui else
    "01"                 when opcode = opc_load else                                          -- LOAD
    "10";                                                                     -- JAL/ JALR
    mem_unsigned_o <= instr_i(14);                                                              -- 0 signed 1 unsigned
    mem_size_o <= instr_i(13 downto 12) when (opcode = opc_load or opcode = opc_store) else -- 00 b 01 h 10 w
    "00";

end architecture rtl;
