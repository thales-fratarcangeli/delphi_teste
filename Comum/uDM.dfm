object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 220
  Width = 320
  object Conn: TFDConnection
    LoginPrompt = False
    Left = 48
    Top = 32
  end
  object DrvFB: TFDPhysFBDriverLink
    Left = 48
    Top = 96
  end
  object WaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 48
    Top = 152
  end
end
