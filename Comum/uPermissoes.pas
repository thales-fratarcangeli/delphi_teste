unit uPermissoes;

{ ===========================================================================
  PERMISSÕES / PRIVILÉGIOS.
  Depois do login, carregamos TODAS as permissões (chaves) do perfil daquele
  usuário para uma lista em memória. Aí, em qualquer lugar do sistema, dá para
  perguntar: "esse usuário pode fazer X?" com TPermissoes.Pode('FAT.MOV.NF').

  As telas usam isso para habilitar/desabilitar menus e botões conforme o
  perfil (Administrador vê tudo; Vendedor vê só o que tem direito, etc.).
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes;

type
  TPermissoes = class
  private
    class var FChaves: TStringList;   // guarda as permissões do usuário logado
  public
    class constructor Create;
    class destructor Destroy;
    // Carrega as permissões do perfil informado (chame logo após o login).
    class procedure Carregar(IdPerfil: Integer);
    // Retorna True se o usuário tem a permissão daquela chave.
    class function Pode(const Chave: string): Boolean;
  end;

implementation

uses
  uDM, Data.DB, FireDAC.Comp.Client;

class constructor TPermissoes.Create;
begin
  FChaves := TStringList.Create;
  FChaves.Sorted := True;               // ordenado = busca rápida
  FChaves.Duplicates := dupIgnore;
end;

class destructor TPermissoes.Destroy;
begin
  FChaves.Free;
end;

class procedure TPermissoes.Carregar(IdPerfil: Integer);
var
  Qry: TFDQuery;
begin
  FChaves.Clear;
  if IdPerfil <= 0 then
    Exit;   // usuário sem perfil = sem permissões

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT CHAVE_PERMISSAO FROM PERFIL_PERMISSAO WHERE ID_PERFIL = :p';
    Qry.ParamByName('p').AsInteger := IdPerfil;
    Qry.Open;
    while not Qry.Eof do
    begin
      FChaves.Add(Qry.FieldByName('CHAVE_PERMISSAO').AsString);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

class function TPermissoes.Pode(const Chave: string): Boolean;
begin
  // IndexOf >= 0 significa que a chave está na lista de permissões do usuário
  Result := FChaves.IndexOf(Chave) >= 0;
end;

end.
