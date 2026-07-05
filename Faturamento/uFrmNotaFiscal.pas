unit uFrmNotaFiscal;

{ ===========================================================================
  Tela de NOTA FISCAL (janela filha MDI) - a tela mais importante para estudar.

  Uma nota fiscal tem DUAS partes (padrão "mestre-detalhe"):
    - CABEÇALHO: número, data, cliente, total  -> tabela NOTAS_FISCAIS
    - ITENS:     produtos, quantidade, preço    -> tabela ITENS_NOTA_FISCAL

  Aqui os itens são montados numa tabela EM MEMÓRIA (TFDMemTable). Só quando o
  usuário clica em "Salvar Nota" é que gravamos tudo no banco DENTRO DE UMA
  TRANSAÇÃO: ou grava a nota E todos os itens, ou não grava nada (rollback).
  Isso evita gravar uma nota "pela metade".
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.Mask,
  Vcl.Dialogs, Data.DB, FireDAC.Comp.Client, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt;

type
  TFrmNotaFiscal = class(TForm)
    pnlCabecalho: TPanel;
    lblNumero: TLabel;
    edtNumero: TEdit;
    lblData: TLabel;
    dtpEmissao: TDateTimePicker;
    lblCliente: TLabel;
    cboCliente: TComboBox;
    pnlItem: TPanel;
    lblProduto: TLabel;
    cboProduto: TComboBox;
    lblQtd: TLabel;
    edtQtd: TEdit;
    btnAddItem: TButton;
    btnDelItem: TButton;
    Grid: TDBGrid;
    pnlRodape: TPanel;
    lblTotalCap: TLabel;
    lblTotal: TLabel;
    btnNova: TButton;
    btnSalvar: TButton;
    memItens: TFDMemTable;
    dsItens: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAddItemClick(Sender: TObject);
    procedure btnDelItemClick(Sender: TObject);
    procedure btnNovaClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    procedure CarregarClientes;
    procedure CarregarProdutos;
    procedure CriarTabelaItensMemoria;
    procedure NovaNota;
    procedure AtualizarTotal;
    function IdSelecionado(Combo: TComboBox): Integer;
  end;

var
  FrmNotaFiscal: TFrmNotaFiscal;

implementation

{$R *.dfm}

uses
  uDM;

procedure TFrmNotaFiscal.FormCreate(Sender: TObject);
begin
  CriarTabelaItensMemoria;
  CarregarClientes;
  CarregarProdutos;
  NovaNota;
end;

procedure TFrmNotaFiscal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

{ Cria em memória a "tabela" que vai segurar os itens enquanto o usuário digita.
  Definimos as colunas e chamamos CreateDataSet para ela existir vazia. }
procedure TFrmNotaFiscal.CriarTabelaItensMemoria;
begin
  memItens.Close;
  memItens.FieldDefs.Clear;
  memItens.FieldDefs.Add('ID_PRODUTO', ftInteger);
  memItens.FieldDefs.Add('DESCRICAO',  ftString, 80);
  memItens.FieldDefs.Add('QUANTIDADE', ftFloat);
  memItens.FieldDefs.Add('PRECO_UNIT', ftFloat);
  memItens.FieldDefs.Add('VALOR_TOTAL', ftFloat);
  memItens.CreateDataSet;
end;

{ Preenche o combo de clientes. Guardamos o ID de cada cliente no "Objects"
  do combo, para depois saber qual ID foi escolhido (ver IdSelecionado). }
procedure TFrmNotaFiscal.CarregarClientes;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT ID, NOME FROM CLIENTES ORDER BY NOME';
    Qry.Open;
    cboCliente.Clear;
    while not Qry.Eof do
    begin
      cboCliente.Items.AddObject(Qry.FieldByName('NOME').AsString,
                                 TObject(Qry.FieldByName('ID').AsInteger));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TFrmNotaFiscal.CarregarProdutos;
var
  Qry: TFDQuery;
begin
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT ID, DESCRICAO FROM PRODUTOS ORDER BY DESCRICAO';
    Qry.Open;
    cboProduto.Clear;
    while not Qry.Eof do
    begin
      cboProduto.Items.AddObject(Qry.FieldByName('DESCRICAO').AsString,
                                 TObject(Qry.FieldByName('ID').AsInteger));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

{ Devolve o ID guardado no item selecionado do combo (ou 0 se nada escolhido). }
function TFrmNotaFiscal.IdSelecionado(Combo: TComboBox): Integer;
begin
  if Combo.ItemIndex < 0 then
    Result := 0
  else
    Result := Integer(Combo.Items.Objects[Combo.ItemIndex]);
end;

{ Zera a tela para começar uma nota nova. }
procedure TFrmNotaFiscal.NovaNota;
begin
  edtNumero.Text := '';
  dtpEmissao.Date := Date;   // data de hoje
  cboCliente.ItemIndex := -1;
  cboProduto.ItemIndex := -1;
  edtQtd.Text := '1';
  memItens.EmptyDataSet;     // limpa os itens
  AtualizarTotal;
end;

procedure TFrmNotaFiscal.btnNovaClick(Sender: TObject);
begin
  NovaNota;
end;

{ Soma o VALOR_TOTAL de todos os itens e mostra no rodapé. }
procedure TFrmNotaFiscal.AtualizarTotal;
var
  Total: Double;
begin
  Total := 0;
  memItens.First;
  while not memItens.Eof do
  begin
    Total := Total + memItens.FieldByName('VALOR_TOTAL').AsFloat;
    memItens.Next;
  end;
  // Format('%m', ...) formata como dinheiro (R$)
  lblTotal.Caption := FormatFloat('R$ #,##0.00', Total);
end;

{ Adiciona um item na tabela em memória.
  Busca o preço do produto no banco e calcula quantidade * preço. }
procedure TFrmNotaFiscal.btnAddItemClick(Sender: TObject);
var
  Qry: TFDQuery;
  IdProduto: Integer;
  Qtd, Preco: Double;
begin
  IdProduto := IdSelecionado(cboProduto);
  if IdProduto = 0 then
  begin
    ShowMessage('Selecione um produto.');
    Exit;
  end;

  // StrToFloatDef converte texto em número; se falhar, usa 0.
  Qtd := StrToFloatDef(edtQtd.Text, 0);
  if Qtd <= 0 then
  begin
    ShowMessage('Informe uma quantidade maior que zero.');
    edtQtd.SetFocus;
    Exit;
  end;

  // Busca o preço de venda do produto escolhido
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

  // Insere a linha na tabela em memória
  memItens.Append;
  memItens.FieldByName('ID_PRODUTO').AsInteger := IdProduto;
  memItens.FieldByName('DESCRICAO').AsString   := cboProduto.Text;
  memItens.FieldByName('QUANTIDADE').AsFloat   := Qtd;
  memItens.FieldByName('PRECO_UNIT').AsFloat   := Preco;
  memItens.FieldByName('VALOR_TOTAL').AsFloat  := Qtd * Preco;
  memItens.Post;

  AtualizarTotal;

  // Prepara para o próximo item
  cboProduto.ItemIndex := -1;
  edtQtd.Text := '1';
  cboProduto.SetFocus;
end;

procedure TFrmNotaFiscal.btnDelItemClick(Sender: TObject);
begin
  if not memItens.IsEmpty then
  begin
    memItens.Delete;
    AtualizarTotal;
  end;
end;

{ Grava a nota + itens no banco dentro de UMA transação. }
procedure TFrmNotaFiscal.btnSalvarClick(Sender: TObject);
var
  IdNota, IdCliente: Integer;
  ValorTotal: Double;
begin
  // --- Validações antes de gravar ---
  if Trim(edtNumero.Text) = '' then
  begin
    ShowMessage('Informe o número da nota.');
    edtNumero.SetFocus;
    Exit;
  end;

  IdCliente := IdSelecionado(cboCliente);
  if IdCliente = 0 then
  begin
    ShowMessage('Selecione o cliente.');
    cboCliente.SetFocus;
    Exit;
  end;

  if memItens.IsEmpty then
  begin
    ShowMessage('Adicione pelo menos um item na nota.');
    Exit;
  end;

  // Total já calculado no rodapé; aqui recalculamos para gravar o número
  ValorTotal := 0;
  memItens.First;
  while not memItens.Eof do
  begin
    ValorTotal := ValorTotal + memItens.FieldByName('VALOR_TOTAL').AsFloat;
    memItens.Next;
  end;

  // --- Início da TRANSAÇÃO ---
  DM.Conn.StartTransaction;
  try
    // 1) Gera o ID da nota e insere o cabeçalho
    IdNota := DM.ProximoId('GEN_NOTAS_FISCAIS');
    DM.Conn.ExecSQL(
      'INSERT INTO NOTAS_FISCAIS (ID, NUMERO, DATA_EMISSAO, ID_CLIENTE, VALOR_TOTAL, SITUACAO) ' +
      'VALUES (:id, :numero, :data, :cliente, :total, ''A'')',
      [IdNota, StrToInt(edtNumero.Text), dtpEmissao.Date, IdCliente, ValorTotal]);

    // 2) Insere cada item apontando para o ID da nota recém-criada
    memItens.First;
    while not memItens.Eof do
    begin
      DM.Conn.ExecSQL(
        'INSERT INTO ITENS_NOTA_FISCAL (ID, ID_NOTA, ID_PRODUTO, QUANTIDADE, PRECO_UNIT, VALOR_TOTAL) ' +
        'VALUES (:id, :nota, :produto, :qtd, :preco, :total)',
        [DM.ProximoId('GEN_ITENS_NOTA_FISCAL'),
         IdNota,
         memItens.FieldByName('ID_PRODUTO').AsInteger,
         memItens.FieldByName('QUANTIDADE').AsFloat,
         memItens.FieldByName('PRECO_UNIT').AsFloat,
         memItens.FieldByName('VALOR_TOTAL').AsFloat]);
      memItens.Next;
    end;

    // 3) Deu tudo certo -> confirma no banco
    DM.Conn.Commit;

    ShowMessage('Nota fiscal salva com sucesso! (ID ' + IntToStr(IdNota) + ')');
    NovaNota;
  except
    on E: Exception do
    begin
      // Deu erro em qualquer passo -> desfaz TUDO
      DM.Conn.Rollback;
      ShowMessage('Erro ao salvar a nota. Nada foi gravado.' + sLineBreak +
                  'Detalhe: ' + E.Message);
    end;
  end;
end;

end.
