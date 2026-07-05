unit uFrmRelatorios;

{ ===========================================================================
  Central de RELATÓRIOS.
  Escolhe o período e chama o serviço uRelatorios, que gera o HTML e abre no
  navegador. Cada botão = um relatório.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.DateUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  uRelatorios;

type
  TFrmRelatorios = class(TForm)
    lblPeriodo: TLabel;
    lblAte: TLabel;
    dtpIni: TDateTimePicker;
    dtpFim: TDateTimePicker;
    btnNotas: TButton;
    btnEstoque: TButton;
    btnVendasPDV: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnNotasClick(Sender: TObject);
    procedure btnEstoqueClick(Sender: TObject);
    procedure btnVendasPDVClick(Sender: TObject);
  end;

var
  FrmRelatorios: TFrmRelatorios;

implementation

{$R *.dfm}

procedure TFrmRelatorios.FormCreate(Sender: TObject);
begin
  // Período padrão: mês corrente
  dtpIni.Date := EncodeDate(YearOf(Now), MonthOf(Now), 1);
  dtpFim.Date := Date;
end;

procedure TFrmRelatorios.btnNotasClick(Sender: TObject);
var
  Rel: TServicoRelatorios;
begin
  Rel := TServicoRelatorios.Create;
  try
    Rel.NotasPorPeriodo(dtpIni.Date, dtpFim.Date);
  finally
    Rel.Free;
  end;
end;

procedure TFrmRelatorios.btnEstoqueClick(Sender: TObject);
var
  Rel: TServicoRelatorios;
begin
  Rel := TServicoRelatorios.Create;
  try
    Rel.PosicaoEstoque;
  finally
    Rel.Free;
  end;
end;

procedure TFrmRelatorios.btnVendasPDVClick(Sender: TObject);
var
  Rel: TServicoRelatorios;
begin
  Rel := TServicoRelatorios.Create;
  try
    Rel.VendasPDV(dtpIni.Date, dtpFim.Date);
  finally
    Rel.Free;
  end;
end;

procedure TFrmRelatorios.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
