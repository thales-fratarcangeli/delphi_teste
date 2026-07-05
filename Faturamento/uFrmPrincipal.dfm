object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Faturamento'
  ClientHeight = 520
  ClientWidth = 840
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsMDIForm
  Menu = MainMenu
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  TextHeight = 15
  object pnlBolaIA: TPanel
    Left = 760
    Top = 420
    Width = 64
    Height = 64
    Anchors = [akRight, akBottom]
    BevelOuter = bvNone
    Caption = 'IA'
    Color = clHighlight
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -19
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    OnClick = pnlBolaIAClick
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 501
    Width = 840
    Height = 19
    Panels = <
      item
        Text = 'Usu'#225'rio: ...'
        Width = 300
      end
      item
        Text = 'Banco conectado'
        Width = 200
      end>
  end
  object MainMenu: TMainMenu
    Left = 40
    Top = 40
    object mnuCadastros: TMenuItem
      Caption = '&Cadastros'
      object mnuClientes: TMenuItem
        Caption = '&Clientes'
        OnClick = mnuClientesClick
      end
      object mnuProdutos: TMenuItem
        Caption = '&Produtos'
        OnClick = mnuProdutosClick
      end
      object mnuSep1: TMenuItem
        Caption = '-'
      end
      object mnuSair: TMenuItem
        Caption = 'Sa&ir'
        OnClick = mnuSairClick
      end
    end
    object mnuMovimento: TMenuItem
      Caption = '&Movimento'
      object mnuNotaFiscal: TMenuItem
        Caption = '&Nota Fiscal'
        OnClick = mnuNotaFiscalClick
      end
      object mnuPDV: TMenuItem
        Caption = 'PDV (Ponto de &Venda)'
        OnClick = mnuPDVClick
      end
    end
    object mnuPedidos: TMenuItem
      Caption = '&Pedidos'
      object mnuAprovarPedidos: TMenuItem
        Caption = '&Aprovar Pedidos'
        OnClick = mnuAprovarPedidosClick
      end
    end
    object mnuFiscal: TMenuItem
      Caption = '&Fiscal'
      object mnuPainelNFe: TMenuItem
        Caption = 'Painel de N&F-e'
        OnClick = mnuPainelNFeClick
      end
      object mnuConfigSEFAZ: TMenuItem
        Caption = 'Configura'#231#227'o &SEFAZ'
        OnClick = mnuConfigSEFAZClick
      end
    end
    object mnuRelatorios: TMenuItem
      Caption = '&Relat'#243'rios'
      object mnuCentralRel: TMenuItem
        Caption = '&Central de Relat'#243'rios'
        OnClick = mnuCentralRelClick
      end
    end
    object mnuAdmin: TMenuItem
      Caption = 'A&dministra'#231#227'o'
      object mnuPrivilegios: TMenuItem
        Caption = '&Privil'#233'gios por Perfil'
        OnClick = mnuPrivilegiosClick
      end
      object mnuRotinas: TMenuItem
        Caption = '&Rotinas (Jenkins)'
        OnClick = mnuRotinasClick
      end
    end
    object mnuExemplos: TMenuItem
      Caption = '&Exemplos (estudo)'
      object mnuClientesOO: TMenuItem
        Caption = 'Clientes (&OO + Thread)'
        OnClick = mnuClientesOOClick
      end
      object mnuRecursosLing: TMenuItem
        Caption = '&Recursos da linguagem'
        OnClick = mnuRecursosLingClick
      end
    end
    object mnuAjuda: TMenuItem
      Caption = '&Ajuda'
      object mnuSobre: TMenuItem
        Caption = '&Sobre'
        OnClick = mnuSobreClick
      end
    end
  end
end
