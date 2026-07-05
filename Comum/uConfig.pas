unit uConfig;

{ ===========================================================================
  Camada de CONFIGURAÇÃO.
  Centraliza a leitura do config.ini e entrega os dados já organizados em
  "records" por assunto (SEFAZ, Email, TEF, IA...). Assim os serviços não
  ficam lendo .ini espalhado pelo código — pedem tudo aqui.

  Padrão de projeto: isso é uma forma simples de "camada de configuração".
  =========================================================================== }

interface

uses
  System.SysUtils, System.IniFiles;

type
  TConfigSEFAZ = record
    Ambiente: string;            // HOMOLOGACAO ou PRODUCAO
    UF: string;
    CNPJ: string;
    RazaoSocial: string;
    InscricaoEstadual: string;
    CaminhoCertificado: string;
    SenhaCertificado: string;
    CSC: string;
    IdTokenCSC: string;
    UrlWebservice: string;
    function EhProducao: Boolean;
  end;

  TConfigEmail = record
    Servidor: string;
    Porta: Integer;
    Usuario: string;
    Senha: string;
    UsarTLS: Boolean;
    Remetente: string;
    NomeRemetente: string;
  end;

  TConfigTEF = record
    Provedor: string;
    TerminalId: string;
    ChaveIntegracao: string;
  end;

  TConfigIA = record
    Endpoint: string;
    Modelo: string;
    ApiKey: string;
    NomeAssistente: string;
  end;

  TConfigJenkins = record
    Url: string;
    Usuario: string;
    Token: string;
  end;

  { Classe utilitária só com métodos de classe (não precisa instanciar). }
  TConfig = class
  private
    class function Arquivo: string;
  public
    class function SEFAZ: TConfigSEFAZ;
    class function Email: TConfigEmail;
    class function TEF: TConfigTEF;
    class function IA: TConfigIA;
    class function Jenkins: TConfigJenkins;
  end;

implementation

{ TConfigSEFAZ }

function TConfigSEFAZ.EhProducao: Boolean;
begin
  Result := SameText(Ambiente, 'PRODUCAO');
end;

{ TConfig }

class function TConfig.Arquivo: string;
begin
  // config.ini fica na mesma pasta do executável
  Result := ExtractFilePath(ParamStr(0)) + 'config.ini';
end;

class function TConfig.SEFAZ: TConfigSEFAZ;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Arquivo);
  try
    Result.Ambiente          := Ini.ReadString('SEFAZ', 'Ambiente', 'HOMOLOGACAO');
    Result.UF                := Ini.ReadString('SEFAZ', 'UF', 'SP');
    Result.CNPJ              := Ini.ReadString('SEFAZ', 'CNPJ', '');
    Result.RazaoSocial       := Ini.ReadString('SEFAZ', 'RazaoSocial', '');
    Result.InscricaoEstadual := Ini.ReadString('SEFAZ', 'InscricaoEstadual', '');
    Result.CaminhoCertificado:= Ini.ReadString('SEFAZ', 'CaminhoCertificado', '');
    Result.SenhaCertificado  := Ini.ReadString('SEFAZ', 'SenhaCertificado', '');
    Result.CSC               := Ini.ReadString('SEFAZ', 'CSC', '');
    Result.IdTokenCSC        := Ini.ReadString('SEFAZ', 'IdTokenCSC', '1');
    Result.UrlWebservice     := Ini.ReadString('SEFAZ', 'UrlWebservice', '');
  finally
    Ini.Free;
  end;
end;

class function TConfig.Email: TConfigEmail;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Arquivo);
  try
    Result.Servidor      := Ini.ReadString('Email', 'Servidor', '');
    Result.Porta         := Ini.ReadInteger('Email', 'Porta', 587);
    Result.Usuario       := Ini.ReadString('Email', 'Usuario', '');
    Result.Senha         := Ini.ReadString('Email', 'Senha', '');
    Result.UsarTLS       := Ini.ReadBool('Email', 'UsarTLS', True);
    Result.Remetente     := Ini.ReadString('Email', 'Remetente', '');
    Result.NomeRemetente := Ini.ReadString('Email', 'NomeRemetente', 'ERP');
  finally
    Ini.Free;
  end;
end;

class function TConfig.TEF: TConfigTEF;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Arquivo);
  try
    Result.Provedor        := Ini.ReadString('TEF', 'Provedor', 'SIMULADO');
    Result.TerminalId      := Ini.ReadString('TEF', 'TerminalId', '0001');
    Result.ChaveIntegracao := Ini.ReadString('TEF', 'ChaveIntegracao', '');
  finally
    Ini.Free;
  end;
end;

class function TConfig.IA: TConfigIA;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Arquivo);
  try
    Result.Endpoint       := Ini.ReadString('IA', 'Endpoint', 'https://api.anthropic.com/v1/messages');
    Result.Modelo         := Ini.ReadString('IA', 'Modelo', 'claude-opus-4-8');
    Result.ApiKey         := Ini.ReadString('IA', 'ApiKey', '');
    Result.NomeAssistente := Ini.ReadString('IA', 'NomeAssistente', 'Assistente ERP');
  finally
    Ini.Free;
  end;
end;

class function TConfig.Jenkins: TConfigJenkins;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(Arquivo);
  try
    Result.Url     := Ini.ReadString('Jenkins', 'Url', '');
    Result.Usuario := Ini.ReadString('Jenkins', 'Usuario', '');
    Result.Token   := Ini.ReadString('Jenkins', 'Token', '');
  finally
    Ini.Free;
  end;
end;

end.
