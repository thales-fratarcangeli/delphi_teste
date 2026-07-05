unit uFrmPrincipal;

{ ===========================================================================
  Janela PRINCIPAL do módulo Faturamento (a "área de trabalho" MDI).
  - FormStyle = fsMDIForm  -> janela-mãe que segura as telas filhas.
  - TMainMenu no topo       -> a "barra com várias opções" com submenus.
  - pnlBolaIA               -> a "bolinha" de IA no canto inferior direito.
  - AplicarPermissoes       -> mostra/esconde menus conforme o perfil do usuário.
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Controls, Vcl.Forms,
  Vcl.Menus, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Dialogs;

type
  TFrmPrincipal = class(TForm)
    MainMenu: TMainMenu;
    mnuCadastros: TMenuItem;
    mnuClientes: TMenuItem;
    mnuProdutos: TMenuItem;
    mnuSep1: TMenuItem;
    mnuSair: TMenuItem;
    mnuMovimento: TMenuItem;
    mnuNotaFiscal: TMenuItem;
    mnuPDV: TMenuItem;
    mnuPedidos: TMenuItem;
    mnuAprovarPedidos: TMenuItem;
    mnuFiscal: TMenuItem;
    mnuPainelNFe: TMenuItem;
    mnuConfigSEFAZ: TMenuItem;
    mnuRelatorios: TMenuItem;
    mnuCentralRel: TMenuItem;
    mnuAdmin: TMenuItem;
    mnuPrivilegios: TMenuItem;
    mnuRotinas: TMenuItem;
    mnuExemplos: TMenuItem;
    mnuClientesOO: TMenuItem;
    mnuRecursosLing: TMenuItem;
    mnuAjuda: TMenuItem;
    mnuSobre: TMenuItem;
    StatusBar: TStatusBar;
    pnlBolaIA: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure mnuClientesClick(Sender: TObject);
    procedure mnuProdutosClick(Sender: TObject);
    procedure mnuNotaFiscalClick(Sender: TObject);
    procedure mnuPDVClick(Sender: TObject);
    procedure mnuAprovarPedidosClick(Sender: TObject);
    procedure mnuPainelNFeClick(Sender: TObject);
    procedure mnuConfigSEFAZClick(Sender: TObject);
    procedure mnuCentralRelClick(Sender: TObject);
    procedure mnuPrivilegiosClick(Sender: TObject);
    procedure mnuRotinasClick(Sender: TObject);
    procedure mnuClientesOOClick(Sender: TObject);
    procedure mnuRecursosLingClick(Sender: TObject);
    procedure mnuSairClick(Sender: TObject);
    procedure mnuSobreClick(Sender: TObject);
    procedure pnlBolaIAClick(Sender: TObject);
  private
    function AbrirForm(AClasseForm: TFormClass): TForm;
    procedure DeixarBolaRedonda;
    procedure AbrirAssistente;
    procedure AplicarPermissoes;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.dfm}

uses
  uSessao, uPermissoes, uLog, uExemplosLinguagem,
  uFrmClientes, uFrmProdutos, uFrmNotaFiscal, uFrmPDV, uFrmFiscal,
  uFrmConfigNFe, uFrmRelatorios, uFrmAssistenteIA, uFrmAprovacaoPedidos,
  uFrmPermissoes, uFrmRotinas, uFrmClientesOO;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  Caption := 'Faturamento';
  StatusBar.Panels[0].Text := 'Usuário: ' + UsuarioLogado.Nome;
  StatusBar.Panels[1].Text := 'Banco conectado';
  DeixarBolaRedonda;
  AplicarPermissoes;
  TLog.Registrar(ClassName, 'Módulo Faturamento aberto.');
end;

{ Mostra apenas os menus que o perfil do usuário tem direito.
  Cada item leva a chave da permissão. Os "pais" ficam visíveis só se tiverem
  pelo menos um filho visível. }
procedure TFrmPrincipal.AplicarPermissoes;

  procedure Aplicar(Item: TMenuItem; const Chave: string);
  begin
    Item.Visible := TPermissoes.Pode(Chave);
  end;

  function AlgumFilhoVisivel(Pai: TMenuItem): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    for i := 0 to Pai.Count - 1 do
      if Pai.Items[i].Visible then
        Exit(True);
  end;

begin
  Aplicar(mnuClientes,       'FAT.CAD.CLI');
  Aplicar(mnuProdutos,       'FAT.CAD.PRO');
  Aplicar(mnuNotaFiscal,     'FAT.MOV.NF');
  Aplicar(mnuPDV,            'FAT.MOV.PDV');
  Aplicar(mnuAprovarPedidos, 'FAT.PED.APROVAR');
  Aplicar(mnuPainelNFe,      'FAT.FIS.NFE');
  Aplicar(mnuConfigSEFAZ,    'FAT.FIS.CFG');
  Aplicar(mnuCentralRel,     'FAT.REL');
  Aplicar(mnuPrivilegios,    'FAT.ADM.PERM');
  Aplicar(mnuRotinas,        'FAT.ADM.ROT');

  // Esconde os menus "pai" que ficaram sem nenhuma opção visível
  mnuCadastros.Visible  := AlgumFilhoVisivel(mnuCadastros);
  mnuMovimento.Visible  := AlgumFilhoVisivel(mnuMovimento);
  mnuPedidos.Visible    := AlgumFilhoVisivel(mnuPedidos);
  mnuFiscal.Visible     := AlgumFilhoVisivel(mnuFiscal);
  mnuRelatorios.Visible := AlgumFilhoVisivel(mnuRelatorios);
  mnuAdmin.Visible      := AlgumFilhoVisivel(mnuAdmin);
end;

procedure TFrmPrincipal.DeixarBolaRedonda;
var
  Regiao: HRGN;
begin
  Regiao := CreateEllipticRgn(0, 0, pnlBolaIA.Width, pnlBolaIA.Height);
  SetWindowRgn(pnlBolaIA.Handle, Regiao, True);
end;

function TFrmPrincipal.AbrirForm(AClasseForm: TFormClass): TForm;
var
  i: Integer;
begin
  for i := 0 to MDIChildCount - 1 do
    if MDIChildren[i].ClassType = AClasseForm then
    begin
      MDIChildren[i].BringToFront;
      Exit(MDIChildren[i]);
    end;
  Result := AClasseForm.Create(Application);
  Result.Show;
end;

procedure TFrmPrincipal.mnuClientesClick(Sender: TObject);
begin
  AbrirForm(TFrmClientes);
end;

procedure TFrmPrincipal.mnuProdutosClick(Sender: TObject);
begin
  AbrirForm(TFrmProdutos);
end;

procedure TFrmPrincipal.mnuNotaFiscalClick(Sender: TObject);
begin
  AbrirForm(TFrmNotaFiscal);
end;

procedure TFrmPrincipal.mnuPDVClick(Sender: TObject);
begin
  AbrirForm(TFrmPDV);
end;

procedure TFrmPrincipal.mnuAprovarPedidosClick(Sender: TObject);
begin
  AbrirForm(TFrmAprovacaoPedidos);
end;

procedure TFrmPrincipal.mnuPainelNFeClick(Sender: TObject);
begin
  AbrirForm(TFrmFiscal);
end;

procedure TFrmPrincipal.mnuConfigSEFAZClick(Sender: TObject);
begin
  AbrirForm(TFrmConfigNFe);
end;

procedure TFrmPrincipal.mnuCentralRelClick(Sender: TObject);
begin
  AbrirForm(TFrmRelatorios);
end;

procedure TFrmPrincipal.mnuPrivilegiosClick(Sender: TObject);
begin
  AbrirForm(TFrmPermissoes);
end;

procedure TFrmPrincipal.mnuRotinasClick(Sender: TObject);
begin
  AbrirForm(TFrmRotinas);
end;

procedure TFrmPrincipal.mnuClientesOOClick(Sender: TObject);
begin
  AbrirForm(TFrmClientesOO);
end;

procedure TFrmPrincipal.mnuRecursosLingClick(Sender: TObject);
begin
  // Roda o arquivo de referência da linguagem e mostra o resultado
  ShowMessage(uExemplosLinguagem.Demonstrar);
end;

procedure TFrmPrincipal.mnuSairClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.mnuSobreClick(Sender: TObject);
begin
  ShowMessage('ERP Didático - Módulo Faturamento' + sLineBreak +
              'Projeto de estudo em Delphi + Firebird.');
end;

procedure TFrmPrincipal.AbrirAssistente;
begin
  if FrmAssistenteIA = nil then
    FrmAssistenteIA := TFrmAssistenteIA.Create(Self);

  FrmAssistenteIA.Left := ClientToScreen(pnlBolaIA.BoundsRect.TopLeft).X +
                          pnlBolaIA.Width - FrmAssistenteIA.Width;
  FrmAssistenteIA.Top := ClientToScreen(pnlBolaIA.BoundsRect.TopLeft).Y -
                         FrmAssistenteIA.Height - 8;
  FrmAssistenteIA.Show;
  FrmAssistenteIA.BringToFront;
end;

procedure TFrmPrincipal.pnlBolaIAClick(Sender: TObject);
begin
  AbrirAssistente;
end;

end.
