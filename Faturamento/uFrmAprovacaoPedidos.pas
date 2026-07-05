unit uFrmAprovacaoPedidos;

{ ===========================================================================
  Tela de APROVAÇÃO DE PEDIDOS.
  Lista os pedidos pendentes e permite Aprovar ou Reprovar. Só quem tem a
  permissão 'FAT.PED.APROVAR' consegue usar os botões (senão eles ficam
  desabilitados). Toda ação vai para o log da tela.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Dialogs,
  Data.DB, FireDAC.Comp.Client;

type
  TFrmAprovacaoPedidos = class(TForm)
    pnlTopo: TPanel;
    btnAprovar: TButton;
    btnReprovar: TButton;
    btnAtualizar: TButton;
    Grid: TDBGrid;
    qryPedidos: TFDQuery;
    dsPedidos: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnAprovarClick(Sender: TObject);
    procedure btnReprovarClick(Sender: TObject);
  private
    procedure Carregar;
    procedure Decidir(NovoStatus: Char; const AcaoTexto: string);
  end;

var
  FrmAprovacaoPedidos: TFrmAprovacaoPedidos;

implementation

{$R *.dfm}

uses
  uDM, uSessao, uPermissoes, uLog;

procedure TFrmAprovacaoPedidos.FormCreate(Sender: TObject);
var
  PodeAprovar: Boolean;
begin
  qryPedidos.Connection := DM.Conn;

  // Aplica a permissão: se o usuário não pode aprovar, botões ficam bloqueados
  PodeAprovar := TPermissoes.Pode('FAT.PED.APROVAR');
  btnAprovar.Enabled := PodeAprovar;
  btnReprovar.Enabled := PodeAprovar;

  Carregar;
end;

procedure TFrmAprovacaoPedidos.Carregar;
begin
  qryPedidos.Close;
  qryPedidos.SQL.Text :=
    'SELECT P.ID, P.DATA_PEDIDO, C.NOME AS CLIENTE, P.VALOR_TOTAL, P.STATUS ' +
    'FROM PEDIDOS P JOIN CLIENTES C ON C.ID = P.ID_CLIENTE ' +
    'WHERE P.STATUS = ''P'' ORDER BY P.DATA_PEDIDO';
  qryPedidos.Open;
end;

procedure TFrmAprovacaoPedidos.btnAtualizarClick(Sender: TObject);
begin
  Carregar;
end;

{ Aprova (A) ou Reprova (R) o pedido selecionado. }
procedure TFrmAprovacaoPedidos.Decidir(NovoStatus: Char; const AcaoTexto: string);
var
  IdPedido: Integer;
begin
  if qryPedidos.IsEmpty then
  begin
    ShowMessage('Selecione um pedido.');
    Exit;
  end;

  IdPedido := qryPedidos.FieldByName('ID').AsInteger;

  DM.Conn.ExecSQL(
    'UPDATE PEDIDOS SET STATUS = :st, APROVADO_POR = :usr, ' +
    'DATA_APROVACAO = :dt WHERE ID = :id',
    [NovoStatus, UsuarioLogado.Id, Now, IdPedido]);

  TLog.Registrar(ClassName,
    Format('Pedido %d %s por %s.', [IdPedido, AcaoTexto, UsuarioLogado.Login]));

  ShowMessage('Pedido ' + IntToStr(IdPedido) + ' ' + AcaoTexto + '.');
  Carregar;
end;

procedure TFrmAprovacaoPedidos.btnAprovarClick(Sender: TObject);
begin
  Decidir('A', 'aprovado');
end;

procedure TFrmAprovacaoPedidos.btnReprovarClick(Sender: TObject);
begin
  Decidir('R', 'reprovado');
end;

procedure TFrmAprovacaoPedidos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
