-- modulo para exibição do numero de 4 bits nos dois displays de 7 seg

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controlador_display is
    port (
        clk         : in  std_logic; -- clock
        reset       : in  std_logic; -- reset
        binary_in   : in  std_logic_vector(3 downto 0);-- o binario a ser exibido 
        hex0        : out std_logic_vector(6 downto 0);-- display unidade
        hex1        : out std_logic_vector(6 downto 0) -- display dezena
    );
end entity;

architecture rtl of controlador_display is

    component decodificador_7seg is
        port ( digit_in : in std_logic_vector(3 downto 0); segments_out : out std_logic_vector(6 downto 0) );
    end component;

    signal bcd_dezena : std_logic_vector(3 downto 0);
    signal bcd_unidade: std_logic_vector(3 downto 0);
    signal seg_dezena : std_logic_vector(6 downto 0);
    signal seg_unidade: std_logic_vector(6 downto 0);
    signal mux_clock  : std_logic := '0';
    signal mux_counter: integer range 0 to 50000 := 0;
    
begin
    process(binary_in) -- converter binarioi em dois digitos 
        variable num : integer;
    begin
        num := to_integer(unsigned(binary_in));
        if num < 10 then
            bcd_dezena  <= x"0";
            bcd_unidade <= std_logic_vector(to_unsigned(num, 4));
        else
            bcd_dezena  <= x"1";
            bcd_unidade <= std_logic_vector(to_unsigned(num - 10, 4));
        end if;
    end process;
    -- traduzir os digitos para 7 seg 
    decoder_unidade: decodificador_7seg port map (digit_in => bcd_unidade, segments_out => seg_unidade);
    decoder_dezena:  decodificador_7seg port map (digit_in => bcd_dezena,  segments_out => seg_dezena);
    
    process(clk, reset) -- clock para multiplexacao
    begin
        if reset = '1' then
            mux_counter <= 0;
            mux_clock <= '0';
        elsif rising_edge(clk) then
            if mux_counter = 50000 then
                mux_counter <= 0;
                mux_clock <= not mux_clock;
            else
                mux_counter <= mux_counter + 1;
            end if;
        end if;
    end process;
    
    process(mux_clock, bcd_dezena, seg_dezena, seg_unidade) -- alterna qual display acende ( multiplexacao)
    begin
        if mux_clock = '0' then
            hex0 <= seg_unidade; -- unidade no displai hex
            hex1 <= (others => '1'); -- apaga display dezena 
        else
            if bcd_dezena = x"0" then
                 hex1 <= (others => '1'); -- dezena no display hex1, apaga o display caso dezena = 0 
            else
                 hex1 <= seg_dezena;
            end if;
            hex0 <= (others => '1'); -- apaga display unidade 
        end if;
    end process;
end architecture;