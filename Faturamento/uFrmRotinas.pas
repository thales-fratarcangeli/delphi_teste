unit uFrmRotinas;

{ ===========================================================================
  Tela de ROTINAS (integração com o Jenkins).
  Permite disparar uma rotina (job do Jenkins) e consultar o resultado da
  última execução. É a "cara" do serviço uServicoJenkins.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  uServicoJenkins;

type
  TFrmRotinas = class(TForm)
    pnlTopo: TPanel;
    lblJob: TLabel;
    cboJob: TComboBox;
    btnDisparar: TButton;
    btnStatus: TButton;
    memSaida: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnDispararClick(Sender: TObject);
    procedure btnStatusClick(Sender: TObject);
  private
    procedure Executar(Consultar: Boolean);
  end;

var
  FrmRotinas: TFrmRotinas;

implementation

{$R *.dfm}

uses
  uLog;

procedure TFrmRotinas.FormCreate(Sender: TObject);
begin
  // Exemplos de rotinas típicas de ERP que ficariam como jobs no Jenkins
  cboJob.Items.Add('fechamento-diario');
  cboJob.Items.Add('backup-banco');
  cboJob.Items.Add('gerar-sped-fiscal');
  cboJob.Items.Add('envio-nfe-pendentes');
  cboJob.ItemIndex := 0;
end;

procedure TFrmRotinas.Executar(Consultar: Boolean);
var
  Jenkins: TServicoJenkins;
  Resultado: string;
begin
  if cboJob.Text = '' then
  begin
    memSaida.Lines.Add('Escolha uma rotina.');
    Exit;
  end;

  Jenkins := TServicoJenkins.Create;
  try
    if Consultar then
      Resultado := Jenkins.StatusUltimaExecucao(cboJob.Text)
    else
      Resultado := Jenkins.DispararJob(cboJob.Text);
  finally
    Jenkins.Free;
  end;

  memSaida.Lines.Add(FormatDateTime('hh:nn:ss', Now) + ' - ' + Resultado);
  TLog.Registrar(ClassName, Resultado);
end;

procedure TFrmRotinas.btnDispararClick(Sender: TObject);
begin
  Executar(False);
end;

procedure TFrmRotinas.btnStatusClick(Sender: TObject);
begin
  Executar(True);
end;

procedure TFrmRotinas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
