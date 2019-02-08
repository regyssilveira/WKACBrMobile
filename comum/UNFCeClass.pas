unit UNFCeClass;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  MVCFramework.Serializer.Commons;

type
  [MVCNameCaseAttribute(ncLowerCase)]
  TNFCeItem = class
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
  TNFCe = class
  private
    FItens: TObjectList<TNFCeItem>;
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

    [MVCListOfAttribute(TNFCeItem)]
    property Itens: TObjectList<TNFCeItem> read FItens write FItens;
  end;

implementation

uses
  MVCFramework.DataSet.Utils,
  MVCFramework.Serializer.JsonDataObjects,
  JsonDataObjects;

{ TNFCe }

function TNFCe.AsJsonString: String;
var
  Serializar: TMVCJsonDataObjectsSerializer;
  JsonObj: TJSONObject;
begin
  Serializar := TMVCJsonDataObjectsSerializer.Create;
  JsonObj := TJSONObject.Create;
  try
    Serializar.ObjectToJSONObject(Self, JsonObj, stDefault, []);
    Result := JsonObj.ToJSON;
  finally
    Serializar.Free;
    JsonObj.Free;
  end;
end;

constructor TNFCe.Create;
begin
  inherited create;
  FItens := TObjectList<TNFCeItem>.Create;
end;

destructor TNFCe.Destroy;
begin
  FItens.Free;
  inherited;
end;

end.

