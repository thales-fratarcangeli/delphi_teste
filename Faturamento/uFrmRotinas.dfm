object FrmRotinas: TFrmRotinas
  Left = 0
  Top = 0
  Caption = 'Rotinas do Sistema (Jenkins)'
  ClientHeight = 380
  ClientWidth = 620
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
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 620
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblJob: TLabel
      Left = 16
      Top = 8
      Width = 39
      Height = 15
      Caption = 'Rotina:'
    end
    object cboJob: TComboBox
      Left = 16
      Top = 26
      Width = 300
      Height = 23
      Style = csDropDownList
      TabOrder = 0
    end
    object btnDisparar: TButton
      Left = 330
      Top = 25
      Width = 130
      Height = 26
      Caption = 'Disparar rotina'
      TabOrder = 1
      OnClick = btnDispararClick
    end
    object btnStatus: TButton
      Left = 470
      Top = 25
      Width = 130
      Height = 26
      Caption = 'Ver status'
      TabOrder = 2
      OnClick = btnStatusClick
    end
  end
  object memSaida: TMemo
    Left = 0
    Top = 60
    Width = 620
    Height = 320
    Align = alClient
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clLime
    Font.Height = -12
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
  end
end
