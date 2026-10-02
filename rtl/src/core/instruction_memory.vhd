
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
    --    /*
    --    signal mem : instr_mem_t := (
    --        0 => x"00001537",  -- lui x10, 0x00001      -> x10 = 0x00001000
    --       1 => x"00050513",  -- addi x10, x10, 0      -> x10 = 0x00001000 (ridondante, ma chiaro)
    --
    --        2 => x"07B00593",  -- addi x11, x0, 123     -> x11 = 123 (0x0000007B)

    --        3 => x"00B52023",  -- sw x11, 0(x10)        -> MEM[0x00001000] = 123

    --       4 => x"00052283",  -- lw x5, 0(x10)         -> x5 = MEM[0x00001000] = 123

    --       5      => x"0000006F",  -- jal x0, 0             -> loop infinito su se stessa
    --       others => x"00000013"   -- nop
    --   );
    --*/

    -- Funzione che legge il file per inizializzare la memoria
    impure function init_rom_hex return instr_mem_t is
        -- Specifica il percorso del file. In simulazione parte dalla cartella dove viene lanciato make.
        file text_file       : text open read_mode is "C:\Users\Alessandro Bernava\RISK_V\software\build\instr.mem";
        variable text_line   : line;
        variable rom_content : instr_mem_t := (others => (others => '0'));                                            -- Riempe di zeri il resto
        variable i           : integer := 0;
    begin
        while not endfile(text_file) loop
            readline(text_file, text_line);
            -- hread legge i caratteri esadecimali e li mette nel std_logic_vector
            hread(text_line, rom_content(i));
            i := i + 1;
        end loop;
            return rom_content;
        end function;

        -- 2- Usa la funzione per inizializzare il segnale della memoria
        signal mem : instr_mem_t := init_rom_hex;
        --signal mem        : instr_mem_t := (others => (others => '0'));
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

