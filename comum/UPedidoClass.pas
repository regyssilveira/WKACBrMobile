unit UPedidoClass;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,

  MVCFramework.Serializer.Commons;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TPedidoItem = class
  private
    FValor: double;
    FDescricao: string;
    FId: Integer;
    FQuantidade: integer;
  public
    property Id: Integer read FId write FId;
    property Descricao: string read FDescricao write FDescricao;
    property Valor: double read FValor write FValor;
    property Quantidade: integer read FQuantidade write FQuantidade;
  end;

  [MVCNameCaseAttribute(ncLowerCase)]
  TPedido = class
  private
    FItens: TObjectList<TPedidoItem>;
    Fcpf: string;
    FNome: string;
    FNumero: integer;
    FSerie: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    function AsJsonString: String;

    property Numero: integer read FNumero write FNumero;
    property Serie: Integer read FSerie write FSerie;
    property cpf: string read Fcpf write Fcpf;
    property Nome: string read FNome write FNome;
    property Itens: TObjectList<TPedidoItem> read FItens write FItens;
  end;

implementation

uses
  MVCFramework.DataSet.Utils,
  MVCFramework.Serializer.JsonDataObjects,
  JsonDataObjects;

{ TPedido }

function TPedido.AsJsonString: String;
var
  Serializar: TMVCJsonDataObjectsSerializer;
  JsonObj: TJSONObject;
begin
  Serializar := TMVCJsonDataObjectsSerializer.Create;
  JsonObj    := TJSONObject.Create;
  try
    Serializar.ObjectToJSONObject(Self, JsonObj, stDefault, []);
    Result := JsonObj.ToJSON;
  finally
    Serializar.Free;
    JsonObj.Free;
  end;
end;

constructor TPedido.Create;
begin
  inherited create;
  FItens := TObjectList<TPedidoItem>.Create;
end;

destructor TPedido.Destroy;
begin
  FItens.DisposeOf;
  inherited;
end;

end.

