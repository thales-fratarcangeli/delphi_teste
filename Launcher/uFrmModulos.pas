unit uFrmModulos;

{ ===========================================================================
  Janelinha de MÓDULOS (fica no canto da tela).
  Depois do login, mostra botões para cada módulo do ERP.
  Ao clicar num módulo, chamamos o executável daquele módulo com ShellExecute.

  Em ERPs modulares assim, cada módulo costuma ser um .EXE separado. O launcher
  só faz o login e "dispara" o módulo escolhido.
  =========================================================================== }

interface

uses
  Winapi.Windows, Winapi.ShellAPI, System.SysUtils, System.Classes,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs;

type
  TFrmModulos = class(TForm)
    pnlTopo: TPanel;
    lblUsuario: TLabel;
    btnFaturamento: TButton;
    btnEstoque: TButton;
    btnFinanceiro: TButton;
    btnCadastros: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnFaturamentoClick(Sender: TObject);
    procedure btnEmDesenvolvimentoClick(Sender: TObject);
  private
    procedure AbrirModulo(const NomeExe: string);
  end;

var
  FrmModulos: TFrmModulos;

implementation

{$R *.dfm}

uses
  uSessao;

procedure TFrmModulos.FormCreate(Sender: TObject);
begin
  // Mostra quem está logado
  lblUsuario.Caption := 'Usuário: ' + UsuarioLogado.Nome;

  // Posiciona a janelinha no canto superior direito da tela de trabalho.
  Left := Screen.WorkAreaWidth - Width - 10;
  Top  := 10;
end;

{ Monta o caminho do .exe do módulo e o executa.
  Em desenvolvimento, cada módulo é compilado numa subpasta. Aqui montamos
  o caminho relativo à pasta do launcher. Ajuste conforme onde você compila. }
procedure TFrmModulos.AbrirModulo(const NomeExe: string);
var
  Caminho: string;
begin
  // Ex.: ...\Launcher\..\Faturamento\Win32\Debug\Faturamento.exe
  // Para simplificar o estudo, procuramos o exe na pasta ..\Faturamento\
  Caminho := ExtractFilePath(ParamStr(0)) + '..\' + NomeExe;

  if not FileExists(Caminho) then
  begin
    ShowMessage('Módulo não encontrado:' + sLineBreak + Caminho + sLineBreak +
      sLineBreak + 'Compile o módulo primeiro e ajuste o caminho em AbrirModulo().');
    Exit;
  end;

  // ShellExecute abre o programa. Passamos o LOGIN do usuário como parâmetro,
  // para o módulo saber quem está usando sem pedir login de novo.
  ShellExecute(Handle, 'open', PChar(Caminho),
    PChar('/usuario=' + UsuarioLogado.Login), nil, SW_SHOWNORMAL);
end;

procedure TFrmModulos.btnFaturamentoClick(Sender: TObject);
begin
  AbrirModulo('Faturamento\Faturamento.exe');
end;

procedure TFrmModulos.btnEmDesenvolvimentoClick(Sender: TObject);
begin
  ShowMessage('Módulo em desenvolvimento.');
end;

end.
