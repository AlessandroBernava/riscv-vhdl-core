-- Memoria dati sincrona: lettura e scrittura sul fronte di salita del clock.
-- La lettura sincrona permette l'inferenza di BRAM su FPGA, evitando il consumo
-- di LUT. Di conseguenza questo modulo assorbe il ruolo del registro MEM/WB
-- per il dato letto dalla memoria.
-- Il reset azzera solo le uscite, non la memoria fisica: su FPGA la BRAM
-- non e' resettabile a runtime in modo efficiente.
-- La formattazione del dato letto (sign extension, estrazione byte/halfword)
-- e' delegata a un modulo separato (load_formatter) per separare le
-- responsabilita' e ridurre il critical path.

-- NOTE MEMORIA DATI / ALLINEAMENTO
-- La memeoria e' word-addressed: l'indirizzo byte RISC-V viene
-- diviso per 4 (si ignorano i bit addr(1 downto 0)) e si accede
-- sempre a word da 32 bit allineate.
--
-- Di conseguenza il core supporta correttamente solo accessi dati
-- "fortemente" allineati (es. lw e lh su indirizzi multipli di 4).
-- Accessi che sarebbero solo halfword-aligned a livello ISA
-- (es. lh/sh a indirizzi con addr(1 downto 0) = "10") non sono
-- gestiti correttamente in questa implementazione semplificata.
--
-- Questo è un compromesso progettuale accettabile per un RV32I
-- accademico; per supportare tutti i casi allineati RISC-V
-- bisognerebbe usare anche addr(1 downto 0) nella load/store unit
-- per selezionare i byte/halfword corretti all'interno della word.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity data_memory is
    port (
        clk          : in  std_logic;
        res_i        : in  std_logic;
        mem_read_i   : in  std_logic;
        mem_write_i  : in  std_logic;
        addr_i       : in  word_t;
        write_data_i : in  word_t;
        data_o       : out word_t
    );
end entity data_memory;

architecture rtl of data_memory is

    signal mem : data_mem_t := (others => (others => '0'));

begin

    data_mem_proc : process (clk) is
    begin

        if (clk'event and clk = '1') then
            if (res_i = '1') then
                data_o <= (others => '0');
            else

                if (mem_write_i = '1') then
                    mem(to_integer(unsigned(addr_i(31 downto 2)))) <= write_data_i;
                end if;

                if mem_read_i = '1' then                              -- nota: se io scrivo in memoria ad un indirizzo e lo leggo durante lo stesso ciclo di clk, sul successivo fronte del clk leggo l'indirizzo vecchio. Non è un problema dato che nessuna istruzione legge e scrive contemparaneamente in memoria
                    data_o <= mem(to_integer(unsigned(addr_i(31 downto 2))));
                else
                    data_o <= (others => '0');
                end if;
            end if;
        end if;
    end process data_mem_proc;

end architecture rtl;
