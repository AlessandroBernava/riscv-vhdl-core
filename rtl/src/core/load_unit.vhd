-- Load Unit: formatta il dato grezzo letto dalla memoria dati per il writeback.
-- Riceve sempre una word a 32 bit dalla memoria e ne estrae il byte o la
-- halfword corretta in base ad addr_low (i 2 bit bassi dell'indirizzo) e
-- mem_size, normalizzando il risultato sempre nei bit bassi del dato in uscita.
-- La sign extension (LB, LH) replica il bit di segno nei bit alti,
-- la zero extension (LBU, LHU) li azzera.
-- Il byte_enable intermedio semplifica la logica di selezione e sign extension,
-- evitando un case annidato su mem_size e addr_low contemporaneamente (eventualmente
-- verificare l'effetto in sintesi).
-- Rileva accessi non allineati (halfword non su multiplo di 2, word non su
-- multiplo di 4) e li segnala tramite misaligned_o, senza generare eccezioni
-- (gestione delegata al livello superiore).

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity load_unit is
    port (
        data_i           : in  word_t;
        mem_unsigned_i   : in  std_logic;
        mem_size_i       : in  std_logic_vector(1 downto 0);
        addr_low_i       : in  std_logic_vector(1 downto 0);  -- connettere con mem_wb.alu_result
        formatted_data_o : out word_t;
        misaligned_o     : out std_logic
    );
end entity load_unit;

architecture rtl of load_unit is
  signal byte_enable : std_logic_vector(3 downto 0); -- posizioni della memoria da leggere
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
      variable formatted_data_v : word_t; --dato letto dalla memoria
    begin
        formatted_data_v := (others => '0');

        case byte_enable is
            when "0001" => formatted_data_v(7 downto 0) := data_i(7 downto 0);
            when "0010" => formatted_data_v(7 downto 0) := data_i(15 downto 8);
            when "0100" => formatted_data_v(7 downto 0) := data_i(23 downto 16);
            when "1000" => formatted_data_v(7 downto 0) := data_i(31 downto 24);
            when "0011" => formatted_data_v(15 downto 0) := data_i(15 downto 0);
            when "1100" => formatted_data_v(15 downto 0) := data_i(31 downto 16);
            when "1111" => formatted_data_v := data_i;
            when others => formatted_data_v := (others => '0');
        end case;

        if mem_unsigned_i = '0' then
            case byte_enable is
                when "0001" => formatted_data_v(31 downto 8) := (others => data_i(7));
                when "0010" => formatted_data_v(31 downto 8) := (others => data_i(15));
                when "0100" => formatted_data_v(31 downto 8) := (others => data_i(23));
                when "1000" => formatted_data_v(31 downto 8) := (others => data_i(31));
                when "0011" => formatted_data_v(31 downto 16) := (others => data_i(15));
                when "1100" => formatted_data_v(31 downto 16) := (others => data_i(31));
                when others => null;
            end case;
        end if;

        formatted_data_o <= formatted_data_v;
    end process formatting;

    misaligned_o <= '1' when (mem_size_i = "10" and addr_low_i /= "00") else
    '1'                 when (mem_size_i = "01" and addr_low_i(0) = '1') else
    '0';
end architecture rtl;

/* formatting : process (all) is
    begin
        if mem_unsigned_i = '1' then
            if mem_size_i = "00" then
                formatted_data_o <= (31 downto 8 => '0') & data_i(7 downto 0);
            elsif mem_size_i = "01" then
                formatted_data_o <= (31 downto 16 => '0') & data_i(15 downto 0);
            else
                formatted_data_o <= data_i;
            end if;
        else
            if mem_size_i = "00" then
                formatted_data_o <= (31 downto 8 => data_i(7)) & data_i(7 downto 0);
            elsif mem_size_i = "01" then
                formatted_data_o <= (31 downto 16 => data_i(15)) & data_i(15 downto 0);
            else
                formatted_data_o <= data_i;

            end if;
        end if;
    end process formatting; */
