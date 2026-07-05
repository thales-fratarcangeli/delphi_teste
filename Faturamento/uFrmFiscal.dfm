object FrmFiscal: TFrmFiscal
  Left = 0
  Top = 0
  Caption = 'Painel Fiscal (NF-e)'
  ClientHeight = 420
  ClientWidth = 760
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
    Width = 760
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object btnEmitir: TButton
      Left = 12
      Top = 9
      Width = 110
      Height = 30
      Caption = 'Emitir NF-e'
      TabOrder = 0
      OnClick = btnEmitirClick
    end
    object btnConsultar: TButton
      Left = 128
      Top = 9
      Width = 110
      Height = 30
      Caption = 'Consultar'
      TabOrder = 1
      OnClick = btnConsultarClick
    end
    object btnCancelar: TButton
      Left = 244
      Top = 9
      Width = 110
      Height = 30
      Caption = 'Cancelar'
      TabOrder = 2
      OnClick = btnCancelarClick
    end
    object btnEnviarEmail: TButton
      Left = 360
      Top = 9
      Width = 140
      Height = 30
      Caption = 'Enviar XML por e-mail'
      TabOrder = 3
      OnClick = btnEnviarEmailClick
    end
    object btnAtualizar: TButton
      Left = 660
      Top = 9
      Width = 90
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 4
      OnClick = btnAtualizarClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 48
    Width = 760
    Height = 372
    Align = alClient
    DataSource = dsNotas
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object qryNotas: TFDQuery
    Left = 320
    Top = 160
  end
  object dsNotas: TDataSource
    DataSet = qryNotas
    Left = 400
    Top = 160
  end
end
