unit uServicoNFe;

{ ===========================================================================
  SERVIÇO DE NF-e (integração com a SEFAZ).

  IMPORTANTE (leia isto): emitir NF-e de verdade é COMPLEXO. Envolve:
    1) Montar o XML da nota no layout oficial (leiaute 4.00 da NF-e).
    2) ASSINAR digitalmente o XML com um certificado A1/A3 (padrão ICP-Brasil).
    3) ENVIAR para o webservice SOAP da SEFAZ da sua UF (via HTTPS/SSL).
    4) Tratar o retorno (autorizado, rejeitado, denegado...).

  Na prática do mercado, quase ninguém faz isso "na mão": usa-se o projeto
  ACBr (gratuito) ou componentes pagos. Este arquivo é um ESQUELETO DIDÁTICO:
  mostra a estrutura e faz de verdade a parte que dá para fazer sem certificado
  (montar o XML e calcular a CHAVE DE ACESSO de 44 dígitos). As etapas de
  assinar e enviar estão SIMULADAS e marcadas com >>> AQUI ENTRARIA O REAL.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, System.DateUtils, System.Math,
  System.StrUtils,
  uConfig;

type
  { Resultado de qualquer operação com a SEFAZ. }
  TRetornoNFe = record
    Sucesso: Boolean;
    Codigo: string;        // cStat da SEFAZ (ex.: 100 = autorizado)
    Mensagem: string;      // xMotivo
    ChaveAcesso: string;   // 44 dígitos
    Protocolo: string;     // número do protocolo de autorização
    XML: string;           // XML gerado/retornado
  end;

  TServicoNFe = class
  private
    FConfig: TConfigSEFAZ;
    function ApenasNumeros(const S: string): string;
    function DigitoVerificadorChave(const Chave43: string): Char;
    function GerarChaveAcesso(const NumeroNota, Serie, Modelo: Integer;
      const CodigoNumerico: Integer): string;
    function MontarXML(NotaId: Integer; const ChaveAcesso: string): string;
    function AssinarXML(const XML: string): string;
    function EnviarSefaz(const XMLAssinado: string): TRetornoNFe;
  public
    constructor Create;
    // Verifica se o serviço da SEFAZ está no ar (status do serviço).
    function StatusServico: TRetornoNFe;
    // Emite (autoriza) a nota de ID informado.
    function EmitirNFe(NotaId: Integer): TRetornoNFe;
    // Consulta a situação de uma nota pela chave de acesso.
    function ConsultarNFe(const ChaveAcesso: string): TRetornoNFe;
    // Cancela uma nota já autorizada (exige justificativa >= 15 caracteres).
    function CancelarNFe(const ChaveAcesso, Justificativa: string): TRetornoNFe;
  end;

implementation

uses
  uDM, Data.DB, FireDAC.Comp.Client;

constructor TServicoNFe.Create;
begin
  inherited Create;
  FConfig := TConfig.SEFAZ;   // carrega as credenciais do config.ini
end;

function TServicoNFe.ApenasNumeros(const S: string): string;
var
  C: Char;
begin
  Result := '';
  for C in S do
    if CharInSet(C, ['0'..'9']) then
      Result := Result + C;
end;

{ Dígito verificador da chave de acesso: algoritmo "módulo 11".
  Percorre os 43 dígitos da direita para a esquerda multiplicando por pesos
  que vão de 2 a 9 e repetem. É o mesmo cálculo usado em boletos, CPF etc. }
function TServicoNFe.DigitoVerificadorChave(const Chave43: string): Char;
var
  i, Soma, Peso, Resto, DV: Integer;
begin
  Soma := 0;
  Peso := 2;
  for i := Length(Chave43) downto 1 do
  begin
    Soma := Soma + StrToInt(Chave43[i]) * Peso;
    Inc(Peso);
    if Peso > 9 then
      Peso := 2;
  end;
  Resto := Soma mod 11;
  if Resto in [0, 1] then
    DV := 0
  else
    DV := 11 - Resto;
  Result := Chr(Ord('0') + DV);
end;

{ Monta a chave de acesso de 44 dígitos, que é a "identidade" da nota:
  cUF(2) + AAMM(4) + CNPJ(14) + Modelo(2) + Serie(3) + Numero(9) +
  tpEmis(1) + Codigo(8) + DV(1).
  O código da UF (cUF) aqui está fixo em SP=35 para simplificar. }
function TServicoNFe.GerarChaveAcesso(const NumeroNota, Serie, Modelo,
  CodigoNumerico: Integer): string;
var
  Chave43: string;
  cUF, AAMM, CNPJ14: string;
begin
  cUF  := '35'; // 35 = São Paulo (numa versão real, mapear pela UF do config)
  AAMM := FormatDateTime('yymm', Now);

  // CNPJ com exatamente 14 dígitos (completa com zeros se vier vazio/curto)
  CNPJ14 := (ApenasNumeros(FConfig.CNPJ) + StringOfChar('0', 14)).Substring(0, 14);

  Chave43 :=
    cUF +
    AAMM +
    CNPJ14 +
    Format('%.2d', [Modelo]) +
    Format('%.3d', [Serie]) +
    Format('%.9d', [NumeroNota]) +
    '1' +                                   // tpEmis = 1 (emissão normal)
    Format('%.8d', [CodigoNumerico]);

  Result := Chave43 + DigitoVerificadorChave(Chave43);
end;

{ Monta um XML SIMPLIFICADO da nota, lendo os dados do banco.
  O leiaute REAL da NF-e tem centenas de campos; aqui mostramos só a ideia:
  cabeçalho (ide/emit/dest) + itens (det) + total. }
function TServicoNFe.MontarXML(NotaId: Integer; const ChaveAcesso: string): string;
var
  XML: TStringBuilder;
  Qry: TFDQuery;
begin
  XML := TStringBuilder.Create;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;

    // Cabeçalho da nota + cliente
    Qry.SQL.Text :=
      'SELECT N.NUMERO, N.DATA_EMISSAO, N.VALOR_TOTAL, ' +
      '       C.NOME, C.CPF_CNPJ, C.UF ' +
      'FROM NOTAS_FISCAIS N ' +
      'JOIN CLIENTES C ON C.ID = N.ID_CLIENTE ' +
      'WHERE N.ID = :id';
    Qry.ParamByName('id').AsInteger := NotaId;
    Qry.Open;

    XML.AppendLine('<?xml version="1.0" encoding="UTF-8"?>');
    XML.AppendLine('<NFe xmlns="http://www.portalfiscal.inf.br/nfe">');
    XML.AppendLine('  <infNFe Id="NFe' + ChaveAcesso + '" versao="4.00">');
    XML.AppendLine('    <ide>');
    XML.AppendLine('      <cUF>35</cUF>');
    XML.AppendLine('      <natOp>VENDA</natOp>');
    XML.AppendLine('      <mod>55</mod>');
    XML.AppendLine('      <nNF>' + Qry.FieldByName('NUMERO').AsString + '</nNF>');
    XML.AppendLine('      <dhEmi>' + FormatDateTime('yyyy-mm-dd', Qry.FieldByName('DATA_EMISSAO').AsDateTime) + '</dhEmi>');
    XML.AppendLine('      <tpAmb>' + IfThen(FConfig.EhProducao, '1', '2') + '</tpAmb>');
    XML.AppendLine('    </ide>');
    XML.AppendLine('    <emit>');
    XML.AppendLine('      <CNPJ>' + ApenasNumeros(FConfig.CNPJ) + '</CNPJ>');
    XML.AppendLine('      <xNome>' + FConfig.RazaoSocial + '</xNome>');
    XML.AppendLine('    </emit>');
    XML.AppendLine('    <dest>');
    XML.AppendLine('      <xNome>' + Qry.FieldByName('NOME').AsString + '</xNome>');
    XML.AppendLine('      <CNPJ>' + ApenasNumeros(Qry.FieldByName('CPF_CNPJ').AsString) + '</CNPJ>');
    XML.AppendLine('    </dest>');
    Qry.Close;

    // Itens da nota
    Qry.SQL.Text :=
      'SELECT I.QUANTIDADE, I.PRECO_UNIT, I.VALOR_TOTAL, P.DESCRICAO ' +
      'FROM ITENS_NOTA_FISCAL I ' +
      'JOIN PRODUTOS P ON P.ID = I.ID_PRODUTO ' +
      'WHERE I.ID_NOTA = :id';
    Qry.ParamByName('id').AsInteger := NotaId;
    Qry.Open;
    while not Qry.Eof do
    begin
      XML.AppendLine('    <det>');
      XML.AppendLine('      <prod>');
      XML.AppendLine('        <xProd>' + Qry.FieldByName('DESCRICAO').AsString + '</xProd>');
      XML.AppendLine('        <qCom>' + Qry.FieldByName('QUANTIDADE').AsString + '</qCom>');
      XML.AppendLine('        <vUnCom>' + Qry.FieldByName('PRECO_UNIT').AsString + '</vUnCom>');
      XML.AppendLine('        <vProd>' + Qry.FieldByName('VALOR_TOTAL').AsString + '</vProd>');
      XML.AppendLine('      </prod>');
      XML.AppendLine('    </det>');
      Qry.Next;
    end;
    Qry.Close;

    XML.AppendLine('  </infNFe>');
    XML.AppendLine('</NFe>');

    Result := XML.ToString;
  finally
    Qry.Free;
    XML.Free;
  end;
end;

{ >>> AQUI ENTRARIA O REAL: assinatura digital com o certificado A1/A3.
  Usa-se a biblioteca de assinatura (ACBr, Capicom, xmlsec...) para inserir
  o elemento <Signature> no XML. Sem certificado, apenas devolvemos o XML. }
function TServicoNFe.AssinarXML(const XML: string): string;
begin
  if FConfig.CaminhoCertificado = '' then
    Result := XML  // modo estudo: segue sem assinar
  else
    // Aqui você chamaria: Result := Assinador.Assinar(XML, Certificado, Senha);
    Result := XML;
end;

{ >>> AQUI ENTRARIA O REAL: envio SOAP para o webservice da SEFAZ.
  Como não temos webservice configurado, SIMULAMOS uma autorização. }
function TServicoNFe.EnviarSefaz(const XMLAssinado: string): TRetornoNFe;
begin
  if FConfig.UrlWebservice = '' then
  begin
    // ---- Simulação (ambiente de estudo) ----
    Result.Sucesso   := True;
    Result.Codigo    := '100';
    Result.Mensagem  := 'Autorizado o uso da NF-e (SIMULADO - sem valor fiscal)';
    Result.Protocolo := '135' + FormatDateTime('yymmddhhnnss', Now);
    Result.XML       := XMLAssinado;
  end
  else
  begin
    // ---- Real ----
    // Aqui você faria o POST SOAP para FConfig.UrlWebservice com o lote da NFe
    // e leria o cStat/xMotivo/protocolo do retorno.
    Result.Sucesso  := False;
    Result.Mensagem := 'Envio real ainda não implementado neste projeto de estudo.';
  end;
end;

function TServicoNFe.StatusServico: TRetornoNFe;
begin
  // Numa implementação real: chama o serviço nfeStatusServico da SEFAZ.
  if FConfig.UrlWebservice = '' then
  begin
    Result.Sucesso  := True;
    Result.Codigo   := '107';
    Result.Mensagem := 'Serviço em operação (SIMULADO). Ambiente: ' + FConfig.Ambiente;
  end
  else
  begin
    Result.Sucesso  := False;
    Result.Mensagem := 'Consulta real de status não implementada.';
  end;
end;

function TServicoNFe.EmitirNFe(NotaId: Integer): TRetornoNFe;
var
  Chave, XML, XMLAssinado: string;
  Numero, Codigo: Integer;
  Qry: TFDQuery;
begin
  // Descobre o número da nota para compor a chave
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT NUMERO FROM NOTAS_FISCAIS WHERE ID = :id';
    Qry.ParamByName('id').AsInteger := NotaId;
    Qry.Open;
    if Qry.IsEmpty then
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Nota ' + IntToStr(NotaId) + ' não encontrada.';
      Exit;
    end;
    Numero := Qry.FieldByName('NUMERO').AsInteger;
  finally
    Qry.Free;
  end;

  // Código numérico aleatório (cNF) - na prática é sorteado
  Codigo := RandomRange(10000000, 99999999);

  Chave       := GerarChaveAcesso(Numero, 1, 55, Codigo);
  XML         := MontarXML(NotaId, Chave);
  XMLAssinado := AssinarXML(XML);
  Result      := EnviarSefaz(XMLAssinado);
  Result.ChaveAcesso := Chave;

  // Se autorizou, grava o retorno fiscal na nota
  if Result.Sucesso then
  begin
    DM.Conn.ExecSQL(
      'UPDATE NOTAS_FISCAIS SET SITUACAO = ''E'', CHAVE_ACESSO = :chave, ' +
      'PROTOCOLO = :prot, XML_NFE = :xml WHERE ID = :id',
      [Chave, Result.Protocolo, Result.XML, NotaId]);
  end;
end;

function TServicoNFe.ConsultarNFe(const ChaveAcesso: string): TRetornoNFe;
begin
  // Real: serviço nfeConsultaProtocolo. Aqui consultamos o próprio banco.
  Result.Sucesso := True;
  Result.ChaveAcesso := ChaveAcesso;
  Result.Mensagem := 'Consulta simulada. Numa implementação real, aqui viria a ' +
                     'situação atual da nota direto da SEFAZ.';
end;

function TServicoNFe.CancelarNFe(const ChaveAcesso, Justificativa: string): TRetornoNFe;
begin
  if Length(Trim(Justificativa)) < 15 then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'A justificativa do cancelamento precisa de ao menos 15 caracteres.';
    Exit;
  end;

  // Real: evento de cancelamento (assinado e enviado à SEFAZ).
  DM.Conn.ExecSQL(
    'UPDATE NOTAS_FISCAIS SET SITUACAO = ''C'' WHERE CHAVE_ACESSO = :chave',
    [ChaveAcesso]);

  Result.Sucesso := True;
  Result.Codigo := '135';
  Result.Mensagem := 'Cancelamento registrado (SIMULADO).';
  Result.ChaveAcesso := ChaveAcesso;
end;

end.
