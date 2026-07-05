unit uFrmPDV;

{ ===========================================================================
  PDV - Ponto de Venda (caixa).
  Monta uma venda rápida, escolhe a forma de pagamento e, quando é cartão,
  chama a maquininha (serviço TEF). No fim grava em VENDAS_PDV.

  Aqui juntamos: tabela em memória (itens) + serviço externo (TEF) + gravação
  em transação. É basicamente uma versão "de balcão" da nota fiscal.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.StrUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.Dialogs, Data.DB, FireDAC.Comp.Client,
  uServicoTEF;

type
  TFrmPDV = class(TForm)
    pnlItem: TPanel;
    lblProduto: TLabel;
    cboProduto: TComboBox;
    lblQtd: TLabel;
    edtQtd: TEdit;
    btnAddItem: TButton;
    Grid: TDBGrid;
    pnlRodape: TPanel;
    lblTotalCap: TLabel;
    lblTotal: TLabel;
    lblForma: TLabel;
    cboForma: TComboBox;
    btnFinalizar: TButton;
    btnCancelarVenda: TButton;
    memItens: TFDMemTable;
    dsItens: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddItemClick(Sender: TObject);
    procedure btnFinalizarClick(Sender: TObject);
    procedure btnCancelarVendaClick(Sender: TObject);
  private
    procedure CarregarProdutos;
    procedure CriarItensMemoria;
    function TotalVenda: Double;
    procedure AtualizarTotal;
    procedure NovaVenda;
  end;

var
  FrmPDV: TFrmPDV;

implementation

{$R *.dfm}

uses
  uDM;

procedure TFrmPDV.FormCreate(Sender: TObject);
begin
  CriarItensMemoria;
  CarregarProdutos;
  cboForma.ItemIndex := 0;
  NovaVenda;
end;

procedure TFrmPDV.CriarItensMemoria;
begin
  memItens.Close;
  memItens.FieldDefs.Clear;
  memItens.FieldDefs.Add('ID_PRODUTO', ftInteger);
  memItens.FieldDefs.Add('DESCRICAO', ftString, 80);
  memItens.FieldDefs.Add('QUANTIDADE', ftFloat);
  memItens.FieldDefs.Add('PRECO_UNIT', ftFloat);
  memItens.FieldDefs.Add('VALOR_TOTAL', ftFloat);
  memItens.CreateDataSet;
end;

procedure TFrmPDV.CarregarProdutos;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT ID, DESCRICAO, PRECO_VENDA FROM PRODUTOS ORDER BY DESCRICAO';
    Qry.Open;
    cboProduto.Clear;
    while not Qry.Eof do
    begin
      // Guardamos o ID no Objects e o preço no próprio texto seria ruim;
      // por simplicidade buscamos o preço de novo ao adicionar (ver abaixo).
      cboProduto.Items.AddObject(Qry.FieldByName('DESCRICAO').AsString,
                                 TObject(Qry.FieldByName('ID').AsInteger));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

function TFrmPDV.TotalVenda: Double;
begin
  Result := 0;
  memItens.First;
  while not memItens.Eof do
  begin
    Result := Result + memItens.FieldByName('VALOR_TOTAL').AsFloat;
    memItens.Next;
  end;
end;

procedure TFrmPDV.AtualizarTotal;
begin
  lblTotal.Caption := FormatFloat('R$ #,##0.00', TotalVenda);
end;

procedure TFrmPDV.NovaVenda;
begin
  memItens.EmptyDataSet;
  cboProduto.ItemIndex := -1;
  edtQtd.Text := '1';
  AtualizarTotal;
end;

procedure TFrmPDV.btnAddItemClick(Sender: TObject);
var
  Qry: TFDQuery;
  IdProduto: Integer;
  Qtd, Preco: Double;
begin
  if cboProduto.ItemIndex < 0 then
  begin
    ShowMessage('Selecione o produto.');
    Exit;
  end;
  IdProduto := Integer(cboProduto.Items.Objects[cboProduto.ItemIndex]);
  Qtd := StrToFloatDef(edtQtd.Text, 0);
  if Qtd <= 0 then
  begin
    ShowMessage('Quantidade inválida.');
    Exit;
  end;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT PRECO_VENDA FROM PRODUTOS WHERE ID = :id';
    Qry.ParamByName('id').AsInteger := IdProduto;
    Qry.Open;
    Preco := Qry.FieldByName('PRECO_VENDA').AsFloat;
  finally
    Qry.Free;
  end;

  memItens.Append;
  memItens.FieldByName('ID_PRODUTO').AsInteger := IdProduto;
  memItens.FieldByName('DESCRICAO').AsString := cboProduto.Text;
  memItens.FieldByName('QUANTIDADE').AsFloat := Qtd;
  memItens.FieldByName('PRECO_UNIT').AsFloat := Preco;
  memItens.FieldByName('VALOR_TOTAL').AsFloat := Qtd * Preco;
  memItens.Post;

  AtualizarTotal;
  cboProduto.ItemIndex := -1;
  edtQtd.Text := '1';
  cboProduto.SetFocus;
end;

procedure TFrmPDV.btnFinalizarClick(Sender: TObject);
var
  TEF: ITEF;
  ResTEF: TResultadoTEF;
  Total: Double;
  Forma: string;
  Bandeira, NSU, Autorizacao: string;
begin
  Total := TotalVenda;
  if Total <= 0 then
  begin
    ShowMessage('Adicione itens à venda.');
    Exit;
  end;

  Forma := cboForma.Text;
  Bandeira := '';
  NSU := '';
  Autorizacao := '';

  // Se for cartão, chama a maquininha (TEF)
  if (Forma = 'DEBITO') or (Forma = 'CREDITO') then
  begin
    TEF := CriarTEF;   // fábrica devolve a implementação (hoje: simulada)
    if Forma = 'DEBITO' then
      ResTEF := TEF.Pagar(Total, fpDebito, 1)
    else
      ResTEF := TEF.Pagar(Total, fpCredito, 1);

    if not ResTEF.Aprovado then
    begin
      ShowMessage('Pagamento NÃO aprovado: ' + ResTEF.Mensagem);
      Exit;
    end;
    Bandeira := ResTEF.Bandeira;
    NSU := ResTEF.NSU;
    Autorizacao := ResTEF.Autorizacao;
  end;

  // Grava a venda
  DM.Conn.ExecSQL(
    'INSERT INTO VENDAS_PDV (DATA_VENDA, VALOR_TOTAL, FORMA_PGTO, BANDEIRA, NSU, AUTORIZACAO) ' +
    'VALUES (:dt, :total, :forma, :band, :nsu, :aut)',
    [Now, Total, Forma, Bandeira, NSU, Autorizacao]);

  ShowMessage('Venda finalizada!' + sLineBreak +
              'Total: ' + FormatFloat('R$ #,##0.00', Total) + sLineBreak +
              'Forma: ' + Forma +
              IfThen(NSU <> '', sLineBreak + 'NSU: ' + NSU, ''));
  NovaVenda;
end;

procedure TFrmPDV.btnCancelarVendaClick(Sender: TObject);
begin
  NovaVenda;
end;

procedure TFrmPDV.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
