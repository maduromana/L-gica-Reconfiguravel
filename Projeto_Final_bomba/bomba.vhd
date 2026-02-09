-- --------------------------------
-- Modulo principal 
-- PROJETO FINAL: Jogo para desarmar uma bomba
-- Grupo: Maria Eduarda Romana, Nicolas Romano e Tiago Soucek
-- --------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bomba is
    port (
        CLOCK_50 : in  std_logic;
        SW       : in  std_logic_vector(3 downto 0);
        KEY      : in  std_logic_vector(1 downto 0);
        LEDR     : out std_logic_vector(9 downto 0);
        HEX0     : out std_logic_vector(6 downto 0);
        HEX1     : out std_logic_vector(6 downto 0)
    );
end entity bomba;

architecture rtl of bomba is

    -- Declaracao do componente AntiRepique 
    component AntiRepique is
        port ( clk : in std_logic; reset : in std_logic; button_in: in std_logic; pulse_out: out std_logic );
    end component;

    component DivisorDeClock is
        port ( clk_in : in std_logic; reset : in std_logic; clk_out : out std_logic );
    end component;
	 
    component SeletorSenha is
        port ( clk : in std_logic; reset : in std_logic; senha_out : out std_logic_vector(3 downto 0) );
    end component;
	 
    component VerificadorSenha is
        port ( senha_correta : in std_logic_vector(3 downto 0); senha_inserida : in std_logic_vector(3 downto 0); is_correct : out std_logic );
    end component;
	 
    component ControleTentativas is
        port ( clk : in std_logic; reset : in std_logic; check_attempt : in std_logic; sem_tentativas : out std_logic );
    end component;
	 
    component Temporizador is
        port ( clk_1hz : in std_logic; reset : in std_logic; enable : in std_logic; led_out : out std_logic_vector(9 downto 0); time_is_up : out std_logic );
    end component;
	 
    component controlador_display is
        port ( clk : in std_logic; reset : in std_logic; binary_in : in std_logic_vector(3 downto 0); hex0 : out std_logic_vector(6 downto 0); hex1 : out std_logic_vector(6 downto 0) );
    end component;

    -- Sinais
    type state_t is (S_ARMED, S_CHECK, S_DEFUSED, S_EXPLODED);
    signal current_state : state_t := S_ARMED; -- sinal que aguarda estado atual 

    signal reset_signal       : std_logic; -- sinal de reset 
    signal confirm_pulse      : std_logic; -- pulso botao de confirmacao
    signal clk_1hz_signal     : std_logic; -- clock gerado 
    signal senha_selecionada  : std_logic_vector(3 downto 0); -- senha a ser adivinhada
    signal senha_correta_flag : std_logic; -- 1 se a senha foi correta
    signal tempo_esgotado     : std_logic; -- 1 se o timer chegr em zero 
    signal tentativas_esgotadas : std_logic; -- 1 se acabar as tentativas
    signal timer_led_out      : std_logic_vector(9 downto 0); -- leds do timer
    
    signal check_attempt_flag : std_logic := '0'; -- pulso para avisar ControleTentativas
    signal timer_enable       : std_logic := '0'; -- habilita contador do timer
    
    signal ledr_s             : std_logic_vector(9 downto 0); -- sinal para controlar leds
    signal fast_blink_signal  : std_logic := '0'; -- sinal para piscar os led de froma rapida 

    constant BLINK_MAX_COUNT : integer := 3125000; -- contador do "pisca-pisca"
    signal blink_counter : integer range 0 to BLINK_MAX_COUNT := 0;

begin
    reset_signal <= not KEY(1); -- inverte nivel logico do botao

    -- Instanciação do AntiRepique 
    inst_anti_repique: AntiRepique
        port map (
            clk       => CLOCK_50,
            reset     => reset_signal, -- Conexão de reset adicionada
            button_in => not KEY(0),
            pulse_out => confirm_pulse
        );

    inst_divisor_clock : DivisorDeClock port map (clk_in => CLOCK_50, reset => reset_signal, clk_out => clk_1hz_signal);
    inst_seletor_senha : SeletorSenha port map (clk => CLOCK_50, reset => reset_signal, senha_out => senha_selecionada);
    inst_verificador_senha : VerificadorSenha port map (senha_correta => senha_selecionada, senha_inserida => SW, is_correct => senha_correta_flag);
    inst_controle_tentativas : ControleTentativas port map (clk => CLOCK_50, reset => reset_signal, check_attempt => check_attempt_flag, sem_tentativas => tentativas_esgotadas);
    inst_temporizador : Temporizador port map (clk_1hz => clk_1hz_signal, reset => reset_signal, enable => timer_enable, led_out => timer_led_out, time_is_up => tempo_esgotado);
    inst_controlador_display: controlador_display port map (clk => CLOCK_50, reset => reset_signal, binary_in => senha_selecionada, hex0 => HEX0, hex1 => HEX1);

    -- maquina de estados finitos 
    fsm_process: process(CLOCK_50, reset_signal)
    begin
        if reset_signal = '1' then -- reset assincrono 
            current_state <= S_ARMED;
        elsif rising_edge(CLOCK_50) then -- sincrona 
            check_attempt_flag <= '0';
            timer_enable       <= '0';
            case current_state is
                when S_ARMED =>
                    timer_enable <= '1'; -- habilita o temporizador
                    if tempo_esgotado = '1' or tentativas_esgotadas = '1' then -- se o tempo acabou as tentativas acabaram = bomba explode 
                        current_state <= S_EXPLODED;
                    elsif confirm_pulse = '1' then -- verifica senha apos o botao de confirmacao ser precionado 
                        current_state <= S_CHECK;
                    end if;
                when S_CHECK =>
                    if senha_correta_flag = '1' then -- se a senha inserida for corrtea a bomba é desarmada 
                        current_state <= S_DEFUSED;
                    else -- se for incorreta 
                        check_attempt_flag <= '1'; -- gasta uma tentativa
                        current_state <= S_ARMED; -- volta ao estado armado 
                    end if;
                when S_DEFUSED | S_EXPLODED =>
                    null;
            end case;
        end if;
    end process fsm_process;
    
    -- Processo do pisca-pisca 
    fast_blinking_process: process(CLOCK_50, reset_signal)
    begin
        if reset_signal = '1' then
            blink_counter <= 0;
            fast_blink_signal <= '0';
        elsif rising_edge(CLOCK_50) then
            if blink_counter = BLINK_MAX_COUNT then
                blink_counter <= 0;
                fast_blink_signal <= not fast_blink_signal;
            else
                blink_counter <= blink_counter + 1;
            end if;
        end if;
    end process fast_blinking_process;

    -- define quais leds vao mostrar em cada estado do jogo 
    led_output_logic: process(current_state, timer_led_out, fast_blink_signal)
    begin
        case current_state is
            when S_ARMED | S_CHECK =>
                ledr_s <= timer_led_out;
            when S_DEFUSED =>
                if fast_blink_signal = '1' then -- senha correta padrão especifico
                   ledr_s <= "1010101010";
                else
                   ledr_s <= "0000000000";
                end if;
            when S_EXPLODED => -- bomba explodiu = pisca tdoso os leds juntos 
                if fast_blink_signal = '1' then
                    ledr_s <= (others => '1');
                else
                    ledr_s <= (others => '0');
                end if;
        end case;
    end process led_output_logic;
    
    LEDR <= ledr_s;

end architecture rtl;