object FrmAssistenteIA: TFrmAssistenteIA
  Left = 0
  Top = 0
  BorderStyle = bsToolWindow
  Caption = 'Assistente'
  ClientHeight = 420
  ClientWidth = 340
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 340
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    Color = clHighlight
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 12
      Top = 9
      Width = 62
      Height = 15
      Caption = 'Assistente'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object memHistorico: TMemo
    Left = 0
    Top = 36
    Width = 340
    Height = 336
    Align = alClient
    BorderStyle = bsNone
    Color = clWindow
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    WordWrap = True
  end
  object pnlBaixo: TPanel
    Left = 0
    Top = 372
    Width = 340
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object edtPergunta: TEdit
      Left = 8
      Top = 10
      Width = 240
      Height = 23
      TabOrder = 0
    end
    object btnEnviar: TButton
      Left = 254
      Top = 9
      Width = 78
      Height = 26
      Caption = 'Enviar'
      Default = True
      TabOrder = 1
      OnClick = btnEnviarClick
    end
  end
end
