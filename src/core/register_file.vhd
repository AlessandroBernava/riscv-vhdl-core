
library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;
    use work.pkg_riskv_types.all;

entity register_file is
    port (
        clk          : in    std_logic;
        res          : in    std_logic;
        we           : in    std_logic;
        rs1_addr_i   : in    reg_addr_t;
        rs2_addr_i   : in    reg_addr_t;
        rd_addr_i    : in    reg_addr_t;
        write_data_i : in    word_t;
        rs1_data_o   : out   word_t;
        rs2_data_o   : out   word_t
    );
end entity register_file;

architecture rtl of register_file is

    signal reg : reg_file_t;

begin

    -- Lettura asincrona con forwarding interno: se we='1' e rd_addr_i coincide con
    -- rs1/rs2_addr_i, viene propagato direttamente write_data_i invece del valore
    -- in memoria, evitando lo structural hazard di scrittura/lettura sullo stesso
    -- registro nello stesso ciclo di clock.
    --
    -- NOTA ARCHITETTURALE: il forwarding e' puramente combinatorio e non considera
    -- il segnale res. Di conseguenza, durante il reset (res='1'), se we='1' e
    -- rd_addr_i = rs1/rs2_addr_i, le uscite mostrano write_data_i invece di zero,
    -- anche se reg e' stato appena azzerato dal process sincrono.
    -- Soluzione scartata: aggiungere il controllo di res nelle uscite combinatorie
    -- avrebbe creato un reset ibrido. Su in hardware/FPGA, se res torna basso prima del fronte
    -- del clock, le uscite escono dal forzamento a zero mentre reg non e' ancora
    -- stato azzerato, generando un impulso spurio (glitch) invisibile in sim.
    -- La responsabilita' di abbassare we durante il reset e' quindi delegata al
    -- controller della pipeline.

    rs1_data_o <= (others => '0') when rs1_addr_i = REG_X0 else
                  write_data_i when (we = '1'  and rs1_addr_i = rd_addr_i) else
                  reg(to_integer(unsigned(rs1_addr_i)));

    rs2_data_o <= (others => '0') when rs2_addr_i = REG_X0 else
                  write_data_i when (we = '1'  and rs2_addr_i = rd_addr_i) else
                  reg(to_integer(unsigned(rs2_addr_i)));

    reg_file_write : process (clk) is
    begin

        if (clk'event and clk = '1') then
            if (res = '1') then
                reg <= (others => (others => '0'));
            elsif ((we = '1') and rd_addr_i /= REG_X0) then
                reg(to_integer(unsigned(rd_addr_i))) <= write_data_i;
            end if;
        end if;

    end process reg_file_write;

end architecture rtl;
