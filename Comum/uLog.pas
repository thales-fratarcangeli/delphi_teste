unit uLog;

{ ===========================================================================
  LOG do sistema.
  Cada tela grava seu próprio arquivo de log dentro da pasta \logs, com o nome
  da tela e a data. Ex.: logs\TFrmNotaFiscal_20260701.log

  Uso típico dentro de uma tela:
     TLog.Registrar(ClassName, 'Nota ' + IntToStr(Id) + ' salva.');
  (ClassName devolve o nome da classe do form, ex.: 'TFrmNotaFiscal')

  Detalhe importante: gravar arquivo pode ser chamado de várias partes ao
  mesmo tempo; por isso usamos uma "trava" (TCriticalSection) para não corromper
  o arquivo. Isso se chama proteção contra concorrência.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, System.SyncObjs;

type
  TLog = class
  private
    class var FTrava: TCriticalSection;
    class function PastaLogs: string;
  public
    class constructor Create;   // roda automaticamente ao carregar a unit
    class destructor Destroy;
    class procedure Registrar(const Origem, Mensagem: string);
  end;

implementation

uses
  uSessao;

class constructor TLog.Create;
begin
  FTrava := TCriticalSection.Create;
end;

class destructor TLog.Destroy;
begin
  FTrava.Free;
end;

class function TLog.PastaLogs: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'logs';
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);   // cria a pasta \logs se não existir
end;

class procedure TLog.Registrar(const Origem, Mensagem: string);
var
  Arquivo, Linha, Usuario: string;
begin
  // Nome do arquivo: <Origem>_<AAAAMMDD>.log
  Arquivo := IncludeTrailingPathDelimiter(PastaLogs) +
             Origem + '_' + FormatDateTime('yyyymmdd', Now) + '.log';

  // Se souber quem está logado, registra junto (útil para auditoria)
  if UsuarioLogado.Login <> '' then
    Usuario := UsuarioLogado.Login
  else
    Usuario := '(sem login)';

  Linha := Format('[%s] %s - %s',
    [FormatDateTime('hh:nn:ss', Now), Usuario, Mensagem]);

  FTrava.Enter;   // só uma gravação por vez
  try
    // TFile.AppendAllText adiciona a linha no fim do arquivo (cria se não existe)
    TFile.AppendAllText(Arquivo, Linha + sLineBreak, TEncoding.UTF8);
  finally
    FTrava.Leave;
  end;
end;

end.
