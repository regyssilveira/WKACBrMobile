unit DPrincipal;

interface

uses
  MVCFramework.RESTClient,
  System.Threading,

  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.DApt;

type
  TDtmPrincipal = class(TDataModule)
    FDConnection1: TFDConnection;
    tmpProdutos: TFDMemTable;
    tmpProdutosid: TIntegerField;
    tmpProdutosgtin: TStringField;
    tmpProdutosdescricao: TStringField;
    tmpProdutosvl_venda: TFloatField;
    tmpProdutosdt_criacao: TDateField;
    tmpProdutosun: TStringField;
    tmpClientes: TFDMemTable;
    tmpClientesid: TIntegerField;
    tmpClientesnome: TStringField;
    tmpClientescpf: TStringField;
    qryProdutos: TFDQuery;
    qryClientes: TFDQuery;
    qryProdutosID: TIntegerField;
    qryProdutosGTIN: TStringField;
    qryProdutosDESCRICAO: TStringField;
    qryProdutosVL_VENDA: TBCDField;
    qryProdutosDT_CRIACAO: TDateField;
    qryProdutosUN: TStringField;
    qryClientesid: TIntegerField;
    qryClientesnome: TStringField;
    qryClientescpf: TStringField;
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure tmpProdutosAfterOpen(DataSet: TDataSet);
    procedure tmpClientesAfterOpen(DataSet: TDataSet);
  private
    FResponse: IRESTResponse;
    FCli: TRESTClient;
  public
    procedure InicializarRESTClient;

    property Cli: TRESTClient read FCli write FCli;
  end;

var
  DtmPrincipal: TDtmPrincipal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  System.IOUtils, MVCFramework.DataSet.Utils, UConfigClass;

procedure TDtmPrincipal.InicializarRESTClient;
begin
  if Assigned(FCli) then
    FCli.DisposeOf;

  FCli := TRESTClient.Create(
    ConfigFile.IpServidor, ConfigFile.Porta
  );
end;

procedure TDtmPrincipal.tmpClientesAfterOpen(DataSet: TDataSet);
var
  FutResponse: IFuture<string>;
begin
  //consumo assincrono
  InicializarRESTClient;

  FutResponse := TTask.Future<string>(
    function: string
    begin
      FResponse := Cli.doGET('/nfce/clientes', []);
      if FResponse.HasError then
        raise Exception.Create(FResponse.ResponseText);

      Result := FResponse.BodyAsString;
    end);

  DataSet.DisableControls;
  try
    tmpClientes.LoadFromJSONArrayString(FutResponse.Value);
    tmpClientes.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TDtmPrincipal.tmpProdutosAfterOpen(DataSet: TDataSet);
begin
  // comsumo sincrono
  InicializarRESTClient;

  FResponse := Cli.doGET('/nfce/produtos', []);
  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText);

  DataSet.DisableControls;
  try
    tmpProdutos.LoadFromJSONArrayString(FResponse.BodyAsString);
    tmpProdutos.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TDtmPrincipal.FDConnection1BeforeConnect(Sender: TObject);
begin
  FDConnection1.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'AppPedidos.sqlite')
end;

end.
