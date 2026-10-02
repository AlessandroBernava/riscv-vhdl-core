
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity tb_fpga_top is
end entity tb_fpga_top;

architecture tb of tb_fpga_top is
    signal  res_i_t     : std_logic;
    signal   clk_i_t    : std_logic;
    signal  led_pass_t  : std_logic;
    signal pass_seen_t  : boolean := false;
    constant clk_period : time := 10 ns;

begin

    dut : entity work.fpga_top
    port map (
        res_n    => res_i_t,
        clk      => clk_i_t,
        led_pass => led_pass_t
    );

    clk_gen : process is
    begin

        clk_i_t <= '0';
        wait for clk_period / 2;
        clk_i_t <= '1';
        wait for clk_period / 2;

    end process  clk_gen;

    stim : process
    begin
        -- Reset esterno attivo basso.
        res_i_t <= '0';
        wait for CLK_PERIOD * 20;

        -- Rilascio del reset sul fronte di discesa.
        wait until falling_edge(clk_i_t);
        res_i_t <= '1';

        report "Reset rilasciato a t=" & time'image(now)
        severity note;

        -- Tempo massimo concesso al programma.
        wait for CLK_PERIOD * 30_000;

        if pass_seen_t then
            report "TEST SUPERATO: led_pass osservato a '1'."
            severity note;
        else
            report "TEST NON SUPERATO: led_pass non e' mai diventato '1' entro il timeout."
            severity error;
        end if;

        report "Simulazione completata."
        severity note;

        std.env.stop;
        wait;
    end process stim;

    -- stampa ad ogni clock cosa succede
    monitor : process
    variable previous_led : std_logic := 'U';
    begin
        wait until rising_edge(clk_i_t);

        -- Lascia assestare gli aggiornamenti successivi al fronte.
        wait for 1 ns;

        if res_i_t = '0' then
            pass_seen_t <= false;
            previous_led := 'U';

        elsif res_i_t = '1' then

            -- Stampa soltanto quando cambia il valore del LED.
            if led_pass_t /= previous_led then
                report "t=" & time'image(now) &
                " | led_pass=" & std_logic'image(led_pass_t)
                severity note;

                previous_led := led_pass_t;
            end if;

            -- Memorizza il raggiungimento del risultato atteso.
            if led_pass_t = '1' and not pass_seen_t then
                pass_seen_t <= true;

                report "PASS osservato: led_pass e' diventato '1' a t=" &
                time'image(now)
                severity note;
            end if;

        end if;
    end process monitor;
end architecture tb;
