object FrmConfigNFe: TFrmConfigNFe
  Left = 0
  Top = 0
  Caption = 'Configura'#231#227'o Fiscal (SEFAZ)'
  ClientHeight = 430
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIChild
  Position = poDefault
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object lblAmbiente: TLabel
    Left = 24
    Top = 20
    Width = 58
    Height = 15
    Caption = 'Ambiente:'
  end
  object lblUF: TLabel
    Left = 300
    Top = 20
    Width = 18
    Height = 15
    Caption = 'UF:'
  end
  object lblCNPJ: TLabel
    Left = 24
    Top = 64
    Width = 36
    Height = 15
    Caption = 'CNPJ:'
  end
  object lblRazao: TLabel
    Left = 220
    Top = 64
    Width = 74
    Height = 15
    Caption = 'Raz'#227'o social:'
  end
  object lblIE: TLabel
    Left = 24
    Top = 108
    Width = 100
    Height = 15
    Caption = 'Inscri'#231#227'o estadual:'
  end
  object lblCert: TLabel
    Left = 24
    Top = 152
    Width = 130
    Height = 15
    Caption = 'Certificado A1 (.pfx):'
  end
  object lblSenhaCert: TLabel
    Left = 24
    Top = 196
    Width = 121
    Height = 15
    Caption = 'Senha do certificado:'
  end
  object lblCSC: TLabel
    Left = 300
    Top = 196
    Width = 130
    Height = 15
    Caption = 'CSC (NFC-e / mod 65):'
  end
  object lblToken: TLabel
    Left = 24
    Top = 240
    Width = 76
    Height = 15
    Caption = 'ID Token CSC:'
  end
  object lblUrl: TLabel
    Left = 24
    Top = 284
    Width = 260
    Height = 15
    Caption = 'URL do webservice (vazio = modo simulado):'
  end
  object cboAmbiente: TComboBox
    Left = 24
    Top = 38
    Width = 250
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 0
    Text = 'HOMOLOGACAO'
    Items.Strings = (
      'HOMOLOGACAO'
      'PRODUCAO')
  end
  object edtUF: TEdit
    Left = 300
    Top = 38
    Width = 60
    Height = 23
    CharCase = ecUpperCase
    MaxLength = 2
    TabOrder = 1
  end
  object edtCNPJ: TEdit
    Left = 24
    Top = 82
    Width = 180
    Height = 23
    TabOrder = 2
  end
  object edtRazao: TEdit
    Left = 220
    Top = 82
    Width = 316
    Height = 23
    TabOrder = 3
  end
  object edtIE: TEdit
    Left = 24
    Top = 126
    Width = 250
    Height = 23
    TabOrder = 4
  end
  object edtCert: TEdit
    Left = 24
    Top = 170
    Width = 430
    Height = 23
    TabOrder = 5
  end
  object btnProcurarCert: TButton
    Left = 460
    Top = 169
    Width = 76
    Height = 25
    Caption = 'Procurar...'
    TabOrder = 6
    OnClick = btnProcurarCertClick
  end
  object edtSenhaCert: TEdit
    Left = 24
    Top = 214
    Width = 250
    Height = 23
    PasswordChar = '*'
    TabOrder = 7
  end
  object edtCSC: TEdit
    Left = 300
    Top = 214
    Width = 236
    Height = 23
    TabOrder = 8
  end
  object edtToken: TEdit
    Left = 24
    Top = 258
    Width = 100
    Height = 23
    TabOrder = 9
  end
  object edtUrl: TEdit
    Left = 24
    Top = 302
    Width = 512
    Height = 23
    TabOrder = 10
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 391
    Width = 560
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 11
    object btnSalvar: TButton
      Left = 360
      Top = 5
      Width = 90
      Height = 30
      Caption = 'Salvar'
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnFechar: TButton
      Left = 456
      Top = 5
      Width = 90
      Height = 30
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
  object OpenDialog: TOpenDialog
    Left = 480
    Top = 40
  end
end
