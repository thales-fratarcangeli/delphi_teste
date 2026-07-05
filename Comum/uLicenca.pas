unit uLicenca;

{ ===========================================================================
  LICENÇA / BLOQUEIO do sistema.
  Verifica na tabela LICENCA se a mensalidade/boleto está em dia. Se estiver
  vencida (ou marcada como BLOQUEADO='S'), o sistema deve BLOQUEAR o acesso.

  Na vida real, essa checagem costuma bater num SERVIDOR da empresa (para o
  cliente não conseguir só "mudar a data no banco"). Aqui, para estudo,
  checamos a própria tabela. O ponto de conceito é o mesmo.
  =========================================================================== }

interface

uses
  System.SysUtils;

type
  TStatusLicenca = record
    Liberado: Boolean;       // True = pode usar; False = bloqueado
    DataVencimento: TDate;
    DiasRestantes: Integer;
    Mensagem: string;
  end;

  TLicenca = class
    class function Verificar: TStatusLicenca;
  end;

implementation

uses
  uDM, Data.DB, FireDAC.Comp.Client;

class function TLicenca.Verificar: TStatusLicenca;
var
  Qry: TFDQuery;
  Bloqueado: string;
begin
  // Assume liberado; só bloqueia se achar motivo
  Result.Liberado := True;
  Result.Mensagem := 'Licença em dia.';

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := DM.Conn;
    Qry.SQL.Text := 'SELECT DATA_VENCIMENTO, BLOQUEADO, MENSAGEM_BLOQUEIO ' +
                    'FROM LICENCA WHERE ID = 1';
    Qry.Open;

    if Qry.IsEmpty then
    begin
      // Sem registro de licença: por segurança, deixamos passar mas avisamos.
      Result.Mensagem := 'Nenhuma licença cadastrada (modo estudo).';
      Exit;
    end;

    Result.DataVencimento := Qry.FieldByName('DATA_VENCIMENTO').AsDateTime;
    Result.DiasRestantes := Trunc(Result.DataVencimento - Date);
    Bloqueado := Qry.FieldByName('BLOQUEADO').AsString;

    // Regra 1: bloqueio manual
    if Bloqueado = 'S' then
    begin
      Result.Liberado := False;
      Result.Mensagem := Qry.FieldByName('MENSAGEM_BLOQUEIO').AsString;
      Exit;
    end;

    // Regra 2: vencido
    if Result.DataVencimento < Date then
    begin
      Result.Liberado := False;
      Result.Mensagem := Qry.FieldByName('MENSAGEM_BLOQUEIO').AsString +
        sLineBreak + '(Vencido em ' +
        FormatDateTime('dd/mm/yyyy', Result.DataVencimento) + ')';
      Exit;
    end;

    // Aviso de vencimento próximo (não bloqueia, só informa)
    if Result.DiasRestantes <= 5 then
      Result.Mensagem := Format('Atenção: sua licença vence em %d dia(s).',
        [Result.DiasRestantes]);
  finally
    Qry.Free;
  end;
end;

end.
