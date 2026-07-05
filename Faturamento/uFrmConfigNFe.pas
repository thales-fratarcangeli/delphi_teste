unit uFrmConfigNFe;

{ ===========================================================================
  Tela de CONFIGURAÇÃO DA NF-e / SEFAZ.
  Campos GENÉRICOS para o usuário preencher as credenciais fiscais. Ao salvar,
  grava tudo na seção [SEFAZ] do config.ini (via TIniFile).
  =========================================================================== }

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.IniFiles,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Dialogs, Vcl.Mask;

type
  TFrmConfigNFe = class(TForm)
    pnlBotoes: TPanel;
    btnSalvar: TButton;
    btnFechar: TButton;
    lblAmbiente: TLabel;
    cboAmbiente: TComboBox;
    lblUF: TLabel;
    edtUF: TEdit;
    lblCNPJ: TLabel;
    edtCNPJ: TEdit;
    lblRazao: TLabel;
    edtRazao: TEdit;
    lblIE: TLabel;
    edtIE: TEdit;
    lblCert: TLabel;
    edtCert: TEdit;
    btnProcurarCert: TButton;
    lblSenhaCert: TLabel;
    edtSenhaCert: TEdit;
    lblCSC: TLabel;
    edtCSC: TEdit;
    lblToken: TLabel;
    edtToken: TEdit;
    lblUrl: TLabel;
    edtUrl: TEdit;
    OpenDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure btnProcurarCertClick(Sender: TObject);
  private
    function ArquivoIni: string;
  end;

var
  FrmConfigNFe: TFrmConfigNFe;

implementation

{$R *.dfm}

function TFrmConfigNFe.ArquivoIni: string;
begin
  Result := ExtractFilePath(ParamStr(0)) + 'config.ini';
end;

procedure TFrmConfigNFe.FormCreate(Sender: TObject);
var
  Ini: TIniFile;
begin
  // Carrega os valores atuais do config.ini para os campos
  Ini := TIniFile.Create(ArquivoIni);
  try
    cboAmbiente.ItemIndex := cboAmbiente.Items.IndexOf(
      Ini.ReadString('SEFAZ', 'Ambiente', 'HOMOLOGACAO'));
    edtUF.Text        := Ini.ReadString('SEFAZ', 'UF', 'SP');
    edtCNPJ.Text      := Ini.ReadString('SEFAZ', 'CNPJ', '');
    edtRazao.Text     := Ini.ReadString('SEFAZ', 'RazaoSocial', '');
    edtIE.Text        := Ini.ReadString('SEFAZ', 'InscricaoEstadual', '');
    edtCert.Text      := Ini.ReadString('SEFAZ', 'CaminhoCertificado', '');
    edtSenhaCert.Text := Ini.ReadString('SEFAZ', 'SenhaCertificado', '');
    edtCSC.Text       := Ini.ReadString('SEFAZ', 'CSC', '');
    edtToken.Text     := Ini.ReadString('SEFAZ', 'IdTokenCSC', '1');
    edtUrl.Text       := Ini.ReadString('SEFAZ', 'UrlWebservice', '');
  finally
    Ini.Free;
  end;
end;

procedure TFrmConfigNFe.btnProcurarCertClick(Sender: TObject);
begin
  OpenDialog.Filter := 'Certificado A1 (*.pfx)|*.pfx|Todos (*.*)|*.*';
  if OpenDialog.Execute then
    edtCert.Text := OpenDialog.FileName;
end;

procedure TFrmConfigNFe.btnSalvarClick(Sender: TObject);
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(ArquivoIni);
  try
    Ini.WriteString('SEFAZ', 'Ambiente', cboAmbiente.Text);
    Ini.WriteString('SEFAZ', 'UF', edtUF.Text);
    Ini.WriteString('SEFAZ', 'CNPJ', edtCNPJ.Text);
    Ini.WriteString('SEFAZ', 'RazaoSocial', edtRazao.Text);
    Ini.WriteString('SEFAZ', 'InscricaoEstadual', edtIE.Text);
    Ini.WriteString('SEFAZ', 'CaminhoCertificado', edtCert.Text);
    Ini.WriteString('SEFAZ', 'SenhaCertificado', edtSenhaCert.Text);
    Ini.WriteString('SEFAZ', 'CSC', edtCSC.Text);
    Ini.WriteString('SEFAZ', 'IdTokenCSC', edtToken.Text);
    Ini.WriteString('SEFAZ', 'UrlWebservice', edtUrl.Text);
    Ini.UpdateFile;   // garante gravação em disco
  finally
    Ini.Free;
  end;
  ShowMessage('Configurações da SEFAZ salvas.');
  Close;
end;

procedure TFrmConfigNFe.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmConfigNFe.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

end.
