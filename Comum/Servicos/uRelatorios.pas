unit uRelatorios;

{ ===========================================================================
  SERVIÇO DE RELATÓRIOS.

  Observação de mercado: em Delphi, relatórios costumam ser feitos com
  ferramentas visuais como FastReport, QuickReport ou RaveReports (você
  "desenha" o relatório e liga nos dados). Como essas são bibliotecas extras,
  aqui geramos relatórios em HTML (que é só texto) e abrimos no navegador.
  A LÓGICA de buscar os dados no banco é a mesma; muda só a "impressão".
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, Winapi.ShellAPI, Winapi.Windows,
  Data.DB, FireDAC.Comp.Client;

type
  TServicoRelatorios = class
  private
    function CabecalhoHTML(const Titulo: string): string;
    function RodapeHTML: string;
    procedure AbrirNoNavegador(const HTML, NomeArquivo: string);
  public
    // Relatório de notas fiscais emitidas num período.
    procedure NotasPorPeriodo(DataIni, DataFim: TDate);
    // Relatório de produtos e estoque atual.
    procedure PosicaoEstoque;
    // Relatório de vendas do PDV.
    procedure VendasPDV(DataIni, DataFim: TDate);
  end;

implementation

uses
  uDM;

function TServicoRelatorios.CabecalhoHTML(const Titulo: string): string;
begin
  Result :=
    '<html><head><meta charset="utf-8"><style>' +
    'body{font-family:Segoe UI,Arial;margin:24px;color:#222}' +
    'h1{font-size:18px} table{border-collapse:collapse;width:100%}' +
    'th,td{border:1px solid #ccc;padding:6px 8px;font-size:13px;text-align:left}' +
    'th{background:#0a58ca;color:#fff} tr:nth-child(even){background:#f4f6fb}' +
    '.num{text-align:right}</style></head><body>' +
    '<h1>' + Titulo + '</h1>' +
    '<p>Emitido em ' + FormatDateTime('dd/mm/yyyy hh:nn', Now) + '</p>';
end;

function TServicoRelatorios.RodapeHTML: string;
begin
  Result := '</body></html>';
end;

{ Salva o HTML num arquivo temporário e manda o Windows abrir (no navegador). }
procedure TServicoRelatorios.AbrirNoNavegador(const HTML, NomeArquivo: string);
var
  Caminho: string;
  Lista: TStringList;
begin
  Caminho := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) + NomeArquivo;
  Lista := TStringList.Create;
  try
    Lista.Text := HTML;
    Lista.SaveToFile(Caminho, TEncoding.UTF8);
  finally
    Lista.Free;
  end;
  ShellExecute(0, 'open', PChar(Caminho), nil, nil, SW_SHOWNORMAL);
end;

procedure TServicoRelatorios.NotasPorPeriodo(DataIni, DataFim: TDate);
var
  Qry: TFDQuery;
  HTML: TStringBuilder;
begin
  Qry := TFDQuery.Create(nil);
  HTML := TStringBuilder.Create;
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text :=
      'SELECT N.NUMERO, N.DATA_EMISSAO, C.NOME, N.VALOR_TOTAL, N.SITUACAO ' +
      'FROM NOTAS_FISCAIS N JOIN CLIENTES C ON C.ID = N.ID_CLIENTE ' +
      'WHERE N.DATA_EMISSAO BETWEEN :ini AND :fim ORDER BY N.DATA_EMISSAO';
    Qry.ParamByName('ini').AsDate := DataIni;
    Qry.ParamByName('fim').AsDate := DataFim;
    Qry.Open;

    HTML.Append(CabecalhoHTML('Notas Fiscais - ' +
      FormatDateTime('dd/mm/yyyy', DataIni) + ' a ' + FormatDateTime('dd/mm/yyyy', DataFim)));
    HTML.Append('<table><tr><th>Número</th><th>Emissão</th><th>Cliente</th>' +
                '<th class="num">Valor</th><th>Situação</th></tr>');
    while not Qry.Eof do
    begin
      HTML.Append('<tr>');
      HTML.Append('<td>' + Qry.FieldByName('NUMERO').AsString + '</td>');
      HTML.Append('<td>' + FormatDateTime('dd/mm/yyyy', Qry.FieldByName('DATA_EMISSAO').AsDateTime) + '</td>');
      HTML.Append('<td>' + Qry.FieldByName('NOME').AsString + '</td>');
      HTML.Append('<td class="num">' + FormatFloat('#,##0.00', Qry.FieldByName('VALOR_TOTAL').AsFloat) + '</td>');
      HTML.Append('<td>' + Qry.FieldByName('SITUACAO').AsString + '</td>');
      HTML.Append('</tr>');
      Qry.Next;
    end;
    HTML.Append('</table>');
    HTML.Append(RodapeHTML);

    AbrirNoNavegador(HTML.ToString, 'rel_notas.html');
  finally
    HTML.Free;
    Qry.Free;
  end;
end;

procedure TServicoRelatorios.PosicaoEstoque;
var
  Qry: TFDQuery;
  HTML: TStringBuilder;
begin
  Qry := TFDQuery.Create(nil);
  HTML := TStringBuilder.Create;
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT DESCRICAO, UNIDADE, PRECO_VENDA, ESTOQUE FROM PRODUTOS ORDER BY DESCRICAO';
    Qry.Open;

    HTML.Append(CabecalhoHTML('Posição de Estoque'));
    HTML.Append('<table><tr><th>Produto</th><th>Un</th>' +
                '<th class="num">Preço</th><th class="num">Estoque</th></tr>');
    while not Qry.Eof do
    begin
      HTML.Append('<tr>');
      HTML.Append('<td>' + Qry.FieldByName('DESCRICAO').AsString + '</td>');
      HTML.Append('<td>' + Qry.FieldByName('UNIDADE').AsString + '</td>');
      HTML.Append('<td class="num">' + FormatFloat('#,##0.00', Qry.FieldByName('PRECO_VENDA').AsFloat) + '</td>');
      HTML.Append('<td class="num">' + FormatFloat('#,##0.000', Qry.FieldByName('ESTOQUE').AsFloat) + '</td>');
      HTML.Append('</tr>');
      Qry.Next;
    end;
    HTML.Append('</table>');
    HTML.Append(RodapeHTML);

    AbrirNoNavegador(HTML.ToString, 'rel_estoque.html');
  finally
    HTML.Free;
    Qry.Free;
  end;
end;

procedure TServicoRelatorios.VendasPDV(DataIni, DataFim: TDate);
var
  Qry: TFDQuery;
  HTML: TStringBuilder;
begin
  Qry := TFDQuery.Create(nil);
  HTML := TStringBuilder.Create;
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text :=
      'SELECT DATA_VENDA, VALOR_TOTAL, FORMA_PGTO, BANDEIRA, NSU ' +
      'FROM VENDAS_PDV WHERE CAST(DATA_VENDA AS DATE) BETWEEN :ini AND :fim ' +
      'ORDER BY DATA_VENDA';
    Qry.ParamByName('ini').AsDate := DataIni;
    Qry.ParamByName('fim').AsDate := DataFim;
    Qry.Open;

    HTML.Append(CabecalhoHTML('Vendas no PDV'));
    HTML.Append('<table><tr><th>Data/Hora</th><th class="num">Valor</th>' +
                '<th>Forma</th><th>Bandeira</th><th>NSU</th></tr>');
    while not Qry.Eof do
    begin
      HTML.Append('<tr>');
      HTML.Append('<td>' + FormatDateTime('dd/mm/yyyy hh:nn', Qry.FieldByName('DATA_VENDA').AsDateTime) + '</td>');
      HTML.Append('<td class="num">' + FormatFloat('#,##0.00', Qry.FieldByName('VALOR_TOTAL').AsFloat) + '</td>');
      HTML.Append('<td>' + Qry.FieldByName('FORMA_PGTO').AsString + '</td>');
      HTML.Append('<td>' + Qry.FieldByName('BANDEIRA').AsString + '</td>');
      HTML.Append('<td>' + Qry.FieldByName('NSU').AsString + '</td>');
      HTML.Append('</tr>');
      Qry.Next;
    end;
    HTML.Append('</table>');
    HTML.Append(RodapeHTML);

    AbrirNoNavegador(HTML.ToString, 'rel_vendas_pdv.html');
  finally
    HTML.Free;
    Qry.Free;
  end;
end;

end.
