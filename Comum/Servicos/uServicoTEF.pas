unit uServicoTEF;

{ ===========================================================================
  SERVIÇO DE TEF (Transferência Eletrônica de Fundos) = máquina de cartão.

  No mundo real, a maquininha/TEF é integrada por um SDK do provedor
  (PayGo, SiTef, Stone, Cielo, PagSeguro...). Cada um tem sua própria API/DLL.
  Por isso, o ideal é programar contra uma INTERFACE (um "contrato") e ter uma
  implementação por provedor. Se amanhã trocar de maquininha, troca só a
  implementação, não o resto do sistema. Isso é o padrão "Strategy".

  Aqui definimos a interface ITEF e uma implementação SIMULADA para estudo.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, uConfig;

type
  TFormaPagamentoCartao = (fpDebito, fpCredito, fpPix);

  { Resultado de uma transação na maquininha. }
  TResultadoTEF = record
    Aprovado: Boolean;
    NSU: string;          // número sequencial único da transação
    Autorizacao: string;  // código de autorização da operadora
    Bandeira: string;     // VISA, MASTERCARD, ELO...
    Mensagem: string;
  end;

  { O "contrato" que qualquer provedor de maquininha deve cumprir. }
  ITEF = interface
    ['{2B0F4A10-9C3E-4E7A-8B2C-1D6F3A9E0C51}']
    function Pagar(Valor: Currency; Forma: TFormaPagamentoCartao;
      Parcelas: Integer): TResultadoTEF;
    function Cancelar(const NSU: string): TResultadoTEF;
  end;

  { Implementação SIMULADA (não fala com maquininha nenhuma). }
  TTEFSimulado = class(TInterfacedObject, ITEF)
  private
    FConfig: TConfigTEF;
  public
    constructor Create;
    function Pagar(Valor: Currency; Forma: TFormaPagamentoCartao;
      Parcelas: Integer): TResultadoTEF;
    function Cancelar(const NSU: string): TResultadoTEF;
  end;

  { "Fábrica": devolve a implementação certa conforme o provedor do config.ini.
    Hoje só temos a simulada; quando integrar de verdade, é aqui que você
    decidiria retornar TTEFPayGo, TTEFSiTef, etc. }
  function CriarTEF: ITEF;

implementation

function CriarTEF: ITEF;
var
  Cfg: TConfigTEF;
begin
  Cfg := TConfig.TEF;
  // if SameText(Cfg.Provedor, 'PAYGO') then Exit(TTEFPayGo.Create);
  // if SameText(Cfg.Provedor, 'SITEF') then Exit(TTEFSiTef.Create);
  Result := TTEFSimulado.Create;  // padrão / estudo
end;

{ TTEFSimulado }

constructor TTEFSimulado.Create;
begin
  inherited Create;
  FConfig := TConfig.TEF;
end;

function TTEFSimulado.Pagar(Valor: Currency; Forma: TFormaPagamentoCartao;
  Parcelas: Integer): TResultadoTEF;
begin
  // Numa maquininha real, aqui o SDK abriria a tela para o cliente passar o
  // cartão / aproximar / digitar senha, e devolveria o resultado.
  Result.Aprovado    := Valor > 0;
  Result.NSU         := FormatDateTime('yymmddhhnnsszzz', Now);
  Result.Autorizacao := IntToStr(Random(900000) + 100000);
  Result.Bandeira    := 'VISA';
  if Result.Aprovado then
    Result.Mensagem := 'Pagamento aprovado (SIMULADO)'
  else
    Result.Mensagem := 'Valor inválido';
end;

function TTEFSimulado.Cancelar(const NSU: string): TResultadoTEF;
begin
  Result.Aprovado := True;
  Result.NSU := NSU;
  Result.Mensagem := 'Transação cancelada (SIMULADO)';
end;

end.
