unit uServicoEmail;

{ ===========================================================================
  SERVIÇO DE E-MAIL.
  Envia um e-mail com um anexo (o XML da NF-e, por exemplo) usando os
  componentes Indy (TIdSMTP), que já vêm com o Delphi.

  Fluxo típico: depois de emitir a nota, o sistema manda o XML/DANFE para o
  e-mail do cliente automaticamente.
  =========================================================================== }

interface

uses
  System.SysUtils, System.Classes,
  IdSMTP, IdMessage, IdSSLOpenSSL, IdExplicitTLSClientServerBase,
  IdAttachmentFile, IdText,
  uConfig;

type
  TServicoEmail = class
  private
    FConfig: TConfigEmail;
  public
    constructor Create;
    { Envia um e-mail. AnexoArquivo pode ser vazio (sem anexo).
      Retorna True se enviou; em Erro devolve a mensagem do problema. }
    function Enviar(const Destinatario, Assunto, Corpo, AnexoArquivo: string;
      out Erro: string): Boolean;
  end;

implementation

constructor TServicoEmail.Create;
begin
  inherited Create;
  FConfig := TConfig.Email;
end;

function TServicoEmail.Enviar(const Destinatario, Assunto, Corpo,
  AnexoArquivo: string; out Erro: string): Boolean;
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
  SSL: TIdSSLIOHandlerSocketOpenSSL;
begin
  Result := False;
  Erro := '';

  SMTP := TIdSMTP.Create(nil);
  Msg  := TIdMessage.Create(nil);
  SSL  := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    try
      // --- Configura o servidor de saída (SMTP) ---
      SMTP.Host := FConfig.Servidor;
      SMTP.Port := FConfig.Porta;
      SMTP.Username := FConfig.Usuario;
      SMTP.Password := FConfig.Senha;

      // TLS/SSL (a maioria dos provedores exige hoje em dia)
      if FConfig.UsarTLS then
      begin
        SMTP.IOHandler := SSL;
        SMTP.UseTLS := utUseExplicitTLS;   // STARTTLS (porta 587)
      end;

      // --- Monta a mensagem ---
      Msg.From.Address := FConfig.Remetente;
      Msg.From.Name := FConfig.NomeRemetente;
      Msg.Recipients.EMailAddresses := Destinatario;
      Msg.Subject := Assunto;

      // Corpo do e-mail (texto simples)
      with TIdText.Create(Msg.MessageParts) do
        Body.Text := Corpo;

      // Anexo (o XML da nota), se informado e existir
      if (AnexoArquivo <> '') and FileExists(AnexoArquivo) then
        TIdAttachmentFile.Create(Msg.MessageParts, AnexoArquivo);

      // --- Envia ---
      SMTP.Connect;
      try
        SMTP.Send(Msg);
        Result := True;
      finally
        SMTP.Disconnect;
      end;
    except
      on E: Exception do
        Erro := E.Message;   // devolve o erro para a tela mostrar
    end;
  finally
    SSL.Free;
    Msg.Free;
    SMTP.Free;
  end;
end;

end.
