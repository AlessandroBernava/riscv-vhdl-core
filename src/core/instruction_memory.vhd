
library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;
    use work.pkg_riskv_types.all;

entity instruction_memory is
    port (
        clk     : in    std_logic;
        pc_i    : in    word_t;
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
            instr_o <= mem(to_integer(unsigned(pc_i(31 downto 2))));
        end if;

    end process instr_fetch;

end architecture rtl;
