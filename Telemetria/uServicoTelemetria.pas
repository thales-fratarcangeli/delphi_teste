unit uServicoTelemetria;

{ ===========================================================================
  A classe do serviço de telemetria (herda de TService).
  O método ServiceExecute roda em loop enquanto o serviço estiver ativo.
  A cada intervalo, verifica se o ERP está aberto e grava um "batimento".
  =========================================================================== }

interface

uses
  Winapi.Windows, Winapi.TlHelp32, System.SysUtils, System.Classes,
  Vcl.SvcMgr;

type
  TSrvTelemetria = class(TService)
    procedure ServiceExecute(Sender: TService);
  private
    procedure Registrar(const Texto: string);
    function ProcessoEstaRodando(const NomeExe: string): Boolean;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  SrvTelemetria: TSrvTelemetria;

implementation

{$R *.dfm}

{ O "controller" é exigido pelo Windows para conversar com o serviço. }
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  SrvTelemetria.Controller(CtrlCode);
end;

function TSrvTelemetria.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

{ Grava uma linha no arquivo de telemetria (ao lado do .exe do serviço). }
procedure TSrvTelemetria.Registrar(const Texto: string);
var
  Arquivo: string;
  F: TextFile;
begin
  Arquivo := ExtractFilePath(ParamStr(0)) + 'telemetria.log';
  AssignFile(F, Arquivo);
  try
    if FileExists(Arquivo) then
      Append(F)
    else
      Rewrite(F);
    Writeln(F, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now) + ' - ' + Texto);
  finally
    CloseFile(F);
  end;
end;

{ Percorre a lista de processos do Windows procurando um .exe pelo nome.
  Usa a API TlHelp32 (snapshot dos processos). }
function TSrvTelemetria.ProcessoEstaRodando(const NomeExe: string): Boolean;
var
  Snap: THandle;
  Proc: TProcessEntry32;
begin
  Result := False;
  Snap := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Snap = INVALID_HANDLE_VALUE then Exit;
  try
    Proc.dwSize := SizeOf(Proc);
    if Process32First(Snap, Proc) then
    repeat
      if SameText(Proc.szExeFile, NomeExe) then
        Exit(True);
    until not Process32Next(Snap, Proc);
  finally
    CloseHandle(Snap);
  end;
end;

procedure TSrvTelemetria.ServiceExecute(Sender: TService);
var
  Contador: Integer;
  EmUso: Boolean;
begin
  Registrar('Serviço de telemetria iniciado.');

  // Enquanto o serviço não for parado, repete o ciclo
  while not Terminated do
  begin
    EmUso := ProcessoEstaRodando('Faturamento.exe') or
             ProcessoEstaRodando('Launcher.exe');

    if EmUso then
      Registrar('EM USO - ERP aberto nesta máquina.')
    else
      Registrar('OCIOSO - ERP fechado.');

    // >>> AQUI, numa versão real, você faria um POST HTTP enviando esse status
    //     para um servidor central de telemetria da empresa.

    // Espera ~30 segundos, mas em pedaços de 1s para responder rápido a um
    // pedido de "parar serviço" (ProcessRequests trata isso).
    Contador := 0;
    while (Contador < 30) and (not Terminated) do
    begin
      Sleep(1000);
      Inc(Contador);
      ServiceThread.ProcessRequests(False);
    end;
  end;

  Registrar('Serviço de telemetria parado.');
end;

end.
