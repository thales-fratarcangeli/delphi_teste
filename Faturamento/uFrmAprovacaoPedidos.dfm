object FrmAprovacaoPedidos: TFrmAprovacaoPedidos
  Left = 0
  Top = 0
  Caption = 'Aprova'#231#227'o de Pedidos'
  ClientHeight = 400
  ClientWidth = 680
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
    Width = 680
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnAprovar: TButton
      Left = 12
      Top = 9
      Width = 110
      Height = 30
      Caption = 'Aprovar'
      TabOrder = 0
      OnClick = btnAprovarClick
    end
    object btnReprovar: TButton
      Left = 128
      Top = 9
      Width = 110
      Height = 30
      Caption = 'Reprovar'
      TabOrder = 1
      OnClick = btnReprovarClick
    end
    object btnAtualizar: TButton
      Left = 580
      Top = 9
      Width = 90
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 2
      OnClick = btnAtualizarClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 48
    Width = 680
    Height = 352
    Align = alClient
    DataSource = dsPedidos
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object qryPedidos: TFDQuery
    Left = 300
    Top = 150
  end
  object dsPedidos: TDataSource
    DataSet = qryPedidos
    Left = 380
    Top = 150
  end
end
