-- ALU Control: riceve ALUOp dalla Control Unit (2 bit che indicano la categoria dell'operazione)
-- e produce il codice a 4 bit per la ALU.
--
-- ALU Code (bit30 & funct3): Identifica univocamente l'operazione logico-aritmetica
-- (R-Type e I-Type) che l'ALU deve eseguire. Questo permette di ottenere una
-- decodifica hardware estremamente efficiente nell'ALU Decoder (semplice cablaggio).
-- In questo modo sfruttiamo la codifica nativa dell'ISA (filtrata leggermente,forzando bit30
-- a 0 quando non serve).
--
-- Per ALUOp="00" (load/store/auipc/jal) forza ADD indipendentemente da funct3.
-- Per ALUOp="01" (branch) forza SUB per il confronto tra operandi.
-- Per ALUOp="10" (R-type/I-type) applica il cablaggio diretto bit30 & funct3.

library ieee;

library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_pipeline.all;
use work.pkg_riskv_types.all;

entity alu_ctrl is
    port (
        aluop_i    : in  std_logic_vector(1 downto 0);
        f3_i       : in  std_logic_vector(2 downto 0);
        f7b_i      : in  std_logic;
        isrtype    : in  std_logic;
        alu_ctrl_o : out std_logic_vector(3 downto 0)
    );
end entity alu_ctrl;

architecture rtl of alu_ctrl is

    signal bit30 : std_logic;

begin

    bit30 <= f7b_i when (isrtype = '1' or f3_i = "101") else
    '0';

    alu_ctrl_o <= alu_add when aluop_i = "00" else -- load/store/auipc/jal
    alu_sub               when aluop_i = "01" else -- branch
    (bit30 & f3_i);                  -- R/I-type

end architecture rtl;
