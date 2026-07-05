unit uServicoIA;

{ ===========================================================================
  SERVIÇO DE IA (o cérebro por trás da "bolinha" do canto da tela).

  Faz uma chamada HTTP para uma API de IA (LLM). O endpoint, o modelo e a
  chave (ApiKey) vêm do config.ini, na seção [IA]. Por padrão está apontando
  para a API da Anthropic (Claude), no formato /v1/messages.

  Conceitos que aparecem aqui:
   - THTTPClient / TNetHTTPClient: cliente HTTP nativo do Delphi.
   - System.JSON: montar e ler JSON.
   - Chamada a serviço externo com tratamento de erro.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Net.HttpClient,
  System.Net.URLClient, System.NetEncoding,
  uConfig;

type
  TServicoIA = class
  private
    FConfig: TConfigIA;
  public
    constructor Create;
    { Envia uma pergunta e devolve a resposta em texto.
      Em caso de erro, o próprio texto de retorno explica o problema. }
    function Perguntar(const Pergunta: string): string;
    function TemChaveConfigurada: Boolean;
  end;

implementation

constructor TServicoIA.Create;
begin
  inherited Create;
  FConfig := TConfig.IA;
end;

function TServicoIA.TemChaveConfigurada: Boolean;
begin
  Result := Trim(FConfig.ApiKey) <> '';
end;

function TServicoIA.Perguntar(const Pergunta: string): string;
var
  HTTP: THTTPClient;
  Corpo, Mensagem, Conteudo, Item: TJSONObject;
  Mensagens, Blocos: TJSONArray;
  Requisicao: TStringStream;
  Resposta: IHTTPResponse;
  JsonResp: TJSONValue;
  i: Integer;
begin
  if not TemChaveConfigurada then
    Exit('⚠ Configure a ApiKey na seção [IA] do config.ini para eu funcionar.');

  HTTP := THTTPClient.Create;
  try
    // O try..except (tratar erro) fica ANINHADO dentro do try..finally (liberar
    // o HTTP). Em Delphi um mesmo try não pode ter except e finally juntos.
    try
    // ----- Monta o corpo JSON no formato da API Anthropic -----
    // {
    //   "model": "claude-...",
    //   "max_tokens": 1024,
    //   "messages": [ { "role": "user", "content": "..." } ]
    // }
    Corpo := TJSONObject.Create;
    try
      Corpo.AddPair('model', FConfig.Modelo);
      Corpo.AddPair('max_tokens', TJSONNumber.Create(1024));

      Mensagens := TJSONArray.Create;
      Mensagem := TJSONObject.Create;
      Mensagem.AddPair('role', 'user');
      Mensagem.AddPair('content', Pergunta);
      Mensagens.Add(Mensagem);
      Corpo.AddPair('messages', Mensagens);

      Requisicao := TStringStream.Create(Corpo.ToJSON, TEncoding.UTF8);
      try
        // ----- Cabeçalhos exigidos pela API -----
        HTTP.CustomHeaders['x-api-key'] := FConfig.ApiKey;
        HTTP.CustomHeaders['anthropic-version'] := '2023-06-01';
        HTTP.ContentType := 'application/json';

        // ----- Faz o POST -----
        Resposta := HTTP.Post(FConfig.Endpoint, Requisicao);

        if (Resposta.StatusCode < 200) or (Resposta.StatusCode >= 300) then
          Exit('Erro da API (HTTP ' + Resposta.StatusCode.ToString + '): ' +
               Resposta.ContentAsString(TEncoding.UTF8));

        // ----- Lê a resposta JSON -----
        // A resposta tem: { "content": [ { "type":"text", "text":"..." } ] }
        JsonResp := TJSONObject.ParseJSONValue(Resposta.ContentAsString(TEncoding.UTF8));
        try
          Result := '';
          if JsonResp is TJSONObject then
          begin
            Blocos := TJSONObject(JsonResp).GetValue('content') as TJSONArray;
            if Assigned(Blocos) then
              for i := 0 to Blocos.Count - 1 do
              begin
                Item := Blocos.Items[i] as TJSONObject;
                if Item.GetValue<string>('type') = 'text' then
                  Result := Result + Item.GetValue<string>('text');
              end;
          end;
          if Result = '' then
            Result := 'Não consegui interpretar a resposta da IA.';
        finally
          JsonResp.Free;
        end;
      finally
        Requisicao.Free;
      end;
    finally
      Corpo.Free;   // libera todo o JSON montado (Mensagens/Mensagem são filhos)
    end;
    except
      on E: Exception do
        Result := 'Falha ao falar com a IA: ' + E.Message;
    end;
  finally
    HTTP.Free;
  end;
end;

end.
