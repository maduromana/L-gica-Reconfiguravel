-- modulo que cria uma contagem regressiva de 30segundos e controla os 10 led, para mostar o tempo restante


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Temporizador is
    port (
        clk_1hz    : in  std_logic; -- clock do DivisorClock
        reset      : in  std_logic; -- reset
        enable     : in  std_logic; -- contagem 
        led_out    : out std_logic_vector(9 downto 0); -- saida dos leds
        time_is_up : out std_logic -- sinaliza 1 quando o tempo acaba
    );
end entity Temporizador;

architecture rtl of Temporizador is
    constant INITIAL_TIME : integer := 30; -- tempo inicial do contador
    signal count : integer range 0 to INITIAL_TIME := INITIAL_TIME; -- sinal interno para contagem regressiva
begin
    process(clk_1hz, reset) -- processo que controla a contagem regressiva
    begin
        if reset = '1' then -- se reset pressionado, volta os 30s
            count <= INITIAL_TIME;
        elsif rising_edge(clk_1hz) then -- a cada pulso decrementa no tempo
            if enable = '1' and count > 0 then
                count <= count - 1;
            end if;
        end if;
    end process;
    time_is_up <= '1' when count = 0 else '0'; -- indicativo que o tempo acabou 
	 
    process(count) -- mapear tempo restante para os 10 leds
        variable leds_on : integer;
    begin
        if count > 0 then
		  -- cada led = 3 segundos
            leds_on := (count + 2) / 3;
            led_out <= (others => '0'); -- apaga todos os leds
            if leds_on > 0 then
                led_out(leds_on - 1 downto 0) <= (others => '1'); -- acende o numero correspondnete de leds
            end if;
        else
            led_out <= (others => '0'); -- tempo acabou = apaga todos 
        end if;
    end process;
end architecture rtl;