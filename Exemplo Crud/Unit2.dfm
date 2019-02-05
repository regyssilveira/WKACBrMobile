object MinhaWebModule: TMinhaWebModule
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  OnDestroy = WebModuleDestroy
  Actions = <>
  Height = 455
  Width = 670
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=C:\CursoNFCeACBrMobile\bin\database\DADOS_TESTE.FDB'
      'User_Name=sysdba'
      'Password=masterkey'
      'Server=localhost'
      'Port=3050'
      'CharacterSet=WIN1252'
      'DriverID=FB')
    LoginPrompt = False
    Left = 96
    Top = 64
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 320
    Top = 208
  end
end
