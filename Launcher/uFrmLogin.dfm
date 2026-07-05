object FrmLogin: TFrmLogin
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'ERP Did'#225'tico - Acesso'
  ClientHeight = 230
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object pnlFundo: TPanel
    Left = 0
    Top = 0
    Width = 340
    Height = 230
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 20
      Width = 130
      Height = 25
      Caption = 'Bem-vindo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblLogin: TLabel
      Left = 24
      Top = 66
      Width = 32
      Height = 15
      Caption = 'Login:'
    end
    object lblSenha: TLabel
      Left = 24
      Top = 116
      Width = 36
      Height = 15
      Caption = 'Senha:'
    end
    object edtLogin: TEdit
      Left = 24
      Top = 84
      Width = 292
      Height = 23
      TabOrder = 0
    end
    object edtSenha: TEdit
      Left = 24
      Top = 134
      Width = 292
      Height = 23
      PasswordChar = '*'
      TabOrder = 1
    end
    object btnEntrar: TButton
      Left = 160
      Top = 178
      Width = 75
      Height = 30
      Caption = 'Entrar'
      Default = True
      TabOrder = 2
      OnClick = btnEntrarClick
    end
    object btnCancelar: TButton
      Left = 241
      Top = 178
      Width = 75
      Height = 30
      Cancel = True
      Caption = 'Cancelar'
      TabOrder = 3
      OnClick = btnCancelarClick
    end
  end
end
