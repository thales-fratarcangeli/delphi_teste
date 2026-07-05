program TelemetriaService;

{ ===========================================================================
  SERVIÇO DE TELEMETRIA (Windows Service).
  Um "serviço" é um programa que roda no fundo do Windows, sem janela, mesmo
  sem ninguém logado. Este aqui fica verificando, de tempos em tempos, se o
  ERP está sendo usado (se o Launcher/Faturamento estão abertos) e registra
  isso num arquivo. Numa versão real, ele enviaria esses dados para um servidor
  central da empresa (telemetria = medir/uso).

  Como instalar/remover o serviço (Prompt de Comando como ADMINISTRADOR):
     TelemetriaService.exe /install     -> instala o serviço no Windows
     TelemetriaService.exe /uninstall   -> remove
  Depois, inicie pelo "Serviços" do Windows (services.msc) ou:
     net start SrvTelemetria
  =========================================================================== }

uses
  Vcl.SvcMgr,
  uServicoTelemetria in 'uServicoTelemetria.pas' {SrvTelemetria: TService};

{$R *.res}

begin
  // Inicialização padrão de um Service Application do Delphi
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TSrvTelemetria, SrvTelemetria);
  Application.Run;
end.
