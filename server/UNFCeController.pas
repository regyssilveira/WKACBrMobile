unit UNFCeController;

interface

uses
  UNFCeWebModulle,
  MVCFramework,
  MVCFramework.Commons;

type

  [MVCPath('/nfce')]
  TNFCeController = class(TMVCController)
  private
    FWebModule: TNFCEWebModule;
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
    [MVCHTTPMethod([httpGET])]
    procedure GetNFCe;

    [MVCPath('/nfce')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateNFCe(Context: TWebContext);
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  Data.DB,
  MVCFramework.Logger, UConfigClass, UNFCeClass;

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
  if not Assigned(FWebModule) then
    FWebModule := GetCurrentWebModule as TNFCEWebModule;

  inherited;
end;



procedure TNFCeController.GetClientes;
var
  TmpDataset: TDataSet;
begin
  FWebModule.FDConnection1.ExecSQL(
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
  FWebModule.FDConnection1.ExecSQL(
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
  FWebModule.FDConnection1.ExecSQL(
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
  FWebModule.FDConnection1.ExecSQL(
    'select * from produtos where id=' + AId.ToString,
    TmpDataset
  );

  if TmpDataset.IsEmpty then
    Render(500, Format('Não existe produto cadastrado com o código "%d" na base de dados', [AId]))
  else
    Render(TmpDataset, True);
end;

procedure TNFCeController.GetNFCe;
var
  oNFCe: TNFCe;
  oNFCeItem: TNFCeItem;
  I: Integer;
begin
  oNFCe := TNFCe.Create;

  oNFCe.cpf  := '11111111111';
  oNFCe.Nome := 'joao da silva';

  for I := 1 to 5 do
  begin
    oNFCeItem := TNFCeItem.Create;
    oNFCeItem.Id         := I;
    oNFCeItem.Descricao  := 'produto ' + I.ToString;
    oNFCeItem.Valor      := 1.01 * I;
    oNFCeItem.Quantidade := 1 * I;
    oNFCe.Itens.Add(oNFCeItem);
  end;

  Render(oNFCe, True);
end;

procedure TNFCeController.CreateNFCe(Context: TWebContext);
var
  oNFCe: TNFCe;
begin
  oNFCe := Context.Request.BodyAs<TNFCe>;
  try
    if oNFCe.Itens.Count <= 0 then
      raise Exception.Create('Nenhum item foi informado!');

    oNFCe.Numero := 9999999;
    oNFCe.Nome   := 'meu objeto alterado';

    Render(oNFCe, True);
  except
    on E: Exception do
    begin
      oNFCe.Free;
      Render(500, E.Message);
    end;
  end;
end;

end.
