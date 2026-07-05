unit uFrmPermissoes;

{ ===========================================================================
  Tela de PRIVILÉGIOS (árvore de permissões por perfil).
  Escolhe um perfil e marca/desmarca as permissões que ele terá. A "árvore"
  vem da tabela PERMISSOES (cada chave sabe seu pai). Aqui mostramos ela numa
  lista com marcação (TCheckListBox), indentada por nível — o nível é dado pela
  quantidade de pontos na chave (ex.: 'FAT.MOV.NF' = nível 2).

  Ao salvar, apagamos as permissões atuais do perfil e regravamos as marcadas.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.StrUtils,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.CheckLst, Vcl.Dialogs,
  Data.DB, FireDAC.Comp.Client;

type
  TFrmPermissoes = class(TForm)
    pnlTopo: TPanel;
    lblPerfil: TLabel;
    cboPerfil: TComboBox;
    btnSalvar: TButton;
    clbPermissoes: TCheckListBox;
    qryAux: TFDQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cboPerfilChange(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
  private
    FChaves: TStringList;   // chave de cada linha (alinhada por índice)
    procedure CarregarPerfis;
    procedure MontarArvore;
    procedure MarcarDoPerfil(IdPerfil: Integer);
    function IdPerfilSelecionado: Integer;
  end;

var
  FrmPermissoes: TFrmPermissoes;

implementation

{$R *.dfm}

uses
  uDM, uLog, uSessao;

procedure TFrmPermissoes.FormCreate(Sender: TObject);
begin
  FChaves := TStringList.Create;
  qryAux.Connection := DM.Conn;
  CarregarPerfis;
  MontarArvore;
  if cboPerfil.Items.Count > 0 then
  begin
    cboPerfil.ItemIndex := 0;
    cboPerfilChange(nil);
  end;
end;

procedure TFrmPermissoes.CarregarPerfis;
begin
  cboPerfil.Clear;
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT ID, NOME FROM PERFIS ORDER BY NOME';
  qryAux.Open;
  while not qryAux.Eof do
  begin
    cboPerfil.Items.AddObject(qryAux.FieldByName('NOME').AsString,
                              TObject(qryAux.FieldByName('ID').AsInteger));
    qryAux.Next;
  end;
end;

{ Monta a lista de permissões (uma vez). Indentação = nível na árvore. }
procedure TFrmPermissoes.MontarArvore;
var
  Chave, Descricao, Texto: string;
  Nivel: Integer;
begin
  clbPermissoes.Items.BeginUpdate;
  try
    clbPermissoes.Clear;
    FChaves.Clear;
    qryAux.Close;
    // Ordenar por CHAVE agrupa pais e filhos (compartilham o prefixo)
    qryAux.SQL.Text := 'SELECT CHAVE, DESCRICAO FROM PERMISSOES ORDER BY CHAVE';
    qryAux.Open;
    while not qryAux.Eof do
    begin
      Chave := qryAux.FieldByName('CHAVE').AsString;
      Descricao := qryAux.FieldByName('DESCRICAO').AsString;
      // Nível = quantos pontos existem na chave
      Nivel := 0;
      for var i := 1 to Length(Chave) do
        if Chave[i] = '.' then Inc(Nivel);
      // Indenta o texto conforme o nível
      Texto := DupeString('      ', Nivel) + Descricao + '   (' + Chave + ')';

      clbPermissoes.Items.Add(Texto);
      FChaves.Add(Chave);   // guarda a chave "crua" nesta mesma posição
      qryAux.Next;
    end;
  finally
    clbPermissoes.Items.EndUpdate;
  end;
end;

function TFrmPermissoes.IdPerfilSelecionado: Integer;
begin
  if cboPerfil.ItemIndex < 0 then
    Result := 0
  else
    Result := Integer(cboPerfil.Items.Objects[cboPerfil.ItemIndex]);
end;

{ Marca na lista as permissões que o perfil selecionado já possui. }
procedure TFrmPermissoes.MarcarDoPerfil(IdPerfil: Integer);
var
  i, Idx: Integer;
begin
  // Desmarca tudo
  for i := 0 to clbPermissoes.Items.Count - 1 do
    clbPermissoes.Checked[i] := False;

  qryAux.Close;
  qryAux.SQL.Text := 'SELECT CHAVE_PERMISSAO FROM PERFIL_PERMISSAO WHERE ID_PERFIL = :p';
  qryAux.ParamByName('p').AsInteger := IdPerfil;
  qryAux.Open;
  while not qryAux.Eof do
  begin
    Idx := FChaves.IndexOf(qryAux.FieldByName('CHAVE_PERMISSAO').AsString);
    if Idx >= 0 then
      clbPermissoes.Checked[Idx] := True;
    qryAux.Next;
  end;
end;

procedure TFrmPermissoes.cboPerfilChange(Sender: TObject);
begin
  MarcarDoPerfil(IdPerfilSelecionado);
end;

procedure TFrmPermissoes.btnSalvarClick(Sender: TObject);
var
  IdPerfil, i: Integer;
begin
  IdPerfil := IdPerfilSelecionado;
  if IdPerfil = 0 then Exit;

  DM.Conn.StartTransaction;
  try
    // Estratégia simples: apaga tudo do perfil e regrava as marcadas
    DM.Conn.ExecSQL('DELETE FROM PERFIL_PERMISSAO WHERE ID_PERFIL = :p', [IdPerfil]);
    for i := 0 to clbPermissoes.Items.Count - 1 do
      if clbPermissoes.Checked[i] then
        DM.Conn.ExecSQL(
          'INSERT INTO PERFIL_PERMISSAO (ID_PERFIL, CHAVE_PERMISSAO) VALUES (:p, :c)',
          [IdPerfil, FChaves[i]]);
    DM.Conn.Commit;

    TLog.Registrar(ClassName,
      Format('Permissões do perfil %d alteradas por %s.', [IdPerfil, UsuarioLogado.Login]));
    ShowMessage('Permissões salvas.');
  except
    on E: Exception do
    begin
      DM.Conn.Rollback;
      ShowMessage('Erro ao salvar: ' + E.Message);
    end;
  end;
end;

procedure TFrmPermissoes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FChaves.Free;
  Action := caFree;
end;

end.
