-- Forwarding Unit: rileva gli hazard di dato e genera i segnali di selezione
-- per i mux di forwarding posti prima degli ingressi della ALU nello stadio EX.
-- Confronta gli indirizzi rs1/rs2 dell'istruzione in EX con rd delle istruzioni
-- in MEM e WB: se coincidono e reg_write e' attivo, il dato viene prelevato
-- direttamente dall'uscita dello stadio piu' avanzato invece che dal registro
-- ID/EX, evitando stall per hazard RAW (Read After Write).
-- Priorita': MEM ha precedenza su WB perche' contiene il dato piu' recente.
-- forward_a/b = "00" nessun forward, "01" da EX/MEM, "10" da MEM/WB.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity forwarding_unit is
    port (
        rs1_addr_i      : in  reg_addr_t;                    --collegare a id_ex.rs1_addr
        rs2_addr_i      : in  reg_addr_t;                    --collegare a id_ex.rs2_addr
        rd_mem_i        : in  reg_addr_t;                    --collegare a ex_mem.rd_addr
        reg_write_mem_i : in  std_logic;
        rd_wb_i         : in  reg_addr_t;                    --collegare a mem_wb.rd_addr
        reg_write_wb_i  : in  std_logic;
        forwardA_o      : out std_logic_vector(1 downto 0);  --00 no forward, 01 da ex/mem, 01 da mem/ wb  controlla mux prima del mux alu_src_A
        forwardB_o      : out std_logic_vector(1 downto 0)
    );
end entity forwarding_unit;

architecture rtl of forwarding_unit is
begin
    forwardA_o <= "01"  when rs1_addr_i = rd_mem_i and reg_write_mem_i = '1' else
    "10"                when rs1_addr_i = rd_wb_i and reg_write_wb_i = '1' else
    "00";

    forwardB_o <= "01"  when rs2_addr_i = rd_mem_i and reg_write_mem_i = '1' else
    "10"                when rs2_addr_i = rd_wb_i and reg_write_wb_i = '1' else
    "00";
end architecture rtl;

--miglioramento: nel caso di store foraward rs2 in mem da mem/wb - permette di evitare lo stall di un ciclo nel caso load + store
