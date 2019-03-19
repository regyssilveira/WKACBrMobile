unit UMyController;

interface

uses
  MVCFramework,
  MVCFramework.Commons;

type

  [MVCPath('/api')]
  TMyController = class(TMVCController)
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure GetMyRootPage;

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos;

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProduto(id: Integer);

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateProduto;

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateProduto(id: Integer);

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure DeleteProduto(id: Integer);
  end;

implementation

uses
  System.SysUtils,

  Dialogs,

  MVCFramework.Logger, ProdutosService, ProdutosClass;

procedure TMyController.GetMyRootPage;
begin
  Render('<h1>API Demo server</h1><p>Bem vindo a minha primeira API RESTFULL.</p>');
  ContentType := 'text/html';
end;

procedure TMyController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin

  inherited;
end;

procedure TMyController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin

  inherited;
end;

procedure TMyController.Getprodutos;
begin
  Render<TProduto>(TProdutoService.GetProdutos);
end;

procedure TMyController.Getproduto(id: Integer);
begin
  Render(TProdutoService.GetProduto(Id));
end;

procedure TMyController.Createproduto;
var
  Produto: TProduto;
begin
  Produto := Context.Request.BodyAs<TProduto>;
  try
    TProdutoService.Post(Produto);
    Render(200, 'Produto criado com sucesso');
  finally
    Produto.Free;
  end;
end;

procedure TMyController.Updateproduto(id: Integer);
var
  Produto: TProduto;
begin
  Produto := Context.Request.BodyAs<TProduto>;
  try
    TProdutoService.Update(Id, Produto);
    Render(200, Format('Produto "%d" atualizado com sucesso', [Id]));
  finally
    Produto.Free;
  end;
end;

procedure TMyController.Deleteproduto(id: Integer);
begin
  TProdutoService.Delete(Id);
  Render(200, Format('Produto "%d" apagado com sucesso', [Id]));
end;



end.
