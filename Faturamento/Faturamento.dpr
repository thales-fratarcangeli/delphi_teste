program Faturamento;

{ ===========================================================================
  Módulo FATURAMENTO.
  Aplicação MDI: a janela principal (uFrmPrincipal) é a "área de trabalho" com
  um menu no topo; as telas abrem dentro dela como janelas filhas (MDI Child).

  Repare na organização das units:
   - Comum\           -> conexão, sessão, configuração
   - Comum\Servicos\  -> integrações (SEFAZ, e-mail, TEF, IA, relatórios)
   - (esta pasta)     -> as telas (Forms) do módulo
  =========================================================================== }

uses
  Vcl.Forms,
  // --- Comum ---
  uDM in '..\Comum\uDM.pas' {DM: TDataModule},
  uSessao in '..\Comum\uSessao.pas',
  uConfig in '..\Comum\uConfig.pas',
  uLog in '..\Comum\uLog.pas',
  uLicenca in '..\Comum\uLicenca.pas',
  uPermissoes in '..\Comum\uPermissoes.pas',
  uExemplosLinguagem in '..\Comum\uExemplosLinguagem.pas',
  uTarefaThread in '..\Comum\uTarefaThread.pas',
  // --- Camada de domínio (entidades + DAO) ---
  uEntidades in '..\Comum\Dominio\uEntidades.pas',
  uClienteDAO in '..\Comum\Dominio\uClienteDAO.pas',
  // --- Serviços (integrações) ---
  uServicoNFe in '..\Comum\Servicos\uServicoNFe.pas',
  uServicoEmail in '..\Comum\Servicos\uServicoEmail.pas',
  uServicoTEF in '..\Comum\Servicos\uServicoTEF.pas',
  uServicoIA in '..\Comum\Servicos\uServicoIA.pas',
  uServicoJenkins in '..\Comum\Servicos\uServicoJenkins.pas',
  uRelatorios in '..\Comum\Servicos\uRelatorios.pas',
  // --- Telas (Forms) ---
  uFrmPrincipal in 'uFrmPrincipal.pas' {FrmPrincipal},
  uFrmClientes in 'uFrmClientes.pas' {FrmClientes},
  uFrmProdutos in 'uFrmProdutos.pas' {FrmProdutos},
  uFrmNotaFiscal in 'uFrmNotaFiscal.pas' {FrmNotaFiscal},
  uFrmPDV in 'uFrmPDV.pas' {FrmPDV},
  uFrmFiscal in 'uFrmFiscal.pas' {FrmFiscal},
  uFrmConfigNFe in 'uFrmConfigNFe.pas' {FrmConfigNFe},
  uFrmRelatorios in 'uFrmRelatorios.pas' {FrmRelatorios},
  uFrmAssistenteIA in 'uFrmAssistenteIA.pas' {FrmAssistenteIA},
  uFrmAprovacaoPedidos in 'uFrmAprovacaoPedidos.pas' {FrmAprovacaoPedidos},
  uFrmPermissoes in 'uFrmPermissoes.pas' {FrmPermissoes},
  uFrmRotinas in 'uFrmRotinas.pas' {FrmRotinas},
  uFrmClientesOO in 'uFrmClientesOO.pas' {FrmClientesOO};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskBar := True;
  Application.Title := 'Faturamento';

  Application.CreateForm(TDM, DM);        // conexão com o banco
  DM.InicializarSessaoModulo;             // recarrega usuário (/usuario=...) e permissões
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);  // janela MDI principal
  Application.Run;
end.
