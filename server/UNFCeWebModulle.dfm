object NFCEWebModule: TNFCEWebModule
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <>
  Height = 325
  Width = 624
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=C:\CursoNFCeACBrMobile\bin\database\DADOS.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Protocol=TCPIP'
      'Server=localhost'
      'Port=3050'
      'CharacterSet=WIN1252'
      'DriverID=FB')
    LoginPrompt = False
    BeforeConnect = FDConnection1BeforeConnect
    Left = 72
    Top = 56
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 432
    Top = 56
  end
end
