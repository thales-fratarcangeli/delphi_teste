unit uSessao;

{ ===========================================================================
  Unit de SESSÃO.
  Guarda, numa variável global, quem é o usuário que fez login.
  Como é uma variável global (declarada em "interface"), qualquer form de
  qualquer módulo que der "uses uSessao" enxerga o mesmo usuário logado.

  É um jeito simples e muito comum em ERPs Delphi de compartilhar informação
  entre telas sem ficar passando parâmetro de um form para o outro.
  =========================================================================== }

interface

type
  { Um "record" é uma estrutura que agrupa vários campos, parecido com uma
    struct em C ou uma classe só com dados. }
  TUsuarioLogado = record
    Id: Integer;
    Login: string;
    Nome: string;
    IdPerfil: Integer;   // qual perfil (Administrador, Vendedor...) -> permissões
  end;

var
  { Preenchida no login (Launcher\uFrmLogin.pas). }
  UsuarioLogado: TUsuarioLogado;

implementation

end.
