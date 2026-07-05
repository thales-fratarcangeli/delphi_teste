unit uServicoJenkins;

{ ===========================================================================
  Integração com o JENKINS.
  Jenkins é um servidor de automação (CI/CD): você cria "jobs" (tarefas) e ele
  executa — na hora ou agendado. Muita empresa usa o Jenkins para rodar as
  ROTINAS do ERP (ex.: fechamento diário, geração de arquivos, backups),
  em vez de deixar isso dentro do próprio sistema.

  O Jenkins tem uma API REST. Aqui a gente:
    - DispararJob: manda o Jenkins executar uma tarefa (POST .../build)
    - StatusUltimaExecucao: pergunta como foi a última execução (GET ...api/json)

  Autenticação: usuário + API Token do Jenkins, enviados no cabeçalho
  Authorization (Basic, em base64). Config na seção [Jenkins] do config.ini.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.NetEncoding,
  System.Net.HttpClient, System.Net.URLClient,
  uConfig;

type
  TServicoJenkins = class
  private
    FConfig: TConfigJenkins;
    function Autorizacao: string;
    function UrlBase: string;
  public
    constructor Create;
    // Manda executar um job. Retorna mensagem do resultado.
    function DispararJob(const NomeJob: string): string;
    // Consulta o resultado da última execução do job (SUCCESS, FAILURE...).
    function StatusUltimaExecucao(const NomeJob: string): string;
  end;

implementation

constructor TServicoJenkins.Create;
begin
  inherited Create;
  FConfig := TConfig.Jenkins;
end;

function TServicoJenkins.UrlBase: string;
begin
  Result := FConfig.Url.TrimRight(['/']);
end;

{ Monta o cabeçalho "Basic base64(usuario:token)" exigido pelo Jenkins. }
function TServicoJenkins.Autorizacao: string;
begin
  Result := 'Basic ' + TNetEncoding.Base64.Encode(
    FConfig.Usuario + ':' + FConfig.Token);
end;

function TServicoJenkins.DispararJob(const NomeJob: string): string;
var
  HTTP: THTTPClient;
  Resp: IHTTPResponse;
  Corpo: TStringStream;
begin
  if FConfig.Url = '' then
    Exit('Jenkins não configurado (preencha a seção [Jenkins] no config.ini).');

  HTTP := THTTPClient.Create;
  Corpo := TStringStream.Create('');   // POST sem corpo
  try
    HTTP.CustomHeaders['Authorization'] := Autorizacao;
    try
      // POST http://servidor/job/NOME/build  -> enfileira a execução
      Resp := HTTP.Post(UrlBase + '/job/' + NomeJob + '/build', Corpo);
      // 201 Created = job enfileirado com sucesso
      if Resp.StatusCode = 201 then
        Result := 'Job "' + NomeJob + '" disparado com sucesso.'
      else
        Result := 'Jenkins respondeu HTTP ' + Resp.StatusCode.ToString + ': ' +
                  Resp.StatusText;
    except
      on E: Exception do
        Result := 'Falha ao falar com o Jenkins: ' + E.Message;
    end;
  finally
    Corpo.Free;
    HTTP.Free;
  end;
end;

function TServicoJenkins.StatusUltimaExecucao(const NomeJob: string): string;
var
  HTTP: THTTPClient;
  Resp: IHTTPResponse;
  Json: TJSONValue;
  Resultado, Building: string;
begin
  if FConfig.Url = '' then
    Exit('Jenkins não configurado.');

  HTTP := THTTPClient.Create;
  try
    HTTP.CustomHeaders['Authorization'] := Autorizacao;
    try
      // GET .../lastBuild/api/json -> traz um JSON com "result" e "building"
      Resp := HTTP.Get(UrlBase + '/job/' + NomeJob + '/lastBuild/api/json');
      if Resp.StatusCode <> 200 then
        Exit('HTTP ' + Resp.StatusCode.ToString + ' ao consultar o job.');

      Json := TJSONObject.ParseJSONValue(Resp.ContentAsString(TEncoding.UTF8));
      try
        if Json is TJSONObject then
        begin
          Building := TJSONObject(Json).GetValue('building').ToString;
          if Building = 'true' then
            Result := 'Job "' + NomeJob + '" está EM EXECUÇÃO agora.'
          else
          begin
            Resultado := TJSONObject(Json).GetValue<string>('result');
            Result := 'Última execução de "' + NomeJob + '": ' + Resultado;
          end;
        end
        else
          Result := 'Resposta inesperada do Jenkins.';
      finally
        Json.Free;
      end;
    except
      on E: Exception do
        Result := 'Falha ao consultar o Jenkins: ' + E.Message;
    end;
  finally
    HTTP.Free;
  end;
end;

end.
