unit uTarefaThread;

{ ===========================================================================
  THREAD (processamento em segundo plano).

  Problema: quando uma tarefa demora (gerar relatório grande, baixar algo da
  internet, processar muitos registros), se ela roda na thread PRINCIPAL, a
  tela CONGELA ("Não Respondendo") até terminar. A solução é rodar em uma
  THREAD SEPARADA.

  Regra de ouro: só a thread principal pode mexer na interface (labels, grids).
  Então, quando a thread quer atualizar a tela, ela usa Synchronize/Queue para
  "pedir" à thread principal que faça isso com segurança.

  Esta unit traz uma classe pronta (TTarefaLonga) que simula um trabalho demorado
  e avisa o progresso. Uso típico numa tela:

     var T := TTarefaLonga.Create(100);
     T.OnProgresso := procedure(Pct: Integer) begin ProgressBar1.Position := Pct; end;
     T.OnConcluida := procedure begin ShowMessage('Pronto!'); end;
     T.Start;
  =========================================================================== }

interface

uses
  System.Classes, System.SysUtils;

type
  // "procedure of ..." anônima usada como callback de progresso/fim
  TProgressoProc = reference to procedure(Percentual: Integer);
  TConcluidaProc = reference to procedure;

  TTarefaLonga = class(TThread)
  private
    FPassos: Integer;
    FOnProgresso: TProgressoProc;
    FOnConcluida: TConcluidaProc;
  protected
    procedure Execute; override;   // o que roda na thread separada
  public
    // FreeOnTerminate = a thread se auto-libera ao terminar
    constructor Create(APassos: Integer);
    property OnProgresso: TProgressoProc read FOnProgresso write FOnProgresso;
    property OnConcluida: TConcluidaProc read FOnConcluida write FOnConcluida;
  end;

implementation

constructor TTarefaLonga.Create(APassos: Integer);
begin
  // CreateSuspended = False -> só começa quando chamarmos Start
  inherited Create(True);
  FreeOnTerminate := True;   // ao acabar, ela mesma dá Free
  FPassos := APassos;
end;

procedure TTarefaLonga.Execute;
var
  i, Pct: Integer;
begin
  for i := 1 to FPassos do
  begin
    if Terminated then Exit;   // respeita pedido de parar

    Sleep(20);                 // aqui, no lugar real, iria o trabalho pesado
    Pct := Round(i / FPassos * 100);

    // Queue: agenda a atualização da tela na thread principal (não trava a thread).
    // (Synchronize faria o mesmo, mas ESPERANDO a tela terminar.)
    if Assigned(FOnProgresso) then
      Queue(
        procedure
        begin
          FOnProgresso(Pct);
        end);
  end;

  // Terminou: avisa a tela principal
  if Assigned(FOnConcluida) then
    Queue(
      procedure
      begin
        FOnConcluida();
      end);
end;

end.
