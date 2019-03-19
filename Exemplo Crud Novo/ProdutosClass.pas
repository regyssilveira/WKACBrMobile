unit ProdutosClass;

interface

uses
  MVCFramework.Serializer.Commons;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TProduto = class
  private
    FId: Integer;
    FGtin: string;
    FDescricao: string;
    FValorVenda: Double;
    FUnidade: string;
    FDataCriacao: TDateTime;
  public
    property Id: Integer read FId write FId;
    property Gtin: string read FGtin write FGtin;
    property Descricao: string read FDescricao write FDescricao;
    property ValorVenda: Double read FValorVenda write FValorVenda;
    property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;
    property Unidade: string read FUnidade write FUnidade;
  end;

implementation

end.
