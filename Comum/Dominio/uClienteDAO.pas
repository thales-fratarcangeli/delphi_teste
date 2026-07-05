unit uClienteDAO;

{ ===========================================================================
  DAO = Data Access Object (Objeto de Acesso a Dados).
  É a camada que conversa com o banco e devolve/recebe OBJETOS (TCliente),
  escondendo o SQL das telas. Assim a tela não sabe (nem precisa saber) se os
  dados vêm de Firebird, de um arquivo ou de uma API - ela só chama o DAO.

  Esse é o padrão "Repository/DAO", muito comum em ERPs profissionais.
  Aqui usamos generics (TObjectList<TCliente>) para devolver uma lista de
  clientes já como objetos.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Generics.Collections,
  uEntidades;

type
  TClienteDAO = class
  private
    function LerAtual(Qry: TObject): TCliente;  // (helper interno, ver .pas)
  public
    // Devolve TODOS os clientes como uma lista de objetos.
    // Quem chamar fica responsável por dar Free na lista (ela é "dona" dos itens).
    function ListarTodos: TObjectList<TCliente>;
    // Busca um cliente pelo Id (ou nil se não achar).
    function BuscarPorId(AId: Integer): TCliente;
    // Insere um novo cliente (gera o Id pelo generator).
    procedure Inserir(Cliente: TCliente);
    // Atualiza um cliente existente.
    procedure Atualizar(Cliente: TCliente);
    // Exclui pelo Id.
    procedure Excluir(AId: Integer);
  end;

implementation

uses
  uDM, Data.DB, FireDAC.Comp.Client;

{ Converte a linha ATUAL de uma query num objeto TCliente.
  Recebe TObject só para não expor o tipo FireDAC na interface; fazemos o cast. }
function TClienteDAO.LerAtual(Qry: TObject): TCliente;
var
  Q: TFDQuery;
begin
  Q := TFDQuery(Qry);
  Result := TCliente.Create;
  Result.Id       := Q.FieldByName('ID').AsInteger;
  Result.Nome     := Q.FieldByName('NOME').AsString;
  Result.CpfCnpj  := Q.FieldByName('CPF_CNPJ').AsString;
  Result.Cidade   := Q.FieldByName('CIDADE').AsString;
  Result.Uf       := Q.FieldByName('UF').AsString;
  Result.Telefone := Q.FieldByName('TELEFONE').AsString;
  Result.Email    := Q.FieldByName('EMAIL').AsString;
end;

function TClienteDAO.ListarTodos: TObjectList<TCliente>;
var
  Qry: TFDQuery;
begin
  // True = a lista é DONA dos objetos e vai liberá-los quando for destruída.
  Result := TObjectList<TCliente>.Create(True);
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT * FROM CLIENTES ORDER BY NOME';
    Qry.Open;
    while not Qry.Eof do
    begin
      Result.Add(LerAtual(Qry));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

function TClienteDAO.BuscarPorId(AId: Integer): TCliente;
var
  Qry: TFDQuery;
begin
  Result := nil;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT * FROM CLIENTES WHERE ID = :id';
    Qry.ParamByName('id').AsInteger := AId;
    Qry.Open;
    if not Qry.IsEmpty then
      Result := LerAtual(Qry);
  finally
    Qry.Free;
  end;
end;

procedure TClienteDAO.Inserir(Cliente: TCliente);
var
  Erro: string;
begin
  // A validação mora na ENTIDADE (regra de negócio no lugar certo)
  if not Cliente.Validar(Erro) then
    raise Exception.Create(Erro);

  Cliente.Id := DM.ProximoId('GEN_CLIENTES');
  DM.Conn.ExecSQL(
    'INSERT INTO CLIENTES (ID, NOME, CPF_CNPJ, CIDADE, UF, TELEFONE, EMAIL) ' +
    'VALUES (:id, :nome, :cpf, :cidade, :uf, :tel, :email)',
    [Cliente.Id, Cliente.Nome, Cliente.CpfCnpj, Cliente.Cidade,
     Cliente.Uf, Cliente.Telefone, Cliente.Email]);
end;

procedure TClienteDAO.Atualizar(Cliente: TCliente);
var
  Erro: string;
begin
  if not Cliente.Validar(Erro) then
    raise Exception.Create(Erro);

  DM.Conn.ExecSQL(
    'UPDATE CLIENTES SET NOME = :nome, CPF_CNPJ = :cpf, CIDADE = :cidade, ' +
    'UF = :uf, TELEFONE = :tel, EMAIL = :email WHERE ID = :id',
    [Cliente.Nome, Cliente.CpfCnpj, Cliente.Cidade, Cliente.Uf,
     Cliente.Telefone, Cliente.Email, Cliente.Id]);
end;

procedure TClienteDAO.Excluir(AId: Integer);
begin
  DM.Conn.ExecSQL('DELETE FROM CLIENTES WHERE ID = :id', [AId]);
end;

end.
