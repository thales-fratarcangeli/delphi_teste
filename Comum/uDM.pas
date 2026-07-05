unit uDM;

{ ===========================================================================
  DATAMODULE (Módulo de Dados).
  Um DataModule é um "form invisível" onde a gente coloca os componentes de
  acesso a banco (conexão, queries etc.). Assim a conexão fica em UM lugar só
  e todas as telas usam a mesma.

  Aqui usamos FireDAC (padrão dos Delphi modernos) para conectar no Firebird.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, System.IniFiles,
  // --- Componentes do FireDAC ---
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef, FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client, FireDAC.Comp.UI, Data.DB;

type
  TDM = class(TDataModule)
    // Conexão principal com o banco
    Conn: TFDConnection;
    // "Driver link" do Firebird. Precisa existir para o FireDAC achar o fbclient.dll
    DrvFB: TFDPhysFBDriverLink;
    // Cursor de espera (ampulheta) durante consultas - exigido pelo FireDAC VCL
    WaitCursor: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure ConfigurarConexao;
  public
    { Retorna o próximo ID de uma tabela usando o generator do Firebird.
      Ex.: NovoId := DM.ProximoId('GEN_CLIENTES'); }
    function ProximoId(const NomeGenerator: string): Integer;

    { Preenche a sessão (UsuarioLogado) a partir do login, sem exigir senha.
      Usado pelos MÓDULOS: eles rodam como .exe separado do launcher, então
      não herdam a sessão. O launcher passa /usuario=LOGIN na linha de comando
      e o módulo recarrega os dados do usuário + suas permissões. }
    procedure InicializarSessaoModulo(const LoginPadrao: string = 'admin');
  end;

var
  DM: TDM;

implementation

{$R *.dfm}

uses
  uSessao, uPermissoes;

{ Lê o config.ini (que fica ao lado do .exe) e monta a string de conexão. }
procedure TDM.ConfigurarConexao;
var
  Ini: TIniFile;
  CaminhoIni, Banco: string;
begin
  // ExtractFilePath(ParamStr(0)) = pasta onde está o executável rodando
  CaminhoIni := ExtractFilePath(ParamStr(0)) + 'config.ini';

  // Erro comum: o config.ini não foi copiado para junto do .exe.
  // Sem ele, o caminho do banco fica vazio e a conexão falha com uma mensagem
  // confusa. Então avisamos de forma clara ANTES de tentar conectar.
  if not FileExists(CaminhoIni) then
    raise Exception.Create(
      'O arquivo config.ini não foi encontrado ao lado do programa.' + sLineBreak +
      'Copie o config.ini para esta pasta:' + sLineBreak +
      ExtractFilePath(ParamStr(0)));

  Ini := TIniFile.Create(CaminhoIni);
  try
    Banco := Ini.ReadString('BancoDeDados', 'Database', '');
    if Banco = '' then
      raise Exception.Create(
        'O caminho do banco (Database=) está vazio no config.ini.');
    if not FileExists(Banco) then
      raise Exception.Create(
        'O arquivo do banco não existe:' + sLineBreak + Banco + sLineBreak +
        'Rode o banco\criar_banco.bat para criar o ERP.FDB.');

    Conn.Params.Clear;
    Conn.Params.DriverID := 'FB';                                   // Firebird
    Conn.Params.Database := Banco;
    Conn.Params.UserName := Ini.ReadString('BancoDeDados', 'User', 'SYSDBA');
    Conn.Params.Password := Ini.ReadString('BancoDeDados', 'Password', 'masterkey');
    Conn.Params.Add('Protocol=TCPIP');
    Conn.Params.Add('Server=' + Ini.ReadString('BancoDeDados', 'Server', 'localhost'));
    Conn.Params.Add('Port='   + Ini.ReadString('BancoDeDados', 'Port', '3050'));
    Conn.Params.Add('CharacterSet=' + Ini.ReadString('BancoDeDados', 'CharacterSet', 'WIN1252'));
    // LoginPrompt = False -> não abre a janelinha pedindo usuário/senha do banco
    Conn.LoginPrompt := False;
  finally
    Ini.Free;
  end;
end;

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  ConfigurarConexao;
  try
    Conn.Connected := True;   // tenta abrir a conexão já na inicialização
  except
    on E: Exception do
      // Repassa o erro com uma mensagem mais amigável
      raise Exception.Create(
        'Não foi possível conectar no banco de dados.' + sLineBreak +
        'Confira o arquivo config.ini e se o Firebird está rodando.' + sLineBreak +
        sLineBreak + 'Detalhe técnico: ' + E.Message);
  end;
end;

function TDM.ProximoId(const NomeGenerator: string): Integer;
begin
  // GEN_ID(gerador, 1) incrementa o gerador em 1 e devolve o novo valor.
  // RDB$DATABASE é uma tabela "de sistema" que sempre tem exatamente 1 linha,
  // por isso é usada quando queremos um SELECT que retorna um valor só.
  Result := Conn.ExecSQLScalar(
    'SELECT GEN_ID(' + NomeGenerator + ', 1) FROM RDB$DATABASE');
end;

procedure TDM.InicializarSessaoModulo(const LoginPadrao: string);
var
  Login, Param: string;
  i: Integer;
  Qry: TFDQuery;
begin
  // 1) Procura o parâmetro /usuario=LOGIN na linha de comando
  Login := '';
  for i := 1 to ParamCount do
  begin
    Param := ParamStr(i);
    if Param.StartsWith('/usuario=') then
      Login := Copy(Param, Length('/usuario=') + 1, MaxInt);
  end;
  // Se rodar direto pela IDE (sem parâmetro), usa um login padrão para testar
  if Login = '' then
    Login := LoginPadrao;

  // 2) Recarrega os dados do usuário a partir do banco
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := Conn;
    Qry.SQL.Text := 'SELECT ID, LOGIN, NOME, ID_PERFIL FROM USUARIOS WHERE LOGIN = :l';
    Qry.ParamByName('l').AsString := Login;
    Qry.Open;
    if not Qry.IsEmpty then
    begin
      UsuarioLogado.Id       := Qry.FieldByName('ID').AsInteger;
      UsuarioLogado.Login    := Qry.FieldByName('LOGIN').AsString;
      UsuarioLogado.Nome     := Qry.FieldByName('NOME').AsString;
      UsuarioLogado.IdPerfil := Qry.FieldByName('ID_PERFIL').AsInteger;
    end;
  finally
    Qry.Free;
  end;

  // 3) Carrega as permissões do perfil desse usuário
  TPermissoes.Carregar(UsuarioLogado.IdPerfil);
end;

end.
