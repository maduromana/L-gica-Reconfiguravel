-- divisor de clock que será usado como base de termpo para o temporizador 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DivisorDeClock is
    port (
        clk_in  : in  std_logic; -- entrada do clock original
        reset   : in  std_logic; -- sinal de reset
        clk_out : out std_logic -- saida do clock dividido em 1HZ
    );
end entity DivisorDeClock;

architecture rtl of DivisorDeClock is

-- para gerar 1Hz, e necessario meio periodo de 0.5s
    constant MAX_COUNT : integer := 24999999; -- -- O contador deve contar ate (50,000,000 / 2) - 1 = 24,999,999
    signal count : integer range 0 to MAX_COUNT := 0; -- contador
    signal clk_signal : std_logic := '0'; -- saída do clock
begin
    process(clk_in, reset)
    begin
        if reset = '1' then
            count <= 0;
            clk_signal <= '0';
        elsif rising_edge(clk_in) then
            if count = MAX_COUNT then -- se o contador chegar ao maximo
                count <= 0; -- zera o contador
                clk_signal <= not clk_signal; -- inverte o sinal de clock
            else
                count <= count + 1; -- incrementa contador
            end if;
        end if;
    end process;
    clk_out <= clk_signal; -- atribui o novo sinal de clok a porta de saída
end architecture rtl;