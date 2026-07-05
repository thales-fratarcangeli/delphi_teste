object FrmRelatorios: TFrmRelatorios
  Left = 0
  Top = 0
  Caption = 'Relat'#243'rios'
  ClientHeight = 220
  ClientWidth = 460
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
  object lblPeriodo: TLabel
    Left = 24
    Top = 24
    Width = 47
    Height = 15
    Caption = 'Per'#237'odo:'
  end
  object lblAte: TLabel
    Left = 220
    Top = 24
    Width = 18
    Height = 15
    Caption = 'at'#233':'
  end
  object dtpIni: TDateTimePicker
    Left = 80
    Top = 20
    Width = 130
    Height = 23
    Date = 45000.000000000000000000
    Time = 0.000000000000000000
    TabOrder = 0
  end
  object dtpFim: TDateTimePicker
    Left = 250
    Top = 20
    Width = 130
    Height = 23
    Date = 45000.000000000000000000
    Time = 0.000000000000000000
    TabOrder = 1
  end
  object btnNotas: TButton
    Left = 24
    Top = 72
    Width = 410
    Height = 38
    Caption = 'Notas Fiscais por per'#237'odo'
    TabOrder = 2
    OnClick = btnNotasClick
  end
  object btnEstoque: TButton
    Left = 24
    Top = 116
    Width = 410
    Height = 38
    Caption = 'Posi'#231#227'o de Estoque'
    TabOrder = 3
    OnClick = btnEstoqueClick
  end
  object btnVendasPDV: TButton
    Left = 24
    Top = 160
    Width = 410
    Height = 38
    Caption = 'Vendas no PDV por per'#237'odo'
    TabOrder = 4
    OnClick = btnVendasPDVClick
  end
end
