unit uFrmAssistenteIA;

{ ===========================================================================
  Janela de CHAT do Assistente de IA.
  É aberta pela "bolinha" no canto inferior direito (ver uFrmPrincipal).
  Mostra o histórico da conversa e envia a pergunta para o serviço uServicoIA.

  Observação: a chamada à IA é síncrona (trava a tela até responder). Num
  sistema real, o ideal é rodar em uma thread para não "congelar" a interface.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  uServicoIA;

type
  TFrmAssistenteIA = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    memHistorico: TMemo;
    pnlBaixo: TPanel;
    edtPergunta: TEdit;
    btnEnviar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnEnviarClick(Sender: TObject);
  private
    FServico: TServicoIA;
  end;

var
  FrmAssistenteIA: TFrmAssistenteIA;

implementation

{$R *.dfm}

uses
  uConfig;

procedure TFrmAssistenteIA.FormCreate(Sender: TObject);
begin
  FServico := TServicoIA.Create;
  lblTitulo.Caption := TConfig.IA.NomeAssistente;
  memHistorico.Clear;
  memHistorico.Lines.Add('Olá! Sou seu assistente. Pergunte algo sobre o sistema.');
  if not FServico.TemChaveConfigurada then
    memHistorico.Lines.Add('(Dica: configure a ApiKey na seção [IA] do config.ini.)');
end;

procedure TFrmAssistenteIA.btnEnviarClick(Sender: TObject);
var
  Pergunta, Resposta: string;
begin
  Pergunta := Trim(edtPergunta.Text);
  if Pergunta = '' then Exit;

  memHistorico.Lines.Add('');
  memHistorico.Lines.Add('Você: ' + Pergunta);
  edtPergunta.Clear;

  // Feedback visual enquanto espera
  memHistorico.Lines.Add('Assistente: pensando...');
  btnEnviar.Enabled := False;
  Application.ProcessMessages;   // deixa a tela redesenhar
  try
    Resposta := FServico.Perguntar(Pergunta);
  finally
    btnEnviar.Enabled := True;
  end;

  // Troca o "pensando..." pela resposta
  memHistorico.Lines[memHistorico.Lines.Count - 1] := 'Assistente: ' + Resposta;
  edtPergunta.SetFocus;
end;

procedure TFrmAssistenteIA.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FServico.Free;
  Action := caFree;
  // Zera a referência global para a "bolinha" saber que a janela fechou
  FrmAssistenteIA := nil;
end;

end.
