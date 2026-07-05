object FrmPDV: TFrmPDV
  Left = 0
  Top = 0
  Caption = 'PDV - Ponto de Venda'
  ClientHeight = 480
  ClientWidth = 640
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
  object pnlItem: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 70
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblProduto: TLabel
      Left = 16
      Top = 8
      Width = 46
      Height = 15
      Caption = 'Produto:'
    end
    object lblQtd: TLabel
      Left = 360
      Top = 8
      Width = 27
      Height = 15
      Caption = 'Qtd:'
    end
    object cboProduto: TComboBox
      Left = 16
      Top = 28
      Width = 330
      Height = 23
      Style = csDropDownList
      TabOrder = 0
    end
    object edtQtd: TEdit
      Left = 360
      Top = 28
      Width = 80
      Height = 23
      TabOrder = 1
      Text = '1'
    end
    object btnAddItem: TButton
      Left = 456
      Top = 27
      Width = 150
      Height = 25
      Caption = 'Adicionar item (F2)'
      TabOrder = 2
      OnClick = btnAddItemClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 70
    Width = 640
    Height = 320
    Align = alClient
    DataSource = dsItens
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 390
    Width = 640
    Height = 90
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object lblTotalCap: TLabel
      Left = 16
      Top = 12
      Width = 34
      Height = 15
      Caption = 'Total:'
    end
    object lblTotal: TLabel
      Left = 56
      Top = 4
      Width = 74
      Height = 30
      Caption = 'R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblForma: TLabel
      Left = 16
      Top = 52
      Width = 118
      Height = 15
      Caption = 'Forma de pagamento:'
    end
    object cboForma: TComboBox
      Left = 140
      Top = 49
      Width = 160
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = 'DINHEIRO'
      Items.Strings = (
        'DINHEIRO'
        'DEBITO'
        'CREDITO'
        'PIX')
    end
    object btnFinalizar: TButton
      Left = 470
      Top = 44
      Width = 150
      Height = 36
      Caption = 'Finalizar venda'
      TabOrder = 1
      OnClick = btnFinalizarClick
    end
    object btnCancelarVenda: TButton
      Left = 340
      Top = 44
      Width = 120
      Height = 36
      Caption = 'Cancelar'
      TabOrder = 2
      OnClick = btnCancelarVendaClick
    end
  end
  object memItens: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired]
    UpdateOptions.CheckRequired = False
    Left = 300
    Top = 180
  end
  object dsItens: TDataSource
    DataSet = memItens
    Left = 380
    Top = 180
  end
end
