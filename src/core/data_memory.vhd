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
-- La memoria e' word-addressed: l'indirizzo byte RISC-V viene
-- diviso per 4 (si ignorano addr(1 downto 0)) e si accede
-- sempre a word da 32 bit allineate.
--
-- La store unit genera il segnale byte_enable (4 bit) che indica
-- quali byte della word devono essere scritti, permettendo accessi
-- corretti a byte e halfword senza sovrascrivere i byte adiacenti.
-- La load unit usa addr(1 downto 0) per estrarre e normalizzare
-- il byte o la halfword corretta dalla word letta.
--
-- Accessi non allineati (halfword su indirizzo dispari, word su
-- indirizzo non multiplo di 4) vengono rilevati dalla load/store
-- unit tramite il segnale misaligned_o, la cui gestione e'
-- delegata al livello superiore.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity data_memory is
    port (
        clk           : in  std_logic;
        res_i         : in  std_logic;
        mem_read_i    : in  std_logic;
        mem_write_i   : in  std_logic;
        addr_i        : in  word_t;
        write_data_i  : in  word_t;
        byte_enable_i : in  std_logic_vector(3 downto 0);
        data_o        : out word_t
    );
end entity data_memory;

architecture rtl of data_memory is

    signal mem        : data_mem_t := (others => (others => '0'));
    signal word_index : integer;

begin

    word_index <= to_integer(unsigned(addr_i(31 downto 2))) - to_integer(unsigned(DATA_BASE_ADDRESS(31 downto 2)));
    data_mem_proc : process (clk) is
    begin
        if (clk'event and clk = '1') then
            if (res_i = '1') then
                data_o <= (others => '0');
            else
                if (mem_write_i = '1') then
                    --  mem(to_integer(unsigned(addr_i(31 downto 2)))) <= write_data_i; questo sovrascrive tutti i byte della word in memoria

                    if (byte_enable_i(0) = '1') then
                        mem(word_index)(7 downto 0) <= write_data_i(7 downto 0);
                    end if;

                    if (byte_enable_i(1) = '1') then
                        mem(word_index)(15 downto 8) <= write_data_i(15 downto 8);
                    end if;

                    if (byte_enable_i(2) = '1') then
                        mem(word_index)(23 downto 16) <= write_data_i(23 downto 16);
                    end if;

                    if (byte_enable_i(3) = '1') then
                        mem(word_index)(31 downto 24) <= write_data_i(31 downto 24);
                    end if;
                end if;

                if (mem_read_i = '1') then                              -- nota: se io scrivo in memoria ad un indirizzo e lo leggo durante lo stesso ciclo di clk, sul successivo fronte del clk leggo l'indirizzo vecchio. Non è un problema dato che nessuna istruzione legge e scrive contemparaneamente in memoria
                    data_o <= mem(word_index);
                else
                    data_o <= (others => '0');
                end if;
            end if;
        end if;

    end process data_mem_proc;

end architecture rtl;
