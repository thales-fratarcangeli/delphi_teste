object FrmClientesOO: TFrmClientesOO
  Left = 0
  Top = 0
  Caption = 'Clientes (vers'#227'o Orientada a Objetos - estudo)'
  ClientHeight = 420
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
    object btnAtualizar: TButton
      Left = 12
      Top = 9
      Width = 100
      Height = 30
      Caption = 'Atualizar'
      TabOrder = 0
      OnClick = btnAtualizarClick
    end
    object btnNovo: TButton
      Left = 118
      Top = 9
      Width = 100
      Height = 30
      Caption = 'Novo'
      TabOrder = 1
      OnClick = btnNovoClick
    end
    object btnExcluir: TButton
      Left = 224
      Top = 9
      Width = 100
      Height = 30
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnProcessar: TButton
      Left = 470
      Top = 9
      Width = 198
      Height = 30
      Caption = 'Processar em segundo plano'
      TabOrder = 3
      OnClick = btnProcessarClick
    end
  end
  object Lista: TListView
    Left = 0
    Top = 48
    Width = 680
    Height = 350
    Align = alClient
    Columns = <
      item
        Caption = 'Id'
        Width = 60
      end
      item
        Caption = 'Nome'
        Width = 320
      end
      item
        Caption = 'Cidade'
        Width = 200
      end
      item
        Caption = 'UF'
        Width = 60
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object Progresso: TProgressBar
    Left = 0
    Top = 398
    Width = 680
    Height = 22
    Align = alBottom
    TabOrder = 2
  end
end
