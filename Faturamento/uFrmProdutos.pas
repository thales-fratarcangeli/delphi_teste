unit uFrmProdutos;

{ ===========================================================================
  Tela de CADASTRO DE PRODUTOS (janela filha MDI).
  Mesma estrutura da tela de Clientes: DBGrid + DBNavigator + FDQuery.
  Estude as duas juntas para perceber o padrão que se repete nos cadastros.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls,
  Data.DB, FireDAC.Comp.Client;

type
  TFrmProdutos = class(TForm)
    pnlTopo: TPanel;
    Nav: TDBNavigator;
    Grid: TDBGrid;
    qryProdutos: TFDQuery;
    dsProdutos: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure qryProdutosBeforePost(DataSet: TDataSet);
  end;

var
  FrmProdutos: TFrmProdutos;

implementation

{$R *.dfm}

uses
  uDM;

procedure TFrmProdutos.FormCreate(Sender: TObject);
begin
  qryProdutos.Connection := DM.Conn;
  qryProdutos.SQL.Text := 'SELECT * FROM PRODUTOS ORDER BY DESCRICAO';
  qryProdutos.Open;
end;

procedure TFrmProdutos.qryProdutosBeforePost(DataSet: TDataSet);
begin
  if DataSet.State = dsInsert then
    if DataSet.FieldByName('ID').IsNull then
      DataSet.FieldByName('ID').AsInteger := DM.ProximoId('GEN_PRODUTOS');
end;

procedure TFrmProdutos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
