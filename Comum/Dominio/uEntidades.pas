unit uEntidades;

{ ===========================================================================
  CAMADA DE DOMÍNIO - Entidades (as "coisas" do negócio como CLASSES).

  Até agora o ERP leu o banco direto nas telas (com TFDQuery). Isso funciona,
  mas em sistemas maiores é comum ter uma CAMADA DE DOMÍNIO: cada tabela vira
  uma classe (TCliente, TProduto...), e as telas trabalham com OBJETOS em vez
  de campos soltos. Vantagens: código mais organizado, regras de validação no
  lugar certo, e fácil de testar.

  Aqui mostramos herança de verdade:
    TEntidadeBase (abstrata)  ->  TCliente
                              ->  TProduto
  =========================================================================== }

interface

uses
  System.SysUtils;

type
  { Classe BASE ABSTRATA: define o que TODA entidade tem (um Id) e o que toda
    entidade DEVE saber fazer (validar-se e se descrever). Não pode ser criada
    diretamente - só serve para as filhas herdarem. }
  TEntidadeBase = class abstract
  private
    FId: Integer;
  public
    property Id: Integer read FId write FId;
    // Métodos ABSTRATOS: cada filha é OBRIGADA a implementar.
    function Validar(out Erro: string): Boolean; virtual; abstract;
    function Descricao: string; virtual; abstract;
  end;

  { CLIENTE - herda de TEntidadeBase e adiciona seus próprios campos. }
  TCliente = class(TEntidadeBase)
  private
    FNome: string;
    FCpfCnpj: string;
    FCidade: string;
    FUf: string;
    FTelefone: string;
    FEmail: string;
  public
    property Nome: string read FNome write FNome;
    property CpfCnpj: string read FCpfCnpj write FCpfCnpj;
    property Cidade: string read FCidade write FCidade;
    property Uf: string read FUf write FUf;
    property Telefone: string read FTelefone write FTelefone;
    property Email: string read FEmail write FEmail;
    // "override" = estou trocando a implementação que veio da base
    function Validar(out Erro: string): Boolean; override;
    function Descricao: string; override;
  end;

  { PRODUTO - outra filha de TEntidadeBase. }
  TProduto = class(TEntidadeBase)
  private
    FDescricaoProd: string;
    FUnidade: string;
    FPrecoVenda: Currency;
    FEstoque: Double;
  public
    property DescricaoProd: string read FDescricaoProd write FDescricaoProd;
    property Unidade: string read FUnidade write FUnidade;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
    property Estoque: Double read FEstoque write FEstoque;
    function Validar(out Erro: string): Boolean; override;
    function Descricao: string; override;
  end;

implementation

{ TCliente }

function TCliente.Validar(out Erro: string): Boolean;
begin
  Erro := '';
  if Trim(FNome) = '' then
    Erro := 'Nome do cliente é obrigatório.'
  else if (FUf <> '') and (Length(FUf) <> 2) then
    Erro := 'UF deve ter 2 letras.';
  Result := Erro = '';   // válido quando não há mensagem de erro
end;

function TCliente.Descricao: string;
begin
  Result := Format('%d - %s (%s/%s)', [Id, FNome, FCidade, FUf]);
end;

{ TProduto }

function TProduto.Validar(out Erro: string): Boolean;
begin
  Erro := '';
  if Trim(FDescricaoProd) = '' then
    Erro := 'Descrição do produto é obrigatória.'
  else if FPrecoVenda < 0 then
    Erro := 'Preço não pode ser negativo.';
  Result := Erro = '';
end;

function TProduto.Descricao: string;
begin
  Result := Format('%d - %s (%s) R$ %.2f', [Id, FDescricaoProd, FUnidade, FPrecoVenda]);
end;

end.
