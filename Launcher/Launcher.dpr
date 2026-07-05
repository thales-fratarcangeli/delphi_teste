program Launcher;

{ ===========================================================================
  Projeto LAUNCHER.
  É o programa que o usuário abre primeiro. Ele:
    1) Mostra a tela de LOGIN.
    2) Se o login der certo, mostra a janelinha de MÓDULOS no canto da tela.
    3) Ao clicar num módulo, ele CHAMA outro executável (ex.: Faturamento.exe).

  Repare na ordem em begin..end: primeiro criamos o DataModule (conexão),
  depois mostramos o login de forma MODAL. Só se o login for OK é que
  a aplicação de fato "roda" mostrando a janela de módulos.
  =========================================================================== }

uses
  Vcl.Forms,
  Vcl.Controls,
  uDM in '..\Comum\uDM.pas' {DM: TDataModule},
  uSessao in '..\Comum\uSessao.pas',
  uConfig in '..\Comum\uConfig.pas',
  uLog in '..\Comum\uLog.pas',
  uLicenca in '..\Comum\uLicenca.pas',
  uPermissoes in '..\Comum\uPermissoes.pas',
  uFrmLogin in 'uFrmLogin.pas' {FrmLogin},
  uFrmModulos in 'uFrmModulos.pas' {FrmModulos};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar := True;
  Application.Title := 'ERP Didático';

  // Cria a conexão com o banco (DataModule)
  Application.CreateForm(TDM, DM);

  // Mostra o login como janela MODAL (trava o resto até o usuário responder)
  FrmLogin := TFrmLogin.Create(nil);
  try
    if FrmLogin.ShowModal = mrOk then
    begin
      // Login OK -> cria a janela de módulos como form principal e roda
      Application.CreateForm(TFrmModulos, FrmModulos);
      Application.Run;
    end;
    // Se o usuário cancelou o login, o programa simplesmente encerra.
  finally
    FrmLogin.Free;
  end;
end.
