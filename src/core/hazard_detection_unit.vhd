-- Hazard Detection Unit: rileva il load-use hazard, l'unico caso in cui il
-- forwarding non e' sufficiente e serve uno stall esplicito della durata di un ciclo di clock. Si verifica quando
-- una LOAD in EX scrive su un registro che l'istruzione successiva (in ID) legge
-- immediatamente: il dato e' disponibile solo dopo MEM, troppo tardi per EX.
-- Quando stall_o='1', il top level deve:
--   1. congelare il PC (non aggiornarlo)
--   2. congelare la Instruction Memory / registro IF/ID (stall_i='1')
--   3. inserire una bolla in ID/EX azzerando i segnali di controllo (flush).
-- Un solo ciclo di stall e' sufficiente perche' la LOAD risolve in MEM e il
-- forwarding da MEM/WB copre il ciclo successivo.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity hazard_detection_unit is
    port (
        opc_id_ex_i : in  std_logic_vector(6 downto 0);  --collegato con id_ex.opc
        rs1_addr_i  : in  reg_addr_t;                    --collegare a if_id.rs1_addr
        rs2_addr_i  : in  reg_addr_t;                    --collegare a if_id.rs2_addr
        rd_addr_i   : in  reg_addr_t;                    -- collegare a id_ex.rd_addr
        stall_o     : out std_logic
    );
end entity hazard_detection_unit;

architecture rtl of hazard_detection_unit is
begin
    stall_o <= '1' when opc_id_ex_i = opc_load and (rd_addr_i = rs1_addr_i or rd_addr_i = rs2_addr_i) else
    '0';
end architecture rtl;

