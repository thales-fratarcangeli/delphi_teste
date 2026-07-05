object FrmNotaFiscal: TFrmNotaFiscal
  Left = 0
  Top = 0
  Caption = 'Nota Fiscal'
  ClientHeight = 520
  ClientWidth = 740
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
  object pnlCabecalho: TPanel
    Left = 0
    Top = 0
    Width = 740
    Height = 90
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblNumero: TLabel
      Left = 16
      Top = 12
      Width = 92
      Height = 15
      Caption = 'N'#250'mero da nota:'
    end
    object lblData: TLabel
      Left = 180
      Top = 12
      Width = 61
      Height = 15
      Caption = 'Emiss'#227'o:'
    end
    object lblCliente: TLabel
      Left = 16
      Top = 52
      Width = 40
      Height = 15
      Caption = 'Cliente:'
    end
    object edtNumero: TEdit
      Left = 16
      Top = 30
      Width = 150
      Height = 23
      NumbersOnly = True
      TabOrder = 0
    end
    object dtpEmissao: TDateTimePicker
      Left = 180
      Top = 30
      Width = 130
      Height = 23
      Date = 45000.000000000000000000
      Time = 0.000000000000000000
      TabOrder = 1
    end
    object cboCliente: TComboBox
      Left = 62
      Top = 49
      Width = 400
      Height = 23
      Style = csDropDownList
      TabOrder = 2
    end
  end
  object pnlItem: TPanel
    Left = 0
    Top = 90
    Width = 740
    Height = 70
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblProduto: TLabel
      Left = 16
      Top = 8
      Width = 46
      Height = 15
      Caption = 'Produto:'
    end
    object lblQtd: TLabel
      Left = 420
      Top = 8
      Width = 27
      Height = 15
      Caption = 'Qtd:'
    end
    object cboProduto: TComboBox
      Left = 16
      Top = 28
      Width = 390
      Height = 23
      Style = csDropDownList
      TabOrder = 0
    end
    object edtQtd: TEdit
      Left = 420
      Top = 28
      Width = 80
      Height = 23
      TabOrder = 1
      Text = '1'
    end
    object btnAddItem: TButton
      Left = 516
      Top = 27
      Width = 100
      Height = 25
      Caption = 'Adicionar item'
      TabOrder = 2
      OnClick = btnAddItemClick
    end
    object btnDelItem: TButton
      Left = 622
      Top = 27
      Width = 100
      Height = 25
      Caption = 'Excluir item'
      TabOrder = 3
      OnClick = btnDelItemClick
    end
  end
  object Grid: TDBGrid
    Left = 0
    Top = 160
    Width = 740
    Height = 290
    Align = alClient
    DataSource = dsItens
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 450
    Width = 740
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object lblTotalCap: TLabel
      Left = 16
      Top = 22
      Width = 82
      Height = 15
      Caption = 'Total da nota:'
    end
    object lblTotal: TLabel
      Left = 104
      Top = 18
      Width = 60
      Height = 21
      Caption = 'R$ 0,00'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnNova: TButton
      Left = 516
      Top = 16
      Width = 100
      Height = 32
      Caption = 'Nova nota'
      TabOrder = 0
      OnClick = btnNovaClick
    end
    object btnSalvar: TButton
      Left = 622
      Top = 16
      Width = 100
      Height = 32
      Caption = 'Salvar nota'
      TabOrder = 1
      OnClick = btnSalvarClick
    end
  end
  object memItens: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    Left = 320
    Top = 220
  end
  object dsItens: TDataSource
    DataSet = memItens
    Left = 400
    Top = 220
  end
end
