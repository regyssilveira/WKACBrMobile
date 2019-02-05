unit Unit1;

interface

uses
  Unit2,

  MVCFramework, MVCFramework.Commons;

type

  TProduto = class
  private
    FUN: string;
    FDESCRICAO: string;
    FGTIN: string;
    FID: Integer;
    FVL_VENDA: Double;
    FDT_CRIACAO: TDateTime;
    FDT_ALTERACAO: TDateTime;
  public
    property ID: Integer read FID write FID;
    property GTIN: string read FGTIN write FGTIN;
    property DESCRICAO: string read FDESCRICAO write FDESCRICAO;
    property VL_VENDA: Double read FVL_VENDA write FVL_VENDA;
    property DT_CRIACAO: TDateTime read FDT_CRIACAO write FDT_CRIACAO;
    property DT_ALTERACAO: TDateTime read FDT_ALTERACAO write FDT_ALTERACAO;
    property UN: string read FUN write FUN;
  end;

  [MVCPath('/nfce')]
  TMinhaController = class(TMVCController)
  private
    FWm: TMinhaWebModule;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;

  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/reversedstrings/($Value)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetReversedString(const Value: String);

    //Sample CRUD Actions for a "Customer" entity
    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProdutos;

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetProduto(id: Integer);

    [MVCPath('/produtos')]
    [MVCHTTPMethod([httpPOST])]
    procedure CreateProduto(Ctx: TWebContext);

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpPUT])]
    procedure UpdateProduto(id: Integer);

    [MVCPath('/produtos/($id)')]
    [MVCHTTPMethod([httpDELETE])]
    procedure DeleteProduto(id: Integer);

  end;

implementation

uses
  Dialogs,
  Data.DB, System.SysUtils, MVCFramework.Logger, System.StrUtils;

procedure TMinhaController.Index;
begin
  //use Context property to access to the HTTP request and response 
  Render('Hello DelphiMVCFramework World');
end;

procedure TMinhaController.GetReversedString(const Value: String);
begin
  Render(System.StrUtils.ReverseString(Value.Trim));
end;

procedure TMinhaController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }

  FWm := GetCurrentWebModule as TMinhaWebModule;

  inherited;
end;

procedure TMinhaController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin

  { Executed after each action }
  inherited;
end;

//Sample CRUD Actions for a "Customer" entity
procedure TMinhaController.GetProdutos;
var
  TmpDataset: TDataset;
begin
  FWm.FDConnection1.ExecSQL(
    'select * from produtos',
    TmpDataset
  );

  Render(TmpDataset, True);
end;

procedure TMinhaController.GetProduto(id: Integer);
var
  TmpDataset: TDataset;
begin
  FWm.FDConnection1.ExecSQL(
    'select * from produtos where id=' + id.ToString,
    TmpDataset
  );

  if not TmpDataset.IsEmpty then
    Render(TmpDataset, True)
  else
    raise Exception.CreateFmt('Nenhum produto encontrado para o codigo: %d', [Id]);
    //Render(500, 'Nenhum produto encontrado para o codigo: ' + Id.ToString);
end;

procedure TMinhaController.CreateProduto(Ctx: TWebContext);
var
  Ret: Integer;
  OProduto: TProduto;
begin
  try
    OProduto := Ctx.Request.BodyAs<TProduto>;
    try
      if OProduto.ID <= 0 then
        raise Exception.Create('Código do produto não foi informado');

      if OProduto.DESCRICAO.Trim.IsEmpty then
        raise Exception.Create('Descrição do produto não foi informado');

      if OProduto.VL_VENDA <= 0 then
        raise Exception.Create('Valor de venda do produto não foi informado');

      Ret := FWm.FDConnection1.ExecSQL(
        'INSERT INTO PRODUTOS (                                ' + sLineBreak +
        '  ID, GTIN, DESCRICAO, VL_VENDA, DT_CRIACAO, UN       ' + sLineBreak +
        ') VALUES (                                            ' + sLineBreak +
        '  :ID, :GTIN, :DESCRICAO, :VL_VENDA, :DT_CRIACAO, :UN ' + sLineBreak +
        ');                                                    ' ,
        [
          OProduto.ID,
          OProduto.GTIN,
          OProduto.DESCRICAO,
          OProduto.VL_VENDA,
          OProduto.DT_CRIACAO,
          OProduto.UN
        ],
        [
          ftInteger,
          ftString,
          ftString,
          ftFloat,
          ftDateTime,
          ftString
        ]
      );

      if Ret > 0 then
        Render(200, 'produto cadastrado com sucesso')
      else
        raise Exception.Create('Ocorreram erros durante o cadastro');
    finally
      OProduto.Free;
    end;
  except
    on E: exception do
    begin
      raise Exception.Create('Ocorreu um erro durante o processo de inserção: ' + E.Message);
    end;
  end;
end;

procedure TMinhaController.UpdateProduto(id: Integer);
var
  Ret: Integer;
  OProduto: TProduto;
begin
  try
    OProduto := Context.Request.BodyAs<TProduto>;
    try
      if OProduto.DESCRICAO.Trim.IsEmpty then
        raise Exception.Create('Descrição do produto não foi informado');

      if OProduto.VL_VENDA <= 0 then
        raise Exception.Create('Valor de venda do produto não foi informado');

      Ret := FWm.FDConnection1.ExecSQL(
        'UPDATE PRODUTOS SET             ' + sLineBreak +
        '  GTIN = :GTIN,                 ' + sLineBreak +
        '  DESCRICAO = :DESCRICAO,       ' + sLineBreak +
        '  VL_VENDA = :VL_VENDA,         ' + sLineBreak +
        '  DT_ALTERACAO = :DT_ALTERACAO, ' + sLineBreak +
        '  UN = :UN                      ' + sLineBreak +
        'WHERE (ID = :ID);               ' ,
        [
          OProduto.GTIN,
          OProduto.DESCRICAO,
          OProduto.VL_VENDA,
          OProduto.DT_ALTERACAO,
          OProduto.UN,
          id
        ],
        [
          ftString,
          ftString,
          ftFloat,
          ftDateTime,
          ftString,
          ftInteger
        ]
      );

      if Ret > 0 then
        Render(200, 'produto atualizado com sucesso')
      else
        raise Exception.Create('Ocorreram erros durante o cadastro');
    finally
      OProduto.Free;
    end;
  except
    on E: exception do
    begin
      raise Exception.Create('Ocorreu um erro durante o processo de atualização: ' + E.Message);
    end;
  end;
end;

procedure TMinhaController.DeleteProduto(id: Integer);
var
  Ret: integer;
begin
  Ret := FWm.FDConnection1.ExecSQL(
    'delete from produtos where id = ' + id.ToString
  );

  if Ret > 0 then
    Render(200, 'Produto apagado com sucesso')
  else
    raise Exception.Create('Nenhuma produto foi encontrado para o código: ' + Id.ToString);
end;



end.
