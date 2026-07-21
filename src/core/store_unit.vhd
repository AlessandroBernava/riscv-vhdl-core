--  NOTE LSU / MEMORIA DATI (BRAM sincrona)
--
--  La memoria dati e' una BRAM sincrona: l'indirizzo si da' in un ciclo
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
--     - la BRAM da' il dato letto un ciclo dopo, quindi in WB
--     - porto fino a MEM/WB i controlli (mem_size, mem_unsigned, addr, rd, ...)
--     - in WB prendo mem_rdata e lo formatto (selezione byte + sign/zero extend)
--       e lo mando al register file
--
--  In pratica: store formattate in MEM, load formattate in WB.
--  Con BRAM sincrona non posso fare tutto in un unico blocco in MEM,
--  altrimenti i dati delle load sarebbero sfasati rispetto all'istruzione.

-- NOTE: questa load_unit assume accessi di memoria allineati
-- (word su indirizzi multipli di 4, half su multipli di 2).
-- Gli accessi misallineati in RISC-V hanno comportamento dipendente
-- dall'ambiente di esecuzione e richiedono logica extra:
--   - o trap per misaligned load/store
--   - o gestione hardware con due accessi di memoria
-- Per ora il core RV32I supporta solo accessi allineati; per estenderlo
-- studiare: misaligned load/store in spec RISC-V e design di LSU (es. Ibex (??)).

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity store_unit is
    port (
        data_i           : in  word_t;
        mem_size_i       : in  std_logic_vector(1 downto 0);
        addr_low_i       : in  std_logic_vector(1 downto 0);  --connettere con ex_mem.alu_result
        formatted_data_o : out word_t;
        byte_enable_o    : out std_logic_vector(3 downto 0);
        misaligned_o     : out std_logic
    );
end entity store_unit;

architecture rtl of store_unit is
    signal byte_enable : std_logic_vector(3 downto 0); --posizioni in cui scrivere in memoria
begin
    byte_enable_proc : process (all) is
    begin
        if mem_size_i = "00" then
            if addr_low_i = "00" then
                byte_enable <= "0001";
            elsif addr_low_i = "01" then
                byte_enable <= "0010";
            elsif addr_low_i = "10" then
                byte_enable <= "0100";
            elsif addr_low_i = "11" then
                byte_enable <= "1000";
            end if;
        elsif  mem_size_i = "01" then
            if addr_low_i = "00" then
                byte_enable <= "0011";
            elsif addr_low_i = "01" then -- misaligned
                byte_enable <= "0110";
            elsif addr_low_i = "10" then
                byte_enable <= "1100";
            else
                byte_enable <= "0000";   -- misaligned
            end if;
        else
            byte_enable <= "1111";
        end if;
    end process byte_enable_proc;

    formatting : process (all) is
        variable formatted_data_v : word_t; --dato che va scritto in memoria
    begin
        formatted_data_v := (others => '0');

        case byte_enable is
            when "0001" => formatted_data_v(7 downto 0) := data_i(7 downto 0);
            when "0010" => formatted_data_v(15 downto 8) := data_i(7 downto 0);
            when "0100" => formatted_data_v(23 downto 16) := data_i(7 downto 0);
            when "1000" => formatted_data_v(31 downto 24) := data_i(7 downto 0);
            when "0011" => formatted_data_v(15 downto 0) := data_i(15 downto 0);
            when "1100" => formatted_data_v(31 downto 16) := data_i(15 downto 0);
            when "1111" => formatted_data_v := data_i;
            when others => formatted_data_v := (others => '0');
        end case;

        formatted_data_o <= formatted_data_v;
    end process formatting;

    byte_enable_o <= byte_enable;

    misaligned_o <= '1' when (mem_size_i = "10" and addr_low_i /= "00") else
    '1'                 when (mem_size_i = "01" and addr_low_i(0) = '1') else
    '0';

end architecture rtl;
