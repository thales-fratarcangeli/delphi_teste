object FrmPermissoes: TFrmPermissoes
  Left = 0
  Top = 0
  Caption = 'Privil'#233'gios por Perfil'
  ClientHeight = 460
  ClientWidth = 560
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
    Width = 560
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblPerfil: TLabel
      Left = 16
      Top = 8
      Width = 33
      Height = 15
      Caption = 'Perfil:'
    end
    object cboPerfil: TComboBox
      Left = 16
      Top = 26
      Width = 300
      Height = 23
      Style = csDropDownList
      TabOrder = 0
      OnChange = cboPerfilChange
    end
    object btnSalvar: TButton
      Left = 440
      Top = 22
      Width = 100
      Height = 30
      Caption = 'Salvar'
      TabOrder = 1
      OnClick = btnSalvarClick
    end
  end
  object clbPermissoes: TCheckListBox
    Left = 0
    Top = 56
    Width = 560
    Height = 404
    Align = alClient
    ItemHeight = 19
    TabOrder = 1
  end
  object qryAux: TFDQuery
    Left = 360
    Top = 120
  end
end
