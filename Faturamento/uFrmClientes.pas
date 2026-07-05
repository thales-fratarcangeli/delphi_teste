unit uFrmClientes;

{ ===========================================================================
  Tela de CADASTRO DE CLIENTES (janela filha MDI).
  Mostra os clientes numa grade (DBGrid) e permite incluir/editar/excluir
  usando o DBNavigator (aquela barrinha com setas e botões + - etc.).

  Componentes de banco de dados usados:
   - TFDQuery    -> executa o SELECT e mantém os dados em memória
   - TDataSource -> "ponte" entre a query e os componentes visuais (DBGrid)
   - TDBGrid     -> a grade que mostra os dados
   - TDBNavigator-> botões de navegar/incluir/editar/gravar/excluir
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Dialogs,
  Data.DB, FireDAC.Comp.Client;

type
  TFrmClientes = class(TForm)
    pnlTopo: TPanel;
    Nav: TDBNavigator;
    Grid: TDBGrid;
    qryClientes: TFDQuery;
    dsClientes: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure qryClientesBeforePost(DataSet: TDataSet);
  end;

var
  FrmClientes: TFrmClientes;

implementation

{$R *.dfm}

uses
  uDM;

procedure TFrmClientes.FormCreate(Sender: TObject);
begin
  // Liga a query na conexão do DataModule e abre os dados
  qryClientes.Connection := DM.Conn;
  qryClientes.SQL.Text := 'SELECT * FROM CLIENTES ORDER BY NOME';
  qryClientes.Open;
end;

{ Antes de gravar um registro NOVO, geramos o ID pelo generator do Firebird.
  (Em registros já existentes o ID não muda, então só fazemos isso no "insert".) }
procedure TFrmClientes.qryClientesBeforePost(DataSet: TDataSet);
begin
  if DataSet.State = dsInsert then
    if DataSet.FieldByName('ID').IsNull then
      DataSet.FieldByName('ID').AsInteger := DM.ProximoId('GEN_CLIENTES');
end;

procedure TFrmClientes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  // caFree faz a janela ser destruída ao fechar (libera memória).
  Action := caFree;
end;

end.
