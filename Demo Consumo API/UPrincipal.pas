unit UPrincipal;

interface

uses
  MVCFramework.RESTClient,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Vcl.Grids, Vcl.DBGrids;

type
  TFrmPrincipal = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    RbtTipoArquivo: TRadioGroup;
    BtnSalvarArquivo: TButton;
    SaveDialog1: TSaveDialog;
    DBGrid1: TDBGrid;
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
    DtsProdutos: TDataSource;
    DtsClientes: TDataSource;
    Panel2: TPanel;
    DBGrid2: TDBGrid;
    Label1: TLabel;
    EdtCodCliente: TEdit;
    BtnBuscaCliente: TButton;
    PageControl2: TPageControl;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    Label2: TLabel;
    EdtCodProduto: TEdit;
    BtnBuscaProduto: TButton;
    BtnBuscaPagAnterior: TButton;
    BtnBuscaPagProximo: TButton;
    Label3: TLabel;
    EdtQuantRegistros: TEdit;
    BtnEnviarPedidoString: TButton;
    BtnEnviarPedidoObjeto: TButton;
    procedure BtnSalvarArquivoClick(Sender: TObject);
    procedure BtnBuscaClienteClick(Sender: TObject);
    procedure BtnBuscaProdutoClick(Sender: TObject);
    procedure BtnBuscaPagAnteriorClick(Sender: TObject);
    procedure BtnBuscaPagProximoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnEnviarPedidoStringClick(Sender: TObject);
    procedure BtnEnviarPedidoObjetoClick(Sender: TObject);
  private
    FRestClient: TRESTClient;
    FResponse: IRESTResponse;
    FAtual: Integer;

    function GetRestClient: TRestClient;
  public
    property RESTClient: TRestClient read GetRestClient;
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  MVCFramework.DataSet.Utils, UNFCeClass;

{$R *.dfm}

{ TFrmPrincipal }

function TFrmPrincipal.GetRestClient: TRestClient;
begin
  if Assigned(FRestClient) then
    FRestClient.Free;

  FRestClient := TRESTClient.Create('localhost', 8080);
  FRestClient.Username := 'admin';
  FRestClient.Password := 'adminpass';

  Result := FRestClient;
end;


procedure TFrmPrincipal.BtnBuscaClienteClick(Sender: TObject);
begin
  if Trim(EdtCodCliente.Text).IsEmpty then
    FResponse := RESTClient.doGET('/nfce/clientes', [])
  else
    FResponse := RESTClient.doGET('/nfce/clientes', [EdtCodCliente.Text]);

  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText);

  tmpClientes.Close;
  tmpClientes.CreateDataSet;

  tmpClientes.DisableControls;
  try
    tmpClientes.LoadFromJSONArrayString(FResponse.BodyAsString);
  finally
    tmpClientes.EnableControls;
  end;
end;

procedure TFrmPrincipal.BtnBuscaPagAnteriorClick(Sender: TObject);
begin
  if Trim(EdtQuantRegistros.Text).IsEmpty then
    raise Exception.Create('Informe a quantidade de registros');

  FAtual := FAtual - StrToInt(EdtQuantRegistros.Text);
  if FAtual <= 0 then
    FAtual := 0;

  FResponse := RESTClient.doGET('/nfce/produtos', [FAtual.ToString , EdtQuantRegistros.Text]);
  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText);

  tmpProdutos.Close;
  tmpProdutos.CreateDataSet;
  tmpProdutos.DisableControls;
  try
    tmpProdutos.LoadFromJSONArrayString(FResponse.BodyAsString);
  finally
    tmpProdutos.EnableControls;
  end;
end;

procedure TFrmPrincipal.BtnBuscaPagProximoClick(Sender: TObject);
begin
  if Trim(EdtQuantRegistros.Text).IsEmpty then
    raise Exception.Create('Informe a quantidade de registros');

  FAtual := FAtual + StrToInt(EdtQuantRegistros.Text);

  FResponse := RESTClient.doGET('/nfce/produtos', [FAtual.ToString, EdtQuantRegistros.Text]);
  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText);

  tmpProdutos.Close;
  tmpProdutos.CreateDataSet;
  tmpProdutos.DisableControls;
  try
    tmpProdutos.LoadFromJSONArrayString(FResponse.BodyAsString);
  finally
    tmpProdutos.EnableControls;
  end;
end;

procedure TFrmPrincipal.BtnBuscaProdutoClick(Sender: TObject);
begin
  if Trim(EdtCodProduto.Text).IsEmpty then
    FResponse := RESTClient.doGET('/nfce/produtos', [])
  else
    FResponse := RESTClient.doGET('/nfce/produtos', [EdtCodProduto.Text]);

  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText);

  tmpProdutos.Close;
  tmpProdutos.CreateDataSet;
  tmpProdutos.DisableControls;
  try
    tmpProdutos.LoadFromJSONArrayString(FResponse.BodyAsString);
  finally
    tmpProdutos.EnableControls;
  end;
end;

procedure TFrmPrincipal.BtnEnviarPedidoObjetoClick(Sender: TObject);
var
  OPedido: TNFCe;
  OPedidoItem: TNFCeItem;
  I: Integer;
begin
  OPedido := TNFCe.Create;
  try
    OPedido.cpf  := '';
    OPedido.Nome := '';

    for I := 1 to 5 do
    begin
      OPedidoItem := TNFCeItem.Create;
      OPedidoItem.Id         := I;
      OPedidoItem.Descricao  := 'Descricao do item ' + I.ToString;
      OPedidoItem.Valor      := I;
      OPedidoItem.Quantidade := I;

      OPedido.Itens.Add(OPedidoItem);
    end;

    FResponse := RESTClient
                    .Resource('/nfce/nfce')
                    .doPOST<TNFCe>(OPedido, False);

    if FResponse.HasError then
      raise Exception.Create(FResponse.ResponseText)
    else
      ShowMessage('Pedido incluido com sucesso!');
  finally
    OPedido.Free;
  end;
end;

procedure TFrmPrincipal.BtnEnviarPedidoStringClick(Sender: TObject);
var
  OPedido: TNFCe;
  OPedidoItem: TNFCeItem;
  I: Integer;
begin
  OPedido := TNFCe.Create;
  try
    OPedido.cpf  := '';
    OPedido.Nome := '';

    for I := 1 to 5 do
    begin
      OPedidoItem := TNFCeItem.Create;
      OPedidoItem.Id         := I;
      OPedidoItem.Descricao  := 'Descricao do item ' + I.ToString;
      OPedidoItem.Valor      := I;
      OPedidoItem.Quantidade := I;

      OPedido.Itens.Add(OPedidoItem);
    end;

    FResponse := RESTClient.doPOST('/nfce/nfce', [], OPedido.AsJsonString);
    if FResponse.HasError then
      raise Exception.Create(FResponse.ResponseText)
    else
      ShowMessage('Pedido incluido com sucesso!');
  finally
    OPedido.Free;
  end;
end;

procedure TFrmPrincipal.BtnSalvarArquivoClick(Sender: TObject);
var
  Tipo: string;
  StreamArquivo: TMemoryStream;
begin
  case RbtTipoArquivo.ItemIndex of
    0:
      begin
        Tipo := 'PDF';

        SaveDialog1.DefaultExt := '.pdf';
        SaveDialog1.FileName   := 'ArquivoPDF';
        SaveDialog1.Filter     := 'arquivos pdf|*.pdf';
        SaveDialog1.Title      := 'Salvar arquivo PDF';
      end;

    1:
      begin
        Tipo := 'XML';

        SaveDialog1.DefaultExt := '.xml';
        SaveDialog1.FileName   := 'ArquivoXML';
        SaveDialog1.Filter     := 'arquivos xml|*.xml';
        SaveDialog1.Title      := 'Salvar arquivo XML';
      end;

    2:
      begin
        Tipo := 'ESCPOS';

        SaveDialog1.DefaultExt := '.txt';
        SaveDialog1.FileName   := 'ArquivoEscPOS';
        SaveDialog1.Filter     := 'arquivos txt|*.txt';
        SaveDialog1.Title      := 'Salvar arquivo EscPOS';
      end;
  end;

  if SaveDialog1.Execute then
  begin
    FResponse := RESTClient.doGET('/nfce/nfce', ['1', '1', Tipo]);
    if FResponse.HasError then
      raise Exception.Create(FResponse.ResponseText);

    StreamArquivo := TMemoryStream.Create;
    try
      StreamArquivo.LoadFromStream(FResponse.Body);
      StreamArquivo.Position := 0;

      StreamArquivo.SaveToFile(SaveDialog1.FileName);

      ShowMessage('Arquivo salvo com sucesso!');
    finally
      StreamArquivo.Free;
    end;
  end;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FAtual := 0;
end;

end.
