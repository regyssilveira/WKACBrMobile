object DtmPrincipal: TDtmPrincipal
  OldCreateOrder = False
  Height = 302
  Width = 528
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=C:\Users\regys\Documents\AppPedidos.sqlite'
      'DriverID=SQLite')
    ConnectedStoredUsage = []
    LoginPrompt = False
    AfterConnect = FDConnection1AfterConnect
    BeforeConnect = FDConnection1BeforeConnect
    Left = 87
    Top = 64
  end
  object tmpProdutos: TFDMemTable
    AfterOpen = tmpProdutosAfterOpen
    FetchOptions.AssignedValues = [evMode, evRecsSkip]
    FetchOptions.Mode = fmAll
    FetchOptions.RecsSkip = 10
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 77
    Top = 155
    object tmpProdutosid: TIntegerField
      FieldName = 'id'
    end
    object tmpProdutosgtin: TStringField
      FieldName = 'gtin'
      Size = 14
    end
    object tmpProdutosdescricao: TStringField
      FieldName = 'descricao'
      Size = 50
    end
    object tmpProdutosvl_venda: TFloatField
      FieldName = 'vl_venda'
    end
    object tmpProdutosdt_criacao: TDateField
      FieldName = 'dt_criacao'
    end
    object tmpProdutosun: TStringField
      FieldName = 'un'
      Size = 3
    end
  end
  object tmpClientes: TFDMemTable
    AfterOpen = tmpClientesAfterOpen
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 147
    Top = 154
    object tmpClientesid: TIntegerField
      FieldName = 'id'
    end
    object tmpClientesnome: TStringField
      FieldName = 'nome'
      Size = 50
    end
    object tmpClientescpf: TStringField
      FieldName = 'cpf'
      Size = 11
    end
  end
  object qryProdutos: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from produtos')
    Left = 178
    Top = 64
    object qryProdutosID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      Required = True
    end
    object qryProdutosGTIN: TStringField
      FieldName = 'GTIN'
      Origin = 'GTIN'
      Size = 13
    end
    object qryProdutosDESCRICAO: TStringField
      FieldName = 'DESCRICAO'
      Origin = 'DESCRICAO'
      Size = 50
    end
    object qryProdutosVL_VENDA: TBCDField
      FieldName = 'VL_VENDA'
      Origin = 'VL_VENDA'
      Precision = 15
      Size = 2
    end
    object qryProdutosDT_CRIACAO: TDateField
      FieldName = 'DT_CRIACAO'
      Origin = 'DT_CRIACAO'
    end
    object qryProdutosUN: TStringField
      FieldName = 'UN'
      Origin = 'UN'
      Size = 3
    end
  end
  object qryClientes: TFDQuery
    Connection = FDConnection1
    SQL.Strings = (
      'select * from clientes')
    Left = 253
    Top = 65
    object qryClientesid: TIntegerField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object qryClientesnome: TStringField
      FieldName = 'nome'
      Origin = 'nome'
      Size = 100
    end
    object qryClientescpf: TStringField
      FieldName = 'cpf'
      Origin = 'cpf'
      Size = 15
    end
  end
  object FDGUIxLoginDialog1: TFDGUIxLoginDialog
    Provider = 'FMX'
    Left = 410
    Top = 40
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'FMX'
    Left = 410
    Top = 90
  end
  object FDGUIxErrorDialog1: TFDGUIxErrorDialog
    Provider = 'FMX'
    Left = 410
    Top = 140
  end
  object FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink
    Left = 410
    Top = 190
  end
end
