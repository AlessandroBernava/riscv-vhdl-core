
library ieee;
library work;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.pkg_riskv_types.all;

entity ALU is
    port (
        a_i      : in  word_t;
        b_i      : in  word_t;
        alu_op_i : in  std_logic_vector(3 downto 0);
        result_o : out word_t;
        zero_o   : out std_logic
    );
end entity ALU;

architecture rtl of ALU is

begin

    process1 : process (a_i, b_i, alu_op_i)
    variable v_res  : word_t;
    variable v_zero : std_logic;

    begin
        v_res := (others => '0'); --per evitare latch
        v_zero := '0';

        case alu_op_i is
            when ALU_ADD =>
                v_res := std_logic_vector(unsigned(a_i) + unsigned(b_i));

            when ALU_SUB =>
                v_res := std_logic_vector(unsigned(a_i) - unsigned(b_i));

            when ALU_SLL =>
                v_res := std_logic_vector(shift_left(unsigned(a_i), to_integer(unsigned(b_i(4 downto 0)))));

            when ALU_SLT =>
                if signed(a_i) < signed(b_i) then
                    v_res := (0 => '1', others => '0');
                else
                    v_res := (others => '0');
                end if;

            when ALU_SLTU =>
                if unsigned(a_i) < unsigned(b_i) then
                    v_res := (0 => '1', others => '0');
                else
                    v_res := (others => '0');
                end if;

            when ALU_XOR =>
                v_res := a_i xor b_i;

            when ALU_SRL =>
                v_res := std_logic_vector(shift_right(unsigned(a_i), to_integer(unsigned(b_i(4 downto 0)))));

            when ALU_SRA =>
                v_res := std_logic_vector(shift_right(signed(a_i), to_integer(unsigned(b_i(4 downto 0)))));

            when ALU_OR =>
                v_res := a_i or b_i;

            when ALU_AND =>
                v_res := a_i and b_i;

            when others =>
                v_res := (others => 'X');
        end case;
        --zero_o <= '1' when unsigned(v_res) = 0 else '0'; problema metavalue warning a t=0 in simulazione gtkwave simu/tb_alu.ghw
        if v_res = (v_res'range => '0') then
            v_zero := '1';
        else
            v_zero := '0';
        end if;

        zero_o <= v_zero;
        result_o <= v_res;

    end process process1;

    --   zero_o <= '1' when unsigned(result_o) = 0 else '0';

end architecture rtl;
