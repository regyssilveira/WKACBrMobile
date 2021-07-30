unit UPedidoController;

interface

uses
  System.Classes,
  MVCFramework,
  MVCFramework.Commons,
  UBaseController;

type
  [MVCPath('/api')]
  TPedidoController = class(TBaseController)
  private
    procedure GetNFCePDF(ANumero: integer; ASerie: integer); overload;
    procedure GetNFCeXML(ANumero: integer; ASerie: integer); overload;
    procedure GetNFCeEscPOS(ANumero: integer; ASerie: integer); overload;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos;

    [MVCPath('/produtos/($AId)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProduto(AId: Integer);

    [MVCPath('/produtos/($AAtual)/($AQuantidade)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutosPaginado(AAtual, AQuantidade: integer);

    [MVCPath('/clientes')]
    [MVCHTTPMethod([httpGET])]
    procedure GetClientes;

    [MVCPath('/clientes/($Aid)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetCliente(Aid: Integer);

    [MVCPath('/pedido')]
    [MVCHTTPMethod([httpGET])]
    procedure GerarPedidoExemplo;

    [MVCPath('/pedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreatePedido;

    [MVCPath('/pedido/($ANumero)/($ASerie)/($ATipo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetDFe(ANumero: integer; ASerie: integer; ATipo: string);
  end;


implementation

uses
  Data.DB,

  ACBrValidador,

  FireDAC.Comp.Client,

  System.NetEncoding,
  System.SysUtils,
  System.StrUtils,

  UDatamoduleInterface,
  MVCFramework.Logger,
  UPedidoClass,

  dfe.service;

{ TNFCeController }

procedure TPedidoController.Index;
begin
  ContentType := TMVCMediaType.TEXT_HTML;
  Render(
    '<h1>curso API NFC-e</h1>' +
    '<p>Curso de NFC-e com mobile utilizando DMVC framework e ACBr</p>'
  );
end;

procedure TPedidoController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  inherited;

end;

procedure TPedidoController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  inherited;

end;

procedure TPedidoController.GetClientes;
var
  TmpDataset: TDataSet;
begin
  TmpDataset := Service.GetClientes;
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.NotFound, 'Não existe nenhum cliente cadastrado na base de dados')
  else
    Render(TmpDataset);
end;

procedure TPedidoController.GetCliente(Aid: Integer);
var
  TmpDataset: TDataSet;
begin
  TmpDataset := Service.GetClienteById(Aid);
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.NotFound, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset);
end;

procedure TPedidoController.GetProdutos;
var
  TmpDataset: TDataSet;
const
  QRY_STRLIKE = 'like';
begin
  if Context.Request.QueryStringParamExists(QRY_STRLIKE) then
    TmpDataset := Service.GetProdutoWhere(Context.Request.QueryStringParam(QRY_STRLIKE))
  else
    TmpDataset := Service.GetProdutos;

  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.NotFound, 'Não existe nenhum produto cadastrado na base de dados')
  else
    Render(TmpDataset);
end;

procedure TPedidoController.GetProdutosPaginado(AAtual, AQuantidade: integer);
var
  TmpDataset: TFDQuery;
begin
  TmpDataset := Service.GetProdutosPaginado(AAtual, AQuantidade);
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.NotFound, 'Não existe nenhum produto cadastrado na base de dados')
  else
    Render(TmpDataset);
end;

procedure TPedidoController.GetProduto(AId: Integer);
var
  TmpDataset: TDataSet;
begin
  TmpDataset := Service.GetProdutoById(AId);
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.NotFound, Format('Não existe produto cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset);
end;

procedure TPedidoController.GetDFe(ANumero, ASerie: integer; ATipo: string);
begin
  if ATipo.ToUpper = 'XML' then
    Self.GetNFCeXML(Anumero, ASerie)
  else
  if ATipo.ToUpper = 'PDF' then
    Self.GetNFCePDF(Anumero, ASerie)
  else
  if ATipo.ToUpper = 'ESCPOS' then
    Self.GetNFCeEscPOS(Anumero, ASerie)
  else
    raise Exception.Create('tipo de saida desconhecida');
end;

procedure TPedidoController.GetNFCeXML(ANumero, ASerie: integer);
begin
  ContentType := TMVCMediaType.APPLICATION_XML;
  Render(Datamodule.GerarXML(ANumero, ASerie));
end;

procedure TPedidoController.GetNFCePDF(ANumero, ASerie: integer);
var
  PathPDF: string;
  StreamPDF: TMemoryStream;
begin
  ContentType := TMVCMediaType.APPLICATION_PDF;

  PathPDF := Datamodule.GerarPDF(ANumero, ASerie);

  StreamPDF := TMemoryStream.Create;
  try
    StreamPDF.LoadFromFile(PathPDF);
    Render(StreamPDF);
  except
    on E: Exception do
    begin
      if Assigned(StreamPDF) then
        StreamPDF.DisposeOf;
    end;
  end;
end;

procedure TPedidoController.GetNFCeEscPOS(ANumero, ASerie: integer);
var
  PathArqEscPOS: string;
  StreamArqEscPOS: TMemoryStream;
begin
  ContentType := TMVCMediaType.TEXT_PLAIN;

  PathArqEscPOS := Datamodule.GerarEscPOS(ANumero, ASerie);

  StreamArqEscPOS := TMemoryStream.Create;
  try
    StreamArqEscPOS.LoadFromFile(PathArqEscPOS);
    Render(StreamArqEscPOS);
  except
    on E: Exception do
    begin
      if Assigned(StreamArqEscPOS) then
        StreamArqEscPOS.Free;
    end;
  end;
end;

procedure TPedidoController.CreatePedido;
var
  oPedido: TPedido;
  StrRetorno: string;
begin
  try
    oPedido := Context.Request.BodyAs<TPedido>;
    try
      if oPedido.Itens.Count <= 0 then
        raise Exception.Create('Nenhum item foi informado!');

      Datamodule.PreencherDFe(oPedido);
      StrRetorno := Datamodule.Enviar;

      Render(StrRetorno);
    finally
      oPedido.DisposeOf;
    end;
  except
    on E: Exception do
    begin
      Render(HTTP_STATUS.InternalServerError, E.Message);
    end;
  end;
end;

procedure TPedidoController.GerarPedidoExemplo;
var
  I: Integer;
  oPedido: TPedido;
  oPedidoItem: TPedidoItem;
begin
  oPedido := TPedido.Create;

  oPedido.cpf  := '';
  oPedido.Nome := '';

  for I := 1 to 5 do
  begin
    oPedidoItem := TPedidoItem.Create;
    oPedidoItem.Id         := I;
    oPedidoItem.Descricao  := 'Descricao teste ' + I.ToString;
    oPedidoItem.Valor      := I * 10;
    oPedidoItem.Quantidade := I;

    oPedido.Itens.Add(oPedidoItem);
  end;

  Render(oPedido);
end;


end.
