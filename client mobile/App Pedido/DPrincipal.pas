unit DPrincipal;

interface

uses
  MVCFramework.RESTClient,
  System.Threading,
  System.Permissions,

  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.FMXUI.Wait,
  Data.DB, FireDAC.Comp.Client, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.DApt, FireDAC.FMXUI.Login, FireDAC.FMXUI.Error,
  FireDAC.Comp.UI, FireDAC.Phys.SQLiteWrapper.Stat;

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
    FDGUIxLoginDialog1: TFDGUIxLoginDialog;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDGUIxErrorDialog1: TFDGUIxErrorDialog;
    FDPhysSQLiteDriverLink1: TFDPhysSQLiteDriverLink;
    procedure FDConnection1BeforeConnect(Sender: TObject);
    procedure tmpProdutosAfterOpen(DataSet: TDataSet);
    procedure tmpClientesAfterOpen(DataSet: TDataSet);
    procedure FDConnection1AfterConnect(Sender: TObject);
  private
    FCli: TRESTClient;
    FResp: IRESTResponse;
    function GetCli: TRESTClient;
  public
    procedure GetPDFFromPedido(const ANumero, ASerie: integer);

    property Cli: TRESTClient read GetCli;
    property Resp: IRESTResponse read FResp write FResp;
  end;

var
  DtmPrincipal: TDtmPrincipal;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  {$IFDEF ANDROID}
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Os,
  {$ELSE}
  WinApi.Windows,
  Winapi.ShellApi,
  {$ENDIF}

  System.IOUtils,
  MVCFramework.DataSet.Utils,
  UConfigClass,
  FMX.DialogService,
  FMX.Dialogs;

function TDtmPrincipal.GetCli: TRESTClient;
begin
  if Assigned(FCli) then
    FCli.DisposeOf;

  FCli := TRESTClient.Create(
    ConfigFile.IpServidor, ConfigFile.Porta
  );

  FCli.Username := 'admin';
  FCli.Password := 'adminpass';

  Result := FCli;
end;

procedure TDtmPrincipal.tmpClientesAfterOpen(DataSet: TDataSet);
var
  FutResponse: IFuture<string>;
begin
  FutResponse := TTask.Future<string>(
    function: string
    var
      Response: IRESTResponse;
    begin
      Response := Cli.doGET('/api/clientes', []);
      if Response.HasError then
        raise Exception.Create(Response.ResponseText);

      Result := Response.BodyAsString;
    end
  );

  DataSet.DisableControls;
  try
    tmpClientes.LoadFromJSONArrayString(FutResponse.Value);
    tmpClientes.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TDtmPrincipal.tmpProdutosAfterOpen(DataSet: TDataSet);
var
  FutResponse: IFuture<string>;
begin
  FutResponse := TTask.Future<string>(
    function: string
    var
      Response: IRESTResponse;
    begin
      Response := Cli.doGET('/api/produtos', []);
      if Response.HasError then
        raise Exception.Create(FResp.ResponseText);

      Result := Response.BodyAsString;
    end
  );

  DataSet.DisableControls;
  try
    tmpProdutos.LoadFromJSONArrayString(FutResponse.Value);
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
  FDConnection1.Params.Values['Database'] :=
    TPath.Combine(TPath.GetDocumentsPath, 'AppPedidos.sqlite');
end;

procedure TDtmPrincipal.GetPDFFromPedido(const ANumero, ASerie: integer);
var
  PDFStream: TMemoryStream;
  PathFilePDF: string;
  {$IFDEF ANDROID}
  Intent: JIntent;
  LFile: JFile;
  {$ENDIF}
  Response: IRESTResponse;
begin
  //caminho do arquivo baixado
  PathFilePDF := TPath.Combine(TPath.GetDownloadsPath, 'notafiscal.pdf');
  if TFile.Exists(PathFilePDF) then
    TFile.Delete(PathFilePDF);

  Response := Cli.doGET('/api/pedido', [ANumero.ToString, ASerie.ToString, 'PDF']);
  if Response.HasError then
    raise Exception.Create(FResp.ResponseText);

  // salvar arquivo pdf local
  PDFStream := TMemoryStream.Create;
  try
    PDFStream.LoadFromStream(Response.Body);
    PDFStream.Position := 0;

    PDFStream.SaveToFile(PathFilePDF);
  finally
    PDFStream.DisposeOf;
  end;

  // abrir pdf no editor padrão
  if TFile.Exists(PathFilePDF) then
  begin
    {$IFDEF ANDROID}
    // visualizar pdf
    LFile := TJFile.JavaClass.init(StringToJString(PathFilePDF));

    Intent := TJIntent.Create;
    Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
    Intent.setFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
    Intent.setDataAndType(TAndroidHelper.JFileToJURI(LFile), StringToJString('application/pdf'));

    // compartilhar
//      Intent := TJIntent.Create;
//      Intent.setAction(TJIntent.JavaClass.ACTION_MEDIA_SHARED);
//      Intent.setDataAndType(StrToJURI('file://' + PathFilePDF), StringToJString('application/pdf'));

    try
      TAndroidHelper.Activity.startActivity(Intent);
    except
    end;
    {$ELSE}
    ShellExecute(
      0,
      nil,
      PChar(PathFilePDF),
      nil,
      nil,
      SW_SHOWNOACTIVATE
    );
    {$ENDIF}
  end
  else
    raise Exception.Create('Arquivo PDF não encontrado!');
end;


end.
