--  NOTE LSU / MEMORIA DATI (BRAM sincrona)
--
--  La memoria dati è una BRAM sincrona: l'indirizzo si dà in un ciclo
--  e il dato di lettura arriva solo al ciclo dopo.
--
--  Per questo separo la logica in due pezzi:
--
--  1) STORE (stadio MEM)
--     - usa segnali da EX/MEM (addr, rs2_data, mem_size, mem_write, ...)
--     - prepara il dato da scrivere (shift in base ad addr(1 downto 0))
--       e i byte_enable
--     - pilota direttamente la BRAM per le store in MEM
--
--  2) LOAD (stadio WB)
--     - la BRAM dà il dato letto un ciclo dopo, quindi in WB
--     - porto fino a MEM/WB i controlli (mem_size, mem_unsigned, addr, rd, ...)
--     - in WB prendo mem_rdata e lo formatto (selezione byte + sign/zero extend)
--       e lo mando al register file
--
--  In pratica: store formattate in MEM, load formattate in WB.
--  Con BRAM sincrona non posso fare tutto in un unico blocco in MEM,
--  altrimenti i dati delle load sarebbero sfasati rispetto all'istruzione.

-- scelta architetturale: verificare se e' utile mettere il blocco di formattazione del dato letto dalla memoria (load_unit)
-- nello stadio di WB piuttosto che nello stadio di MEM come logica aggiunta al modulo data_memory

-- NOTE: questa load_unit assume accessi di memoria allineati
-- (word su indirizzi multipli di 4, half su multipli di 2).
-- Gli accessi misallineati in RISC-V hanno comportamento dipendente
-- dall'ambiente di esecuzione (EEI) e richiedono logica extra:
--   - o trap per misaligned load/store
--   - o gestione hardware con due accessi di memoria
-- Per ora il core RV32I supporta solo accessi allineati; per estenderlo
-- studiare: misaligned load/store in spec RISC-V e design di LSU (es. Ibex).

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity store_unit is
    port (
        data_i           : in  word_t;
        mem_size_i         : in  std_logic_vector(1 downto 0);
        formatted_data_o : out word_t
    );
end entity store_unit;

architecture rtl of store_unit is

begin
    formatting : process (all) is
    begin
        if mem_size_i = "00" then
            formatted_data_o <= (31 downto 8 => '0') & data_i(7 downto 0);
        elsif mem_size_i = "01" then
            formatted_data_o <= (31 downto 16 => '0') & data_i(15 downto 0);
        else
            formatted_data_o <= data_i;
        end if;
    end process formatting;

end architecture rtl;
