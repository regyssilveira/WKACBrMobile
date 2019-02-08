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
    FCli: TRESTClient;
    FResp: IRESTResponse;
  public
    procedure InicializarRESTClient;

    procedure GetPDFFromNFCe(const ANumero, ASerie: integer);

    property Cli: TRESTClient read FCli write FCli;
    property Resp: IRESTResponse read FResp write FResp;
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
  FCli.Username := 'admin';
  FCli.Password := 'adminpass';
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
      FResp := Cli.doGET('/nfce/clientes', []);
      if FResp.HasError then
        raise Exception.Create(FResp.ResponseText);

      Result := FResp.BodyAsString;
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

  FResp := Cli.doGET('/nfce/produtos', []);
  if FResp.HasError then
    raise Exception.Create(FResp.ResponseText);

  DataSet.DisableControls;
  try
    tmpProdutos.LoadFromJSONArrayString(FResp.BodyAsString);
    tmpProdutos.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TDtmPrincipal.FDConnection1BeforeConnect(Sender: TObject);
begin
  FDConnection1.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'AppPedidos.sqlite')
end;


procedure TDtmPrincipal.GetPDFFromNFCe(const ANumero, ASerie: integer);
var
  PDFStream: TMemoryStream;
begin
  FResp := Cli.doGET('/nfce/nfce/', [ANumero.ToString, ASerie.ToString, 'PDF']);
  if Resp.HasError then
    raise Exception.Create(FResp.ResponseText);


  PDFStream := TMemoryStream.Create;
  try
    PDFStream.LoadFromStream(FResp.Body);
    PDFStream.Position := 0;


  finally
    PDFStream.DisposeOf;
  end;

end;


end.
