-- Branch/Jump Unit: decide se il PC deve essere aggiornato con il target
-- address (branch taken o jump) o con PC+4 (esecuzione sequenziale).
-- Per i branch, valuta la condizione direttamente sui dati (BLT, BGE, BLTU, BGEU)
-- o sul flag zero proveniente dalla ALU (BEQ, BNE), evitando flag aggiuntivi
-- nell'ALU. Per JAL e JALR il salto e' incondizionato.
-- La variabile branch viene resettata a '0' ad ogni esecuzione del process
-- per evitare l'inferenza di latch in sintesi.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity branch_jump_unit is
    port (
        opc_i   : in  std_logic_vector(6 downto 0);
        f3_i    : in  std_logic_vector(2 downto 0);
        zero_i  : in  std_logic;
        data1_i : in  word_t;
        data2_i : in  word_t;
        jump_o  : out std_logic
    );
end entity branch_jump_unit;

architecture rtl of branch_jump_unit is

begin

    jump : process (all) is
        variable branch : std_logic;
    begin
        branch := '0';                       --nota: e' necessario resettarla a 0 all'inizio del process, perche' in sisntesi si puo' inferire un latch
        case f3_i is
            when f3_beq =>
                branch := zero_i;
            when f3_bne =>
                branch := not zero_i;
            when f3_blt =>
                if signed(data1_i) < signed(data2_i) then
                    branch := '1';
                end if;
            when f3_bge =>
                if signed(data1_i) >= signed(data2_i) then
                    branch := '1';
                end if;
            when f3_bltu =>
                if unsigned(data1_i) < unsigned(data2_i) then
                    branch := '1';
                end if;
            when f3_bgeu =>
                if unsigned(data1_i) >= unsigned(data2_i) then
                    branch := '1';
                end if;
            when others =>
                branch := '0';
        end case;

        if opc_i = opc_jal or opc_i = opc_jalr then
            jump_o <= '1';
        elsif opc_i = OPC_BRANCH and branch = '1' then
            jump_o <= '1';
        else
            jump_o <= '0';
        end if;

    end process jump;

end architecture rtl;
