-- o usuario so pode tentar acertar a senha 3 vezes, esse modulo garnate a contagem de tentativas 


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ControleTentativas is
    port (
        clk            : in  std_logic; -- clock
        reset          : in  std_logic; -- sinal de reset
        check_attempt  : in  std_logic; -- pulso que indica uma tentativa
        sem_tentativas : out std_logic -- sinaliza 1 quando as tentativas acabam
    );
end entity ControleTentativas;

architecture rtl of ControleTentativas is
    signal tentativas_restantes : integer range 0 to 3 := 3; -- numero de tentativas = 3
begin
    process(clk, reset)
    begin
        if reset = '1' then -- no reset, o numero de tenativas volta para 3
            tentativas_restantes <= 3;
        elsif rising_edge(clk) then
            if check_attempt = '1' then -- recebe o pulso de tenativa
                if tentativas_restantes > 0 then
                    tentativas_restantes <= tentativas_restantes - 1; -- decrementa contador 
                end if;
            end if;
        end if;
    end process;
    sem_tentativas <= '1' when tentativas_restantes = 0 else '0'; -- se o contador for 0, a saída 'sem_tentativas' é '1'
end architecture rtl;