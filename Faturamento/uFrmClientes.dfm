object FrmClientes: TFrmClientes
  Left = 0
  Top = 0
  Caption = 'Cadastro de Clientes'
  ClientHeight = 400
  ClientWidth = 700
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
    Width = 700
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Nav: TDBNavigator
      Left = 8
      Top = 6
      Width = 280
      Height = 28
      DataSource = dsClientes
      TabOrder = 0
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 40
    Width = 700
    Height = 360
    Align = alClient
    DataSource = dsClientes
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object qryClientes: TFDQuery
    BeforePost = qryClientesBeforePost
    Left = 320
    Top = 96
  end
  object dsClientes: TDataSource
    DataSet = qryClientes
    Left = 400
    Top = 96
  end
end
