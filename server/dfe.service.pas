unit dfe.service;

interface

uses
  System.SysUtils,
  System.Classes,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB;

type
  TDFService = class
  private
    FDConexao: TFDConnection;
  public
    constructor Create;
    destructor Destroy; override;

    function GetClientes: TDataSet;
    function GetClienteById(const AId: Integer): TDataSet;
    function GetProdutos: TDataSet;
    function GetProdutoWhere(const AWhere: string): TDataSet;
    function GetProdutosPaginado(const AAtual, AQuantidade: integer): TFDQuery;
    function GetProdutoById(const AId: Integer): TDataSet;
  end;

implementation

uses
  UPoolConnection;

{ TDFService }

constructor TDFService.Create;
begin
  inherited Create;
  FDConexao := TFDConnection.Create(nil);
  FDConexao.ConnectionDefName := NOME_CONEXAO_FB;
end;

destructor TDFService.Destroy;
begin
  FDConexao.DisposeOf;
  inherited;
end;

function TDFService.GetClientes: TDataSet;
begin
  FDConexao.ExecSQL('select * from clientes', Result);
end;

function TDFService.GetClienteById(const AId: Integer): TDataSet;
begin
  FDConexao.ExecSQL('select * from clientes where id=0' + AId.ToString, Result);
end;

function TDFService.GetProdutoById(const AId: Integer): TDataSet;
begin
  FDConexao.ExecSQL('select * from produtos where id=' + AId.ToString, Result);
end;

function TDFService.GetProdutos: TDataSet;
begin
  FDConexao.ExecSQL('select * from produtos', Result);
end;

function TDFService.GetProdutoWhere(const AWhere: string): TDataSet;
var
  StrWhere: string;
begin
  StrWhere := 'where descricao like ''%' + AWhere + '%''';
  FDConexao.ExecSQL('select * from produtos ' + StrWhere, Result);
end;

function TDFService.GetProdutosPaginado(const AAtual, AQuantidade: integer): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FDConexao;
  Result.FetchOptions.RecsSkip := AAtual;
  Result.FetchOptions.RecsMax  := AQuantidade;
  Result.Open('select * from produtos');
end;

end.
