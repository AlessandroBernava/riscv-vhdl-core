
-- Instruction Memory con registro IF/ID integrato.
-- Su FPGA, una memoria con lettura sincrona viene inferita come BRAM,
-- evitando il consumo di LUT che si avrebbe con una lettura asincrona.
-- Dato che l'istruzione e' disponibile il ciclo di clock successivo rispetto
-- all'arrivo in input del PC, risulta inutile un registro IF/ID separato:
-- le uscite instr_o, pc_o e pc4_o sono gia' registrate dalla memoria stessa
-- Il modulo gestisce internamente reset, stall (congela le uscite) e flush
-- (sostituisce l'istruzione con una NOP per annullare il fetch in caso
-- di branch taken o eccezione), con priorita': reset > flush > stall > normale

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;    -- Estensione per leggere stringhe hex in std_logic_vector

use std.textio.all;               -- Libreria standard VHDL per i file

use work.pkg_riskv_types.all;

entity instruction_memory is
    port (
        clk     : in  std_logic;
        res_i   : in  std_logic;
        flush_i : in  std_logic;
        stall_i : in  std_logic;
        pc_i    : in  word_t;
        pc_o    : out word_t;
        pc4_o   : out word_t;
        instr_o : out word_t
    );
end entity instruction_memory;

architecture rtl of instruction_memory is
    /*
    signal mem : instr_mem_t := (
        0 => x"00001537",  -- lui x10, 0x00001      -> x10 = 0x00001000
        1 => x"00050513",  -- addi x10, x10, 0      -> x10 = 0x00001000 (ridondante, ma chiaro)

        2 => x"07B00593",  -- addi x11, x0, 123     -> x11 = 123 (0x0000007B)

        3 => x"00B52023",  -- sw x11, 0(x10)        -> MEM[0x00001000] = 123

        4 => x"00052283",  -- lw x5, 0(x10)         -> x5 = MEM[0x00001000] = 123

        5      => x"0000006F",  -- jal x0, 0             -> loop infinito su se stessa
        others => x"00000013"   -- nop
    );
*/
    -- 1. Definisci il tuo tipo di memoria (lo avevi già, metti la tua dimensione reale)

    -- 2. Scrivi la funzione che legge il file
    impure function init_ram_hex return instr_mem_t is
        -- Specifica il percorso del file. In simulazione parte dalla cartella dove lanci make.
        file text_file       : text open read_mode is "software/build/instr.mem";
        variable text_line   : line;
        variable ram_content : instr_mem_t := (others => (others => '0'));         -- Riempe di zeri il resto
        variable i           : integer := 0;
    begin
        while not endfile(text_file) loop
            readline(text_file, text_line);
            -- hread legge i caratteri esadecimali e li mette nel std_logic_vector
            hread(text_line, ram_content(i));
            i := i + 1;
        end loop;
            return ram_content;
        end function;

        -- 3. Usa la funzione per inizializzare il segnale della memoria
        signal mem : instr_mem_t := init_ram_hex;

    begin

        instr_fetch : process (clk) is
        begin

            if (clk'event and clk = '1') then
                if (res_i = '1') then
                    pc_o <= (others => '0');
                    pc4_o <= (others => '0');
                    instr_o <= INSTR_NOP;
                elsif (stall_i = '0') then
                    if(flush_i = '1') then
                        pc_o <= (others => '0');
                        pc4_o <= (others => '0');
                        instr_o <= INSTR_NOP;
                    else
                        pc_o <= pc_i;
                        pc4_o <= std_logic_vector(unsigned(pc_i) + 4);
                        instr_o <= mem(to_integer(unsigned(pc_i(31 downto 2))));
                    end if;
                end if;
            end if;

            -- if (clk'event and clk = '1') then
            --      instr_o <= mem(to_integer(unsigned(pc_i(31 downto 2))));
            --  end if;
            -- nota: PC contiene indirizzi byte , mentre mem e'indicizzata per word in VHDL.
            -- I 2 bit bassi del PC sono sempre '00' per istruzioni
            -- allineate a 32 bit, quindi si usa pc_i(31 downto 2) come indice: cio' equivale a dividere il PC per 4.

        end process instr_fetch;

    end architecture rtl;

    /*         if (clk'event and clk = '1') then
            if (res_i = '1') then
                pc_o <= (others => '0');
                pc4_o <= (others => '0');
                instr_o <= INSTR_NOP;
            elsif (flush_i = '1') then
                pc_o <= (others => '0');
                pc4_o <= (others => '0');
                instr_o <= INSTR_NOP;
            elsif (stall_i = '0') then
                pc_o <= pc_i;
                pc4_o <= std_logic_vector(unsigned(pc_i) + 4);
                instr_o <= mem(to_integer(unsigned(pc_i(31 downto 2))));
            end if;
*/
    /*
00a08093
01410113
002081b3
00302023
00002203
00a28293
00a30313
fe6282e3
*/

    /*
        0 => x"00500093",  -- addi x1, x0, 5
        1 => x"00300113",  -- addi x2, x0, 3
        2 => x"002081B3",  -- add  x3, x1, x2        ; x3 = 8
        3 => x"40110233",  -- sub  x4, x2, x1        ; x4 = -2
        4 => x"0020F2B3",  -- and  x5, x1, x2
        5 => x"0020E333",  -- or   x6, x1, x2

        6  => x"002020A3",  -- sw   x2, 1(x0)
        7  => x"00102623",  -- sw x1, 12(x0)
        8  => x"00C02203",  -- lw x4, 12(x0)
        9  => x"00102203",  -- lw   x4, 1(x0)
        10 => x"0042D863",  -- bge x5 x4 +16
        -- 9      => x"00718463",  -- beq  x3, x7, +8
        11     => x"00100413",  -- addi x8, x0, 1         ; da saltare se beq preso
        12     => x"00200493",  -- addi x9, x0, 2
        13     => x"0080006F",  -- jal  x0, +8
        14     => x"00300513",  -- addi x10, x0, 3        ; da saltare col jal
        15     => x"00400593",  -- addi x11, x0, 4
        */
