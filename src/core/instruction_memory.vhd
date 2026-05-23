
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

    signal mem : instr_mem_t := (
        -- FASE 1: dipendenze lunghe su registri (forwarding/stall)
        0 => x"00100093",  -- addi x1, x0, 1
        1 => x"00100113",  -- addi x2, x0, 1
        2 => x"32208063",  -- beq  x1, x2, +800 bytes  -> salta a indirizzo 202
        3 => x"11100193",  -- addi x3, x0, 273   ; da saltare
        4 => x"22200213",  -- addi x4, x0, 546   ; da saltare
        5 => x"33300293",  -- addi x5, x0, 819   ; da saltare

        20 => x"00A00313",  -- addi x6, x0, 10    ; target del branch indietro
        21 => x"01400393",  -- addi x7, x0, 20
        22 => x"00638433",  -- add  x8, x7, x6    ; x8 = 30
        23 => x"00000063",  -- beq  x0, x0, 0     ; loop finale se arrivi qui

        202 => x"00100413",  -- addi x8, x0, 1     ; conferma salto avanti riuscito
        203 => x"00108493",  -- addi x9, x1, 1     ; x9 = 2
        204 => x"d21080e3",  -- beq  x1, x1, -720 bytes -> torna a indirizzo 24 circa
        205 => x"44400513",  -- addi x10, x0, 1092 ; da saltare
        206 => x"55500593",  -- addi x11, x0, 1365 ; da saltare

        24 => x"06300613",  -- addi x12, x0, 99   ; qui deve arrivare il branch all'indietro
        25 => x"00160693",  -- addi x13, x12, 1   ; x13 = 100
        26 => x"00000063",  -- beq  x0, x0, 0     ; loop finale pulito

        others => x"00000013"  -- nop
    );

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
