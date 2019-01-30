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
    procedure GetNFCeArquivo(ANumero: integer; ASerie: integer); overload;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos;

    [MVCPath('/produtos/($AId)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProduto(AId: Integer);

    [MVCPath('/clientes')]
    [MVCHTTPMethod([httpGET])]
    procedure GetClientes;

    [MVCPath('/clientes/($Aid)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetCliente(Aid: Integer);

    [MVCPath('/nfce')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateNFCe(Context: TWebContext);

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
  DNFCe;

{ TNFCeController }

procedure TNFCeController.Index;
begin
  //use Context property to access to the HTTP request and response 
  Render('curso API NFC-e');
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
  FDConexao.ExecSQL(
    'select * from clientes',
    TmpDataset
  );

  if TmpDataset.IsEmpty then
    Render(500, 'Não existe nenhum cliente cadastrado na base de dados')
  else
    Render(TmpDataset, True);
end;

procedure TNFCeController.GetCliente(Aid: Integer);
var
  TmpDataset: TDataSet;
begin
  FDConexao.ExecSQL(
    'select * from clientes where id=' + AId.ToString,
    TmpDataset
  );

  if TmpDataset.IsEmpty then
    Render(500, Format('Não existe cliente cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset, True);
end;

procedure TNFCeController.GetProdutos;
var
  TmpDataset: TDataSet;
begin
  FDConexao.ExecSQL(
    'select * from produtos',
    TmpDataset
  );

  if TmpDataset.IsEmpty then
    Render(500, 'Não existe nenhum produto cadastrado na base de dados')
  else
    Render(TmpDataset, True);
end;

procedure TNFCeController.GetProduto(AId: Integer);
var
  TmpDataset: TDataSet;
begin
  FDConexao.ExecSQL(
    'select * from produtos where id=' + AId.ToString,
    TmpDataset
  );

  if TmpDataset.IsEmpty then
    Render(500, Format('Não existe produto cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset, True);
end;

procedure TNFCeController.GetNFCeArquivo(ANumero, ASerie: integer);
var
  Lista: TStringList;
  DmNFCe: TdtmNFCe;
begin
  DmNFCe := TdtmNFCe.Create(nil);
  try
    Render(DmNFCe.GerarXML(ANumero, ASerie));
  finally
    DmNFCe.Free;
  end;
end;

procedure TNFCeController.GetNFCePDF(ANumero, ASerie: integer);
var
  DmNFCe: TdtmNFCe;
  PathPDF: string;
  StreamPDF: TMemoryStream;
begin
  DmNFCe := TdtmNFCe.Create(nil);
  try
    PathPDF := DmNFCe.GerarPDF(ANumero, ASerie);

    StreamPDF := TMemoryStream.Create;;
    try
      StreamPDF.LoadFromFile(PathPDF);
      Render(StreamPDF, True);
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

procedure TNFCeController.GetNFCe(ANumero, ASerie: integer; ATipo: string);
begin
  if ATipo.ToUpper = 'XML' then
    Self.GetNFCeArquivo(Anumero, ASerie)
  else
  if ATipo.ToUpper = 'PDF' then
    Self.GetNFCePDF(Anumero, ASerie)
  else
    raise Exception.Create('tipo de saida desconhecida');
end;

procedure TNFCeController.CreateNFCe(Context: TWebContext);
var
  oNFCe: TNFCe;
  DmNFCe: TdtmNFCe;
  StrRetorno: string;
begin
  try
    oNFCe := Context.Request.BodyAs<TNFCe>;
    try
      if oNFCe.Itens.Count <= 0 then
        raise Exception.Create('Nenhum item foi informado!');

      DmNFCe := TdtmNFCe.Create(nil);
      try
        DmNFCe.PreencherNFCe(oNFCe);
        StrRetorno := DmNFCe.Enviar;

        Render(201, StrRetorno);
      finally
        DmNFCe.Free;
      end;
    finally
      oNFCe.Free;
    end;
  except
    on E: Exception do
    begin
      Render(500, E.Message);
    end;
  end;
end;

end.
