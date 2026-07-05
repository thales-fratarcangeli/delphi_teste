unit uExemplosLinguagem;

{ ===========================================================================
  ARQUIVO DE REFERÊNCIA - RECURSOS DA LINGUAGEM OBJECT PASCAL (Delphi).

  Este arquivo NÃO faz parte da regra de negócio do ERP. Ele existe só para
  você ESTUDAR os principais recursos da linguagem num lugar só, com exemplos
  curtos e comentados. Cada função demonstra um conceito e devolve um texto
  explicando o que aconteceu (dá para chamar tudo de uma vez com Demonstrar).

  Conceitos cobertos:
    1) Tipos enumerados e conjuntos (enum / set)
    2) Registros (record) com métodos
    3) Classes: herança, métodos virtuais/abstratos, polimorfismo, propriedades
    4) Interfaces
    5) Generics (listas e dicionários tipados)
    6) Métodos anônimos (anonymous methods)
    7) Laço for-in e tratamento de exceções
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

// Chame esta função para rodar TODAS as demonstrações e receber um relatório.
function Demonstrar: string;

implementation

{ ---------------------------------------------------------------------------
  1) TIPOS ENUMERADOS E CONJUNTOS
  Um "enum" é um tipo com uma lista fixa de valores nomeados. Um "set" é um
  conjunto desses valores (dá para ter vários ao mesmo tempo).
  --------------------------------------------------------------------------- }
type
  TDiaSemana = (dsSeg, dsTer, dsQua, dsQui, dsSex, dsSab, dsDom);
  TDiasSet = set of TDiaSemana;

function ExemploEnumSet: string;
var
  FimDeSemana: TDiasSet;
  Dia: TDiaSemana;
begin
  FimDeSemana := [dsSab, dsDom];   // conjunto com 2 valores
  Result := 'Enum/Set -> dias de folga: ';
  // "for ... in" percorre todos os valores possíveis do enum
  for Dia := Low(TDiaSemana) to High(TDiaSemana) do
    if Dia in FimDeSemana then                 // "in" testa se está no conjunto
      Result := Result + IntToStr(Ord(Dia)) + ' ';
end;

{ ---------------------------------------------------------------------------
  2) RECORD COM MÉTODOS
  Um record agrupa dados e (em Delphi moderno) pode ter métodos e propriedades.
  Diferente de classe: record é copiado por VALOR e não precisa de Free.
  --------------------------------------------------------------------------- }
type
  TDinheiro = record
    Valor: Currency;
    function Formatado: string;                // método dentro do record
    class function Criar(AValor: Currency): TDinheiro; static;  // "construtor"
  end;

function TDinheiro.Formatado: string;
begin
  Result := FormatFloat('R$ #,##0.00', Valor);
end;

class function TDinheiro.Criar(AValor: Currency): TDinheiro;
begin
  Result.Valor := AValor;
end;

function ExemploRecord: string;
var
  D: TDinheiro;
begin
  D := TDinheiro.Criar(1234.5);
  Result := 'Record com método -> ' + D.Formatado;
end;

{ ---------------------------------------------------------------------------
  3) CLASSES: HERANÇA, VIRTUAL/ABSTRACT, POLIMORFISMO, PROPRIEDADES
  - Classe base ABSTRATA: não pode ser instanciada; define o "contrato".
  - Método VIRTUAL: pode ser trocado (override) na classe filha.
  - POLIMORFISMO: chamar o mesmo método em objetos diferentes, cada um responde
    do seu jeito.
  --------------------------------------------------------------------------- }
type
  TAnimal = class abstract
  private
    FNome: string;
  public
    constructor Create(const ANome: string);
    property Nome: string read FNome write FNome;   // propriedade
    function Som: string; virtual; abstract;         // cada filho implementa
  end;

  TCachorro = class(TAnimal)
  public
    function Som: string; override;
  end;

  TGato = class(TAnimal)
  public
    function Som: string; override;
  end;

constructor TAnimal.Create(const ANome: string);
begin
  inherited Create;
  FNome := ANome;
end;

function TCachorro.Som: string;
begin
  Result := 'au au';
end;

function TGato.Som: string;
begin
  Result := 'miau';
end;

function ExemploPolimorfismo: string;
var
  Animais: TObjectList<TAnimal>;   // lista genérica que DONA dos objetos
  A: TAnimal;
begin
  Animais := TObjectList<TAnimal>.Create(True);  // True = libera os itens no fim
  try
    Animais.Add(TCachorro.Create('Rex'));
    Animais.Add(TGato.Create('Mia'));
    Result := 'Polimorfismo -> ';
    // Mesmo código, respostas diferentes: isso é polimorfismo
    for A in Animais do
      Result := Result + A.Nome + ' faz ' + A.Som + '; ';
  finally
    Animais.Free;   // como a lista é "dona", ela libera Rex e Mia sozinha
  end;
end;

{ ---------------------------------------------------------------------------
  4) INTERFACES
  Uma interface é um "contrato" (só a lista de métodos). Quem implementa
  promete ter esses métodos. Objetos com interface têm contagem de referência
  e se auto-liberam (não precisa Free).
  --------------------------------------------------------------------------- }
type
  ISaudacao = interface
    ['{7B3D2A1C-1111-2222-3333-444455556666}']
    function Ola(const Nome: string): string;
  end;

  TSaudacaoBR = class(TInterfacedObject, ISaudacao)
    function Ola(const Nome: string): string;
  end;

function TSaudacaoBR.Ola(const Nome: string): string;
begin
  Result := 'Olá, ' + Nome + '!';
end;

function ExemploInterface: string;
var
  S: ISaudacao;
begin
  S := TSaudacaoBR.Create;   // sem try/finally: interface se libera sozinha
  Result := 'Interface -> ' + S.Ola('Thales');
end;

{ ---------------------------------------------------------------------------
  5) GENERICS (coleções tipadas)
  Generics deixam você reusar a mesma estrutura com QUALQUER tipo, com
  segurança de tipo. TList<Integer>, TDictionary<string,Integer> etc.
  --------------------------------------------------------------------------- }
function ExemploGenerics: string;
var
  Numeros: TList<Integer>;
  Estoque: TDictionary<string, Integer>;
  N, Soma: Integer;
begin
  Numeros := TList<Integer>.Create;
  Estoque := TDictionary<string, Integer>.Create;
  try
    Numeros.AddRange([10, 20, 30]);
    Soma := 0;
    for N in Numeros do
      Soma := Soma + N;

    // Dicionário = pares chave->valor (como uma tabela de consulta rápida)
    Estoque.Add('Caneta', 100);
    Estoque.Add('Caderno', 50);

    Result := Format('Generics -> soma da lista = %d; estoque de Caneta = %d',
      [Soma, Estoque['Caneta']]);
  finally
    Numeros.Free;
    Estoque.Free;
  end;
end;

{ ---------------------------------------------------------------------------
  6) MÉTODOS ANÔNIMOS
  É uma função "sem nome" que você passa como se fosse um valor. Muito usado
  em threads, callbacks e ordenações. TFunc<T, TResult> e TProc são os tipos.
  --------------------------------------------------------------------------- }
function ExemploAnonimo: string;
var
  Dobro: TFunc<Integer, Integer>;   // função que recebe Integer e devolve Integer
begin
  // A função inteira cabe dentro de uma variável:
  Dobro := function(X: Integer): Integer
    begin
      Result := X * 2;
    end;
  Result := 'Método anônimo -> dobro de 21 = ' + IntToStr(Dobro(21));
end;

{ ---------------------------------------------------------------------------
  7) EXCEÇÕES (try/except) e for-in em string
  --------------------------------------------------------------------------- }
function ExemploExcecao: string;
var
  Texto: string;
  C: Char;
  Vogais: Integer;
begin
  // try/except captura erros em tempo de execução sem derrubar o programa
  try
    StrToInt('abc');   // isso lança uma exceção (não é número)
  except
    on E: EConvertError do
      Result := 'Exceção capturada: ' + E.Message + '. ';
  end;

  // for-in percorrendo os caracteres de uma string
  Texto := 'Delphi';
  Vogais := 0;
  for C in Texto do
    if CharInSet(UpCase(C), ['A', 'E', 'I', 'O', 'U']) then
      Inc(Vogais);
  Result := Result + Format('A palavra "%s" tem %d vogais.', [Texto, Vogais]);
end;

{ Roda todas as demonstrações e junta num relatório. }
function Demonstrar: string;
var
  L: TStringList;
begin
  L := TStringList.Create;
  try
    L.Add(ExemploEnumSet);
    L.Add(ExemploRecord);
    L.Add(ExemploPolimorfismo);
    L.Add(ExemploInterface);
    L.Add(ExemploGenerics);
    L.Add(ExemploAnonimo);
    L.Add(ExemploExcecao);
    Result := L.Text;
  finally
    L.Free;
  end;
end;

end.
