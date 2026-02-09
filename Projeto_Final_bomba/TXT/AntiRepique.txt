-- Esse modulo garante que ao pressinar o botao uma unica vez ele sera lido como unico pulso

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AntiRepique is
    port (
        clk       : in  std_logic; -- Entrada de clock principal
        reset     : in  std_logic; -- Sinal de reset para reiniciar o jogo
        button_in : in  std_logic; -- Entrada do botão
        pulse_out : out std_logic  -- Saída do pulso 
    );
end entity AntiRepique;

architecture rtl of AntiRepique is
    constant DEBOUNCE_LIMIT : integer := 500000; -- define o tempo de espera (10ms)
	 
	 -- Define os estados da maquina de estados
    type state_t is (IDLE, WAIT_STABLE, WAIT_RELEASE);
    signal state      : state_t := IDLE; -- Amazena o estado atual
    signal counter    : integer range 0 to DEBOUNCE_LIMIT := 0; -- contador para o tempo de espera
	 
begin
    process(clk, reset)
	 
    begin
        if reset = '1' then  -- Se o sial de reset estiver ativo, reinicia o jogo 
            state <= IDLE;
            counter <= 0;
            pulse_out <= '0';
				
        elsif rising_edge(clk) then -- Clock
            pulse_out <= '0'; -- Padrao saida 0
				
            case state is
                when IDLE => -- Espera o botao ser pressionado
                    if button_in = '1' then
                        state <= WAIT_STABLE; -- Botao pressionado -> estado de verificacao
                    end if;
                    counter <= 0; -- zera contador
						  
                when WAIT_STABLE => -- verifica se o botao fica pressionado por um tempo
                    if button_in = '0' then -- se foi ruído e o botao soltou, volta para IDLE
                        state <= IDLE;
								
                    elsif counter = DEBOUNCE_LIMIT then -- se o tempo foi atingido
                        pulse_out <= '1'; -- gera pulso de síada válido
                        state <= WAIT_RELEASE; -- vai para o estado correspondente ao botao
								
                    end if;
                    counter <= counter + 1; -- incrementa contador
						  
                when WAIT_RELEASE => -- botao valido, vai para um novo ciclo
                    if button_in = '0' then
                        state <= IDLE; -- botao solto volta ao stado inicial
                    end if;
                    counter <= 0; -- mantem o contador zerado
            end case;
        end if;
    end process;
end architecture rtl;