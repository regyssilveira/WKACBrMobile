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
    procedure FDConnection1AfterConnect(Sender: TObject);
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
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,

  System.IOUtils, MVCFramework.DataSet.Utils, UConfigClass,
  FMX.DialogService.Async;

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

procedure TDtmPrincipal.FDConnection1AfterConnect(Sender: TObject);
var
  Tabelas: TStringList;
begin
  Tabelas := TStringList.Create;
  try
    FDConnection1.GetTableNames('', '', '', Tabelas);

    Tabelas.CaseSensitive := False;

    if Tabelas.IndexOf('produtos') < 0 then
    begin
      FDConnection1.ExecSQL(
        'create table produtos (   ' + sLineBreak +
        '  ID integer not null,    ' + sLineBreak +
        '  GTIN varchar(13),       ' + sLineBreak +
        '  DESCRICAO varchar(50),  ' + sLineBreak +
        '  VL_VENDA numeric(15,2), ' + sLineBreak +
        '  DT_CRIACAO DATE,        ' + sLineBreak +
        '  DT_ALTERACAO DATE,      ' + sLineBreak +
        '  UN varchar(3),          ' + sLineBreak +
        '                          ' + sLineBreak +
        '  primary key (id)        ' + sLineBreak +
        ')                         '
      );
    end;

    if Tabelas.IndexOf('clientes') < 0 then
    begin
      FDConnection1.ExecSQL(
        'create table clientes ( ' + sLineBreak +
        '  id integer not null,  ' + sLineBreak +
        '  nome varchar(100),    ' + sLineBreak +
        '  cpf varchar(15),      ' + sLineBreak +
        '                        ' + sLineBreak +
        '  primary key (id)      ' + sLineBreak +
        ')                       '
      );
    end;
  finally
    Tabelas.DisposeOf;
  end;
end;

procedure TDtmPrincipal.FDConnection1BeforeConnect(Sender: TObject);
begin
  FDConnection1.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'AppPedidos.sqlite');
end;


procedure TDtmPrincipal.GetPDFFromNFCe(const ANumero, ASerie: integer);
var
  PDFStream: TMemoryStream;
  PathFilePDF: string;
  Intent: JIntent;
  URIArquivo: JParcelable;
begin
  FResp := Cli.doGET('/nfce/nfce', [ANumero.ToString, ASerie.ToString, 'PDF']);
  if Resp.HasError then
    raise Exception.Create(FResp.ResponseText);

  //caminho do arquivo baixado
  PathFilePDF := TPath.Combine(
    TPath.GetSharedDocumentsPath,
    Format('nf%9.9d%3.3d.pdf', [ANumero, ASerie])
  );
  if FileExists(PathFilePDF) then
    DeleteFile(PathFilePDF);

  // salvar arquivo pdf local
  PDFStream := TMemoryStream.Create;
  try
    PDFStream.LoadFromStream(FResp.Body);
    PDFStream.Position := 0;
    PDFStream.SaveToFile(PathFilePDF);

//    TDialogServiceAsync.ShowMessage(
//      'Arquivo pdf salvo em:' + sLineBreak +
//      PathFilePDF
//    );

    // abrir pdf no editor padrão
    if FileExists(PathFilePDF) then
    begin
      URIArquivo := JParcelable(
        TJNet_Uri.JavaClass.fromFile(
          TJFile.JavaClass.init(StringToJString(PathFilePDF))
        )
      );

      Intent := TJIntent.Create;
      Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
      Intent.setType(StringToJString('application/pdf'));
      Intent.putExtra(TJIntent.JavaClass.EXTRA_STREAM, URIArquivo);
      try
        TAndroidHelper.Activity.startActivity(Intent);
      except
      end;
    end
    else
      raise Exception.Create('Arquivo PDF não encontrado!');
  finally
    PDFStream.DisposeOf;
  end;
end;


end.
