object FrmModulos: TFrmModulos
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'M'#243'dulos'
  ClientHeight = 260
  ClientWidth = 220
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 220
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Color = clHighlight
    ParentBackground = False
    TabOrder = 0
    object lblUsuario: TLabel
      Left = 10
      Top = 12
      Width = 55
      Height = 15
      Caption = 'Usu'#225'rio: ...'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object btnFaturamento: TButton
    Left = 16
    Top = 56
    Width = 188
    Height = 40
    Caption = 'Faturamento'
    TabOrder = 1
    OnClick = btnFaturamentoClick
  end
  object btnEstoque: TButton
    Left = 16
    Top = 102
    Width = 188
    Height = 40
    Caption = 'Estoque'
    TabOrder = 2
    OnClick = btnEmDesenvolvimentoClick
  end
  object btnFinanceiro: TButton
    Left = 16
    Top = 148
    Width = 188
    Height = 40
    Caption = 'Financeiro'
    TabOrder = 3
    OnClick = btnEmDesenvolvimentoClick
  end
  object btnCadastros: TButton
    Left = 16
    Top = 194
    Width = 188
    Height = 40
    Caption = 'Cadastros Gerais'
    TabOrder = 4
    OnClick = btnEmDesenvolvimentoClick
  end
end
