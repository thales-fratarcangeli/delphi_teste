unit uFrmFiscal;

{ ===========================================================================
  Painel FISCAL.
  Lista as notas fiscais e permite: emitir na SEFAZ, consultar, cancelar e
  enviar o XML por e-mail. Aqui as TELAS conversam com os SERVIÇOS
  (uServicoNFe, uServicoEmail). Repare como a tela fica "magra": ela só
  coordena; a regra pesada está nos serviços.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Dialogs,
  Data.DB, FireDAC.Comp.Client,
  uServicoNFe, uServicoEmail;

type
  TFrmFiscal = class(TForm)
    pnlTopo: TPanel;
    btnEmitir: TButton;
    btnConsultar: TButton;
    btnCancelar: TButton;
    btnEnviarEmail: TButton;
    btnAtualizar: TButton;
    Grid: TDBGrid;
    qryNotas: TFDQuery;
    dsNotas: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnEmitirClick(Sender: TObject);
    procedure btnConsultarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnEnviarEmailClick(Sender: TObject);
  private
    procedure Carregar;
    function NotaSelecionada(out Id: Integer; out Chave: string): Boolean;
  end;

var
  FrmFiscal: TFrmFiscal;

implementation

{$R *.dfm}

uses
  uDM;

procedure TFrmFiscal.FormCreate(Sender: TObject);
begin
  qryNotas.Connection := DM.Conn;
  Carregar;
end;

procedure TFrmFiscal.Carregar;
begin
  qryNotas.Close;
  qryNotas.SQL.Text :=
    'SELECT N.ID, N.NUMERO, N.DATA_EMISSAO, C.NOME AS CLIENTE, ' +
    '       N.VALOR_TOTAL, N.SITUACAO, N.CHAVE_ACESSO ' +
    'FROM NOTAS_FISCAIS N JOIN CLIENTES C ON C.ID = N.ID_CLIENTE ' +
    'ORDER BY N.ID DESC';
  qryNotas.Open;
end;

procedure TFrmFiscal.btnAtualizarClick(Sender: TObject);
begin
  Carregar;
end;

{ Pega o ID e a chave da nota selecionada na grade. }
function TFrmFiscal.NotaSelecionada(out Id: Integer; out Chave: string): Boolean;
begin
  Result := not qryNotas.IsEmpty;
  if Result then
  begin
    Id := qryNotas.FieldByName('ID').AsInteger;
    Chave := qryNotas.FieldByName('CHAVE_ACESSO').AsString;
  end
  else
    ShowMessage('Selecione uma nota na lista.');
end;

procedure TFrmFiscal.btnEmitirClick(Sender: TObject);
var
  Servico: TServicoNFe;
  Ret: TRetornoNFe;
  Id: Integer;
  Chave: string;
begin
  if not NotaSelecionada(Id, Chave) then Exit;

  if qryNotas.FieldByName('SITUACAO').AsString = 'E' then
  begin
    ShowMessage('Esta nota já foi emitida.');
    Exit;
  end;

  Servico := TServicoNFe.Create;
  try
    Ret := Servico.EmitirNFe(Id);
    if Ret.Sucesso then
      ShowMessage('NF-e autorizada!' + sLineBreak +
                  'Chave: ' + Ret.ChaveAcesso + sLineBreak +
                  'Protocolo: ' + Ret.Protocolo)
    else
      ShowMessage('Falha na emissão: ' + Ret.Mensagem);
  finally
    Servico.Free;
  end;
  Carregar;
end;

procedure TFrmFiscal.btnConsultarClick(Sender: TObject);
var
  Servico: TServicoNFe;
  Ret: TRetornoNFe;
  Id: Integer;
  Chave: string;
begin
  if not NotaSelecionada(Id, Chave) then Exit;
  if Chave = '' then
  begin
    ShowMessage('Esta nota ainda não foi emitida (sem chave de acesso).');
    Exit;
  end;

  Servico := TServicoNFe.Create;
  try
    Ret := Servico.ConsultarNFe(Chave);
    ShowMessage(Ret.Mensagem);
  finally
    Servico.Free;
  end;
end;

procedure TFrmFiscal.btnCancelarClick(Sender: TObject);
var
  Servico: TServicoNFe;
  Ret: TRetornoNFe;
  Id: Integer;
  Chave, Justificativa: string;
begin
  if not NotaSelecionada(Id, Chave) then Exit;
  if Chave = '' then
  begin
    ShowMessage('Só é possível cancelar uma nota já emitida.');
    Exit;
  end;

  Justificativa := '';
  if not InputQuery('Cancelamento de NF-e',
       'Justificativa (mínimo 15 caracteres):', Justificativa) then
    Exit;

  Servico := TServicoNFe.Create;
  try
    Ret := Servico.CancelarNFe(Chave, Justificativa);
    ShowMessage(Ret.Mensagem);
  finally
    Servico.Free;
  end;
  Carregar;
end;

procedure TFrmFiscal.btnEnviarEmailClick(Sender: TObject);
var
  ServicoEmail: TServicoEmail;
  Id: Integer;
  Chave, Destinatario, CaminhoXML, Erro: string;
  Lista: TStringList;
begin
  if not NotaSelecionada(Id, Chave) then Exit;
  if Chave = '' then
  begin
    ShowMessage('Emita a nota antes de enviar o XML.');
    Exit;
  end;

  Destinatario := '';
  if not InputQuery('Enviar XML por e-mail', 'E-mail do destinatário:', Destinatario) then
    Exit;

  // Grava o XML da nota (guardado no banco) num arquivo temporário para anexar
  CaminhoXML := IncludeTrailingPathDelimiter(GetEnvironmentVariable('TEMP')) +
                'NFe_' + Chave + '.xml';
  Lista := TStringList.Create;
  try
    Lista.Text := qryNotas.Connection.ExecSQLScalar(
      'SELECT XML_NFE FROM NOTAS_FISCAIS WHERE ID = ' + Id.ToString);
    Lista.SaveToFile(CaminhoXML, TEncoding.UTF8);
  finally
    Lista.Free;
  end;

  ServicoEmail := TServicoEmail.Create;
  try
    if ServicoEmail.Enviar(Destinatario, 'NF-e ' + Chave,
         'Segue em anexo o XML da sua nota fiscal.', CaminhoXML, Erro) then
      ShowMessage('E-mail enviado para ' + Destinatario)
    else
      ShowMessage('Não foi possível enviar: ' + Erro);
  finally
    ServicoEmail.Free;
  end;
end;

procedure TFrmFiscal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
