-- modulo seletro de senha: selecionar uma senha de 4 bits de forma quase que aleatoria a cada vez que começar um jogo


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SeletorSenha is
    port (
        clk       : in  std_logic; -- clock 
        reset     : in  std_logic; -- sinal de reset
        senha_out : out std_logic_vector(3 downto 0) -- saída com a senha escolhida 
    );
end entity SeletorSenha;

architecture rtl of SeletorSenha is
-- define um tipo de dados para armazenar em vetor de senhas
    type password_array is array (0 to 7) of std_logic_vector(3 downto 0);
    constant senhas_disponiveis : password_array := (
	 -- contantes com as possiveis senhas 
        x"1", x"2", x"3", x"5",
        x"7", x"A", x"B", x"D"
    );
    signal fast_counter : unsigned(2 downto 0) := (others => '0'); -- contador rapido, garante a aleatoriedade
    signal selected_pass : std_logic_vector(3 downto 0) := senhas_disponiveis(0); -- armazena senha selecionada 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                fast_counter <= fast_counter + 1; -- enquanto o botao de reset estiver pressionado o contador gira
            else
				-- reset solto, entao o valor atual do contador é usado como indice para selecionar uma senha 
                selected_pass <= senhas_disponiveis(to_integer(fast_counter));
            end if;
        end if;
    end process;
    senha_out <= selected_pass;
end architecture rtl;