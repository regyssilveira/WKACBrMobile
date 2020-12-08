unit UNFCeController;

interface

uses
  System.Classes,
  MVCFramework,
  MVCFramework.Commons,
  UBaseController;

type
  [MVCPath('/nfce')]
  TNFCeController = class(TBaseController)
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

    [MVCPath('/nfce')]
    [MVCHTTPMethod([httpGET])]
    procedure GerarNFCeExemplo;

    [MVCPath('/nfce')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateNFCe;

    [MVCPath('/nfce/($ANumero)/($ASerie)/($ATipo)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetNFCe(ANumero: integer; ASerie: integer; ATipo: string);
  end;


implementation

uses
  Data.DB,
  System.NetEncoding,
  ACBrValidador,
  System.SysUtils,
  System.StrUtils,
  MVCFramework.Logger,
  UConfigClass,
  UNFCeClass,
  DNFCe,
  FireDAC.Comp.Client, DSAT, dfe.service;

{ TNFCeController }

procedure TNFCeController.Index;
begin
  ContentType := TMVCMediaType.TEXT_HTML;
  Render(
    '<h1>curso API NFC-e</h1>' +
    '<p>Curso de NFC-e com mobile utilizando DMVC framework e ACBr</p>'
  );
end;

procedure TNFCeController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  inherited;

end;

procedure TNFCeController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  inherited;

end;

procedure TNFCeController.GetClientes;
var
  TmpDataset: TDataSet;
begin
  TmpDataset := Service.GetClientes;
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.InternalServerError, 'Não existe nenhum cliente cadastrado na base de dados')
  else
    Render(TmpDataset);
end;

procedure TNFCeController.GetCliente(Aid: Integer);
var
  TmpDataset: TDataSet;
begin
  TmpDataset := Service.GetClienteById(Aid);
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.InternalServerError, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset);
end;

procedure TNFCeController.GetProdutos;
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
    Render(HTTP_STATUS.InternalServerError, 'Não existe nenhum produto cadastrado na base de dados')
  else
    Render(TmpDataset);
end;

procedure TNFCeController.GetProdutosPaginado(AAtual, AQuantidade: integer);
var
  TmpDataset: TFDQuery;
begin
  TmpDataset := Service.GetProdutosPaginado(AAtual, AQuantidade);
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.InternalServerError, 'Não existe nenhum produto cadastrado na base de dados')
  else
    Render(TmpDataset);
end;

procedure TNFCeController.GetProduto(AId: Integer);
var
  TmpDataset: TDataSet;
begin
  TmpDataset := Service.GetProdutoById(AId);
  if TmpDataset.IsEmpty then
    Render(HTTP_STATUS.InternalServerError, Format('Não existe produto cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset);
end;

procedure TNFCeController.GetNFCe(ANumero, ASerie: integer; ATipo: string);
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

procedure TNFCeController.GetNFCeXML(ANumero, ASerie: integer);
var
  DmNFCe: TdtmNFCe;
  DmSAT: TDtmSAT;
begin
  case ConfigServer.Tipo of
    tpNFCe:
      begin
        DmNFCe := TdtmNFCe.Create(nil);
        try
          ContentType := TMVCMediaType.APPLICATION_XML;
          Render(DmNFCe.GerarXML(ANumero, ASerie));
        finally
          DmNFCe.Free;
        end;
      end;

    tpSAT:
      begin
        DmSAT := TDtmSAT.Create(nil);
        try
          ContentType := TMVCMediaType.APPLICATION_XML;
          Render(DmSAT.GerarXML(ANumero, ASerie));
        finally
          DmSAT.Free;
        end;
      end;
  end;
end;

procedure TNFCeController.GetNFCePDF(ANumero, ASerie: integer);
var
  DmNFCe: TdtmNFCe;
  DmSAT: TDtmSAT;
  PathPDF: string;
  StreamPDF: TMemoryStream;
begin
  case ConfigServer.Tipo of
    tpNFCe:
      begin
        DmNFCe := TdtmNFCe.Create(nil);
        try
          PathPDF := DmNFCe.GerarPDF(ANumero, ASerie);

          StreamPDF := TMemoryStream.Create;
          try
            StreamPDF.LoadFromFile(PathPDF);

            ContentType := TMVCMediaType.APPLICATION_PDF;
            Render(StreamPDF);
          except
            on E: Exception do
            begin
              if Assigned(StreamPDF) then
                StreamPDF.Free;
            end;
          end;
        finally
          DmNFCe.Free;
        end;
      end;

    tpSAT:
      begin
        DmSAT := TDtmSAT.Create(nil);
        try
          PathPDF := DmSAT.GerarPDF(ANumero, ASerie);

          StreamPDF := TMemoryStream.Create;
          try
            StreamPDF.LoadFromFile(PathPDF);

            ContentType := TMVCMediaType.APPLICATION_PDF;
            Render(StreamPDF);
          except
            on E: Exception do
            begin
              if Assigned(StreamPDF) then
                StreamPDF.Free;
            end;
          end;
        finally
          DmSAT.Free;
        end;
      end;
  end;
end;

procedure TNFCeController.GetNFCeEscPOS(ANumero, ASerie: integer);
var
  DmNFCe: TdtmNFCe;
  DmSAT: TDtmSAT;
  PathArqEscPOS: string;
  StreamArqEscPOS: TMemoryStream;
begin
  case ConfigServer.Tipo of
    tpNFCe:
      begin
        DmNFCe := TdtmNFCe.Create(nil);
        try
          PathArqEscPOS := DmNFCe.GerarEscPOS(ANumero, ASerie);

          StreamArqEscPOS := TMemoryStream.Create;
          try
            StreamArqEscPOS.LoadFromFile(PathArqEscPOS);

            ContentType := TMVCMediaType.TEXT_PLAIN;
            Render(StreamArqEscPOS);
          except
            on E: Exception do
            begin
              if Assigned(StreamArqEscPOS) then
                StreamArqEscPOS.Free;
            end;
          end;
        finally
          DmNFCe.Free;
        end;
      end;

    tpSAT:
      begin
        DmSAT := TDtmSAT.Create(nil);
        try
          PathArqEscPOS := DmSAT.GerarEscPOS(ANumero, ASerie);

          StreamArqEscPOS := TMemoryStream.Create;
          try
            StreamArqEscPOS.LoadFromFile(PathArqEscPOS);

            ContentType := TMVCMediaType.TEXT_PLAIN;
            Render(StreamArqEscPOS);
          except
            on E: Exception do
            begin
              if Assigned(StreamArqEscPOS) then
                StreamArqEscPOS.Free;
            end;
          end;
        finally
          DmSAT.Free;
        end;
      end;
  end;
end;

procedure TNFCeController.CreateNFCe;
var
  oNFCe: TNFCe;
  DmNFCe: TdtmNFCe;
  DmSAT: TDtmSAT;
  StrRetorno: string;
begin
  try
    oNFCe := Context.Request.BodyAs<TNFCe>;
    try
      if oNFCe.Itens.Count <= 0 then
        raise Exception.Create('Nenhum item foi informado!');

      case ConfigServer.Tipo of
        tpNFCe:
          begin
            DmNFCe := TdtmNFCe.Create(nil);
            try
              DmNFCe.PreencherNFCe(oNFCe);
              StrRetorno := DmNFCe.Enviar;

              Render(HTTP_STATUS.Created, StrRetorno);
            finally
              DmNFCe.Free;
            end;
          end;

        tpSAT:
          begin
            DmSAT := TDtmSAT.Create(nil);
            try
              DmSAT.PreencherNFCe(oNFCe);
              StrRetorno := DmSAT.Enviar;

              Render(HTTP_STATUS.Created, StrRetorno);
            finally
              DmSAT.Free;
            end;
          end;
      end;
    finally
      oNFCe.Free;
    end;
  except
    on E: Exception do
    begin
      Render(HTTP_STATUS.InternalServerError, E.Message);
    end;
  end;
end;

procedure TNFCeController.GerarNFCeExemplo;
var
  I: Integer;
  oNFCe: TNFCe;
  oNFCeItem: TNFCeItem;
begin
  oNFCe := TNFCe.Create;

  oNFCe.cpf  := '';
  oNFCe.Nome := '';

  for I := 1 to 5 do
  begin
    oNFCeItem := TNFCeItem.Create;
    oNFCeItem.Id         := I;
    oNFCeItem.Descricao  := 'Descricao teste ' + I.ToString;
    oNFCeItem.Valor      := I * 10;
    oNFCeItem.Quantidade := I;

    oNFCe.Itens.Add(oNFCeItem);
  end;

  Render(oNFCe);
end;


end.
