-- Il Program Counter e' implementato come registro interno (pc_reg) aggiornato
-- sul fronte di salita del clock. L'uscita pc_o e' combinatoria e riflette
-- immediatamente il valore di pc_reg, rendendolo disponibile alla Instruction
-- Memory nello stesso ciclo in cui viene aggiornato. Questo e' il pattern
-- standard "registro con uscita combinatoria": lo stato e' unico (pc_reg),
-- le uscite sono finestre su quello stato, senza duplicazioni.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity program_counter is
    port (
        clk         : in  std_logic;
        res_i       : in  std_logic;
        stall_i     : in  std_logic;
        pc_sel_i    : in  std_logic;
        pc_target_i : in  word_t;
        pc_o        : out word_t
    );
end entity program_counter;

architecture rtl of program_counter is

    signal pc_reg : word_t := x"00000000";

begin
    pc_proc : process (clk) is
    begin
        if clk'event and clk = '1' then
            if res_i = '1' then
                pc_reg <= (others => '0');
            elsif stall_i = '0' then
                if pc_sel_i = '0' then
                    pc_reg <= std_logic_vector(unsigned(pc_reg) + 4);
                else
                    pc_reg <= pc_target_i;
                end if;
            end if;
        end if;
    end process pc_proc;

    pc_o <= pc_reg;
end architecture rtl;

