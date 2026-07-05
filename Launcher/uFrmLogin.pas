unit uFrmLogin;

{ ===========================================================================
  Tela de LOGIN.
  Pede login e senha, consulta a tabela USUARIOS no banco e, se encontrar,
  guarda o usuário na sessão (uSessao) e fecha com ModalResult = mrOk.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs,
  Data.DB, FireDAC.Stan.Param, FireDAC.Comp.Client;

type
  TFrmLogin = class(TForm)
    pnlFundo: TPanel;
    lblTitulo: TLabel;
    lblLogin: TLabel;
    lblSenha: TLabel;
    edtLogin: TEdit;
    edtSenha: TEdit;
    btnEntrar: TButton;
    btnCancelar: TButton;
    procedure btnEntrarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
  end;

var
  FrmLogin: TFrmLogin;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uLicenca, uPermissoes, uLog;

procedure TFrmLogin.btnEntrarClick(Sender: TObject);
var
  Qry: TFDQuery;
  StatusLic: TStatusLicenca;
begin
  // Validação simples dos campos antes de ir ao banco
  if Trim(edtLogin.Text) = '' then
  begin
    ShowMessage('Informe o login.');
    edtLogin.SetFocus;
    Exit;
  end;

  // Criamos uma query "na mão" só para esta consulta e liberamos no final.
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    // Usamos PARÂMETROS (:login, :senha) em vez de concatenar texto na SQL.
    // Isso é mais seguro (evita SQL Injection) e é a forma correta.
    Qry.SQL.Text :=
      'SELECT ID, LOGIN, NOME, ID_PERFIL FROM USUARIOS ' +
      'WHERE LOGIN = :login AND SENHA = :senha AND ATIVO = ''S''';
    Qry.ParamByName('login').AsString := Trim(edtLogin.Text);
    Qry.ParamByName('senha').AsString := edtSenha.Text;
    Qry.Open;

    if Qry.IsEmpty then
    begin
      ShowMessage('Login ou senha inválidos.');
      edtSenha.SetFocus;
      Exit;
    end;

    // ---- Antes de liberar, checa a LICENÇA (boleto/mensalidade) ----
    StatusLic := TLicenca.Verificar;
    if not StatusLic.Liberado then
    begin
      TLog.Registrar('Login', 'Acesso BLOQUEADO por licença: ' + edtLogin.Text);
      ShowMessage('ACESSO BLOQUEADO' + sLineBreak + sLineBreak + StatusLic.Mensagem);
      Exit;   // não deixa entrar
    end;

    // Deu certo: guarda o usuário na sessão global
    UsuarioLogado.Id       := Qry.FieldByName('ID').AsInteger;
    UsuarioLogado.Login    := Qry.FieldByName('LOGIN').AsString;
    UsuarioLogado.Nome     := Qry.FieldByName('NOME').AsString;
    UsuarioLogado.IdPerfil := Qry.FieldByName('ID_PERFIL').AsInteger;

    // Carrega as permissões do perfil desse usuário
    TPermissoes.Carregar(UsuarioLogado.IdPerfil);

    // Registra o login no log e, se a licença estiver perto de vencer, avisa
    TLog.Registrar('Login', 'Login efetuado: ' + UsuarioLogado.Login);
    if StatusLic.DiasRestantes <= 5 then
      ShowMessage(StatusLic.Mensagem);

    ModalResult := mrOk;   // fecha a janela sinalizando sucesso
  finally
    Qry.Free;
  end;
end;

procedure TFrmLogin.btnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;  // fecha sinalizando que o usuário desistiu
end;

end.
