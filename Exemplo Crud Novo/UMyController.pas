unit UMyController;

interface

uses
  Redis.Commons,
  Redis.NetLib.indy,

  ProdutosService,
  Data.DB,
  ProdutosClass,

  Generics.Collections,

  MVCFramework,
  MVCFramework.Logger,
  MVCFramework.Commons,
  MVCFramework.Controllers.CacheController;

type
  [MVCPath('/api')]
  TMyController = class(TMVCCacheController)
  private
    FProdutoService: TProdutoService;
    function GetProdutosDataset(const Alike: string): TDataset;
    function GetProdutosLista(const Alike: string): TObjectList<TProduto>;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath]
    [MVCHTTPMethod([httpGET])]
    procedure GetMyRootPage;

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos;

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateProduto;

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProduto(id: Integer);

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateProduto(id: Integer);

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure DeleteProduto(id: Integer);
  end;

implementation

uses
  System.SysUtils;

procedure TMyController.GetMyRootPage;
begin
  ContentType := TMVCMediaType.TEXT_HTML;
  Render(
    '<h1>API Demo server</h1>' +
    '<p>Bem vindo a minha primeira API RESTFULL.</p>'
  );
end;

procedure TMyController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  FProdutoService.DisposeOf;
  inherited;
end;

procedure TMyController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  inherited;
  FProdutoService := TProdutoService.Create;
end;

procedure TMyController.Getprodutos;
var
  StrQuery: string;
  StrTipo: string;
begin
  StrQuery := Context.Request.QueryStringParam('like');

  StrTipo := Context.Request.QueryStringParam('tipo');
  if StrTipo.Trim.IsEmpty then
    StrTipo := 'lista';

  // seta a chave e verifica se existe cache
  SetCacheKey('#cache::produto::' + StrTipo + '::' + StrQuery);
  if CacheAvailable then
  begin
    Log.Info('>>>>>>>> usou o cache.', '');
    Exit;
  end;

  Log.Info('>>>>>>>>> não usou o cache.', '');
  if StrTipo.Equals('dataset') then
    Render(GetProdutosDataset(StrQuery))
  else
  if StrTipo.Equals('lista') then
    Render<TProduto>(GetProdutosLista(StrQuery))
  else
    raise Exception.Create('Tipo desconhecido');

  // seta o tempo de vida do cache
  SetCache(8);
end;

function TMyController.GetProdutosDataset(const Alike: string): TDataset;
begin
  Result := FProdutoService.GetProdutosDataset(Alike);
end;

function TMyController.GetProdutosLista(const Alike: string): TObjectList<TProduto>;
begin
  Result := FProdutoService.GetProdutos(Alike);
end;

procedure TMyController.Getproduto(id: Integer);
begin
  SetCacheKey('#cache::produto::' + Id.ToString);
  if CacheAvailable then
    Exit;

  Render(FProdutoService.GetProduto(Id));

  SetCache(3);
end;

procedure TMyController.Createproduto;
var
  Produto: TProduto;
begin
  Produto := Context.Request.BodyAs<TProduto>;
  try
    FProdutoService.Post(Produto);
    Render(201, 'Produto criado com sucesso');
  finally
    Produto.Free;
  end;
end;

procedure TMyController.Updateproduto(id: Integer);
var
  Produto: TProduto;
begin
  // forçar limpeza do cache se existir para o id do produto
  SetCacheKey('#cache::produto::' + Id.ToString);
  SetCache(0);

  Produto := Context.Request.BodyAs<TProduto>;
  try
    FProdutoService.Update(Id, Produto);
    Render(200, Format('Produto "%d" atualizado com sucesso', [Id]));
  finally
    Produto.Free;
  end;
end;

procedure TMyController.Deleteproduto(id: Integer);
begin
  // forçar limpeza do cache se existir para o id do produto
  SetCacheKey('#cache::produto::' + Id.ToString);
  SetCache(0);

  FProdutoService.Delete(Id);
  Render(200, Format('Produto "%d" apagado com sucesso', [Id]));
end;



end.
