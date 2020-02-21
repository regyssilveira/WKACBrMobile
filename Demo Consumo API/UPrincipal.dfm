object FrmPrincipal: TFrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Demo Consumo API'
  ClientHeight = 510
  ClientWidth = 789
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 783
    Height = 504
    ActivePage = TabSheet4
    Align = alClient
    TabOrder = 0
    TabWidth = 150
    object TabSheet1: TTabSheet
      Caption = 'Produtos'
      object DBGrid1: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 102
        Width = 769
        Height = 371
        Align = alClient
        DataSource = DtsProdutos
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
      object PageControl2: TPageControl
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 769
        Height = 93
        ActivePage = TabSheet7
        Align = alTop
        TabOrder = 0
        object TabSheet5: TTabSheet
          Caption = 'Busca Normal'
          object Label2: TLabel
            Left = 10
            Top = 15
            Width = 33
            Height = 13
            Caption = 'C'#243'digo'
          end
          object EdtCodProduto: TEdit
            Left = 10
            Top = 31
            Width = 151
            Height = 21
            NumbersOnly = True
            TabOrder = 0
          end
          object BtnBuscaProduto: TButton
            Left = 167
            Top = 29
            Width = 75
            Height = 25
            Caption = 'Buscar'
            TabOrder = 1
            OnClick = BtnBuscaProdutoClick
          end
        end
        object TabSheet6: TTabSheet
          Caption = 'Busca Paginada'
          ImageIndex = 1
          object Label3: TLabel
            Left = 10
            Top = 15
            Width = 116
            Height = 13
            Caption = 'Quantidade de registros'
          end
          object BtnBuscaPagAnterior: TButton
            Left = 167
            Top = 29
            Width = 75
            Height = 25
            Caption = 'Anterior'
            TabOrder = 1
            OnClick = BtnBuscaPagAnteriorClick
          end
          object BtnBuscaPagProximo: TButton
            Left = 248
            Top = 29
            Width = 75
            Height = 25
            Caption = 'Proximo'
            TabOrder = 2
            OnClick = BtnBuscaPagProximoClick
          end
          object EdtQuantRegistros: TEdit
            Left = 10
            Top = 31
            Width = 151
            Height = 21
            NumbersOnly = True
            TabOrder = 0
            Text = '10'
          end
        end
        object TabSheet7: TTabSheet
          Caption = 'Busca com Like'
          ImageIndex = 2
          object Label4: TLabel
            Left = 15
            Top = 20
            Width = 46
            Height = 13
            Caption = 'Descri'#231#227'o'
          end
          object EdtProdutoDescr: TEdit
            Left = 15
            Top = 36
            Width = 151
            Height = 21
            TabOrder = 0
          end
          object BtnBuscaProdutoLike: TButton
            Left = 172
            Top = 34
            Width = 75
            Height = 25
            Caption = 'Buscar'
            TabOrder = 1
            OnClick = BtnBuscaProdutoLikeClick
          end
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Clientes'
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 775
        Height = 70
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 20
          Top = 20
          Width = 33
          Height = 13
          Caption = 'C'#243'digo'
        end
        object EdtCodCliente: TEdit
          Left = 20
          Top = 36
          Width = 151
          Height = 21
          NumbersOnly = True
          TabOrder = 0
        end
        object BtnBuscaCliente: TButton
          Left = 177
          Top = 34
          Width = 75
          Height = 25
          Caption = 'Buscar'
          TabOrder = 1
          OnClick = BtnBuscaClienteClick
        end
      end
      object DBGrid2: TDBGrid
        AlignWithMargins = True
        Left = 3
        Top = 73
        Width = 769
        Height = 400
        Align = alClient
        DataSource = DtsClientes
        TabOrder = 1
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Pedido'
      ImageIndex = 2
      object BtnEnviarPedidoString: TButton
        Left = 25
        Top = 40
        Width = 261
        Height = 31
        Caption = 'Enviar Pedido Teste (com string no body)'
        TabOrder = 0
        OnClick = BtnEnviarPedidoStringClick
      end
      object BtnEnviarPedidoObjeto: TButton
        Left = 25
        Top = 77
        Width = 261
        Height = 31
        Caption = 'Enviar Pedido Teste (com objeto)'
        TabOrder = 1
        OnClick = BtnEnviarPedidoObjetoClick
      end
    end
    object TabSheet4: TTabSheet
      Caption = 'Download'
      ImageIndex = 3
      object RbtTipoArquivo: TRadioGroup
        Left = 25
        Top = 30
        Width = 185
        Height = 105
        Caption = 'Tipo de Arquivo'
        ItemIndex = 0
        Items.Strings = (
          'PDF'
          'XML'
          'EscPOS')
        TabOrder = 0
      end
      object BtnSalvarArquivo: TButton
        Left = 255
        Top = 70
        Width = 176
        Height = 36
        Caption = 'Salvar'
        TabOrder = 1
        OnClick = BtnSalvarArquivoClick
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 405
    Top = 330
  end
  object tmpProdutos: TFDMemTable
    FetchOptions.AssignedValues = [evMode, evRecsSkip]
    FetchOptions.Mode = fmAll
    FetchOptions.RecsSkip = 10
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 392
    Top = 225
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
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 497
    Top = 226
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
  object DtsProdutos: TDataSource
    DataSet = tmpProdutos
    Left = 390
    Top = 270
  end
  object DtsClientes: TDataSource
    DataSet = tmpClientes
    Left = 495
    Top = 270
  end
end
