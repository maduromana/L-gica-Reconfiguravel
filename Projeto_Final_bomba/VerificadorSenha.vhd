-- modulo que compara a senha inserida pelo usuario com a senha correta


library ieee;
use ieee.std_logic_1164.all;

entity VerificadorSenha is
    port (
        senha_correta  : in  std_logic_vector(3 downto 0); -- senha do sistema
        senha_inserida : in  std_logic_vector(3 downto 0); -- senha do usuario
        is_correct     : out std_logic -- saida 1 se as senhas forem iguais e 0 se forem diferentes
    );
end entity VerificadorSenha;

architecture rtl of VerificadorSenha is
begin
    process(senha_correta, senha_inserida)
    begin
        if senha_correta = senha_inserida then
            is_correct <= '1';
        else
            is_correct <= '0';
        end if;
    end process;
end architecture rtl;