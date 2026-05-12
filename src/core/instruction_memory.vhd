
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
        clk     : in    std_logic;
        res_i   : in    std_logic;
        flush_i : in    std_logic;
        stall_i : in    std_logic;
        pc_i    : in    word_t;
        pc_o    : out   word_t;
        pc4_o   : out   word_t;
        instr_o : out   word_t
    );
end entity instruction_memory;

architecture rtl of instruction_memory is

    signal mem : instr_mem_t := (
                                 0      => x"00500093", -- addi x1, x0, 5
                                 1      => x"00300113", -- addi x2, x0, 3
                                 2      => x"002081B3", -- add  x3, x1, x2
                                 others => x"00000013"  -- NOP
                                );

begin

    instr_fetch : process (clk) is
    begin

        if (clk'event and clk = '1') then
            if (res_i = '1') then
                pc_o    <= (others => '0');
                pc4_o   <= (others => '0');
                instr_o <= INSTR_NOP;
            elsif (flush_i = '1') then
                pc_o    <= (others => '0');
                pc4_o   <= (others => '0');
                instr_o <= INSTR_NOP;
            elsif (stall_i = '0') then
                pc_o    <= pc_i;
                pc4_o   <= std_logic_vector(unsigned(pc_i) + 4);
                instr_o <= mem(to_integer(unsigned(pc_i(31 downto 2))));
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
