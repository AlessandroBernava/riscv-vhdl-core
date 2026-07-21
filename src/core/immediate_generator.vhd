-- Generatore dell'immediato: riceve l'istruzione a 32 bit e il tipo
-- (R, I, S, B, U, J come enum instr_type_t) e riassembla i bit dell'immediato
-- come da specifica RV32I , con sign extension a 32 bit.
-- Logica puramente combinatoria, nessun clock.
-- Il tipo R non ha immediato: restituisce zero

-- verificare se e' opportuno modificare la logica rendendola parallela a quella della CU per
-- ridurre il critical path (teoricamente lo stadio EX è quello critico in ogni caso)

library ieee;

library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity immediate_generator is
    port (
        type_i  : in  instr_type_t;
        instr_i : in  word_t;
        imm_o   : out word_t
    );
end entity immediate_generator;

architecture rtl of immediate_generator is

begin

    imm_o <= (others => '0')                                                                           when type_i = R_TYPE else
    (31 downto 12 => instr_i(31)) & instr_i(31 downto 20)                                              when type_i = I_TYPE else
    (31 downto 12 => instr_i(31)) & instr_i(31 downto 25) & instr_i(11 downto 7)                       when type_i = S_TYPE else
    (31 downto 12 => instr_i(31)) & instr_i(7) & instr_i(30 downto 25) & instr_i(11 downto 8) & '0'    when type_i = B_TYPE else
    instr_i(31 downto 12) & (11 downto 0 => '0')                                                       when type_i = U_TYPE else
    (31 downto 20 => instr_i(31)) & instr_i(19 downto 12) & instr_i(20) & instr_i(30 downto 21) & '0'  when type_i = J_TYPE else
    (others => '0');

end architecture rtl;
