unit ProdutosService;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,

  UPoolConnection,
  ProdutosClass,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, {FireDAC.VCLUI.Wait,} Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB;

type
  TProdutoService = class
  private

  public
    class function GetProdutos(const ALikeDescricao: string): TObjectList<TProduto>;
    class function GetProduto(const ACodProduto: Integer): TProduto;
    class procedure Post(const AProduto: TProduto);
    class procedure Update(const AId: Integer; const AProduto: TProduto);
    class procedure Delete(const ACodProduto: Integer);
  end;

implementation

{ TProdutoService }

class procedure TProdutoService.Delete(const ACodProduto: Integer);
var
  FDConexao: TFDConnection;
  CountDelete: Integer;
begin
  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_FB;

    CountDelete := FDConexao.ExecSQL(
      'delete from produtos where ID=?',
      [ACodProduto],
      [ftInteger]
    );

    if CountDelete = 0 then
      raise EDatabaseError.Create('Nenhum produto foi excluido!');
  finally
    FDConexao.Free;
  end;
end;

class function TProdutoService.GetProduto(const ACodProduto: Integer): TProduto;
var
  FDConexao: TFDConnection;
  TmpDataset: TDataSet;
begin
  Result := TProduto.Create;

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_FB;

    FDConexao.ExecSQL(
      'select * from produtos where ID=' + ACodProduto.ToString,
      TmpDataset
    );

    if not TmpDataset.IsEmpty then
    begin
      Result.Id          := TmpDataset.FieldByName('ID').AsInteger;
      Result.Gtin        := TmpDataset.FieldByName('GTIN').AsString;
      Result.Descricao   := TmpDataset.FieldByName('DESCRICAO').AsString;
      Result.ValorVenda  := TmpDataset.FieldByName('VL_VENDA').AsCurrency;
      Result.Unidade     := TmpDataset.FieldByName('UN').AsString;
      Result.DataCriacao := TmpDataset.FieldByName('DT_CRIACAO').AsDateTime;
    end
    else
      raise EDatabaseError.CreateFmt('Produto "%d" não encontrado na base de dados!', [ACodProduto]);
  finally
    TmpDataset.Free;
    FDConexao.Free;
  end;
end;

class function TProdutoService.GetProdutos(const ALikeDescricao: string): TObjectList<TProduto>;
var
  FDConexao: TFDConnection;
  TmpDataset: TDataSet;
  Produto: TProduto;
  StrWhere: string;
begin
  Result := TObjectList<TProduto>.Create;

  FDConexao := TFDConnection.Create(nil);
  try
    if ALikeDescricao.Trim.IsEmpty then
      StrWhere := ''
    else
      StrWhere := 'where descricao like ''%' + ALikeDescricao + '%''';

    FDConexao.ConnectionDefName := NOME_CONEXAO_FB;
    FDConexao.ExecSQL('select * from produtos ' + StrWhere + ' order by id', TmpDataset);

    if not TmpDataset.IsEmpty then
    begin
      TmpDataset.First;
      while not TmpDataset.Eof do
      begin
        Produto := TProduto.Create;
        Produto.Id          := TmpDataset.FieldByName('ID').AsInteger;
        Produto.Gtin        := TmpDataset.FieldByName('GTIN').AsString;
        Produto.Descricao   := TmpDataset.FieldByName('DESCRICAO').AsString;
        Produto.ValorVenda  := TmpDataset.FieldByName('VL_VENDA').AsCurrency;
        Produto.Unidade     := TmpDataset.FieldByName('UN').AsString;
        Produto.DataCriacao := TmpDataset.FieldByName('DT_CRIACAO').AsDateTime;

        Result.Add(Produto);
        TmpDataset.Next;
      end;
    end
    else
      raise EDatabaseError.Create('Nenhum produto cadastrado na base de dados!');
  finally
    TmpDataset.Free;
    FDConexao.Free;
  end;
end;

class procedure TProdutoService.Post(const AProduto: TProduto);
var
  FDConexao: TFDConnection;
const
  SQL_INSERT: string =
    'INSERT INTO PRODUTOS (                                ' + sLineBreak +
    '  ID, GTIN, DESCRICAO, VL_VENDA, DT_CRIACAO, UN       ' + sLineBreak +
    ') VALUES (                                            ' + sLineBreak +
    '  (select coalesce(max(id) , 0) + 1 from produtos), :GTIN, :DESCRICAO, :VL_VENDA, CURRENT_TIMESTAMP, :UN ' + sLineBreak +
    ')                                                     ' ;
begin
  if AProduto.Descricao.Trim.IsEmpty then
    raise EDatabaseError.Create('Descrição do produto é obrigatória');

  if AProduto.ValorVenda <= 0 then
    raise EDatabaseError.Create('valor do produto deve ser um valor maior que zero');

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_FB;
    FDConexao.ExecSQL(SQL_INSERT,
      [
        Aproduto.Gtin,
        Aproduto.Descricao,
        Aproduto.ValorVenda,
        Aproduto.Unidade
      ],
      [
        ftString,
        ftString,
        ftFloat,
        ftString
      ]
    );
  finally
    FDConexao.Free;
  end;
end;

class procedure TProdutoService.Update(const AId: Integer; const AProduto: TProduto);
var
  FDConexao: TFDConnection;
  CountAtu: Integer;

const
  SQL_UPDATE: string =
    'UPDATE PRODUTOS SET         ' + sLineBreak +
    '  GTIN = :GTIN,             ' + sLineBreak +
    '  DESCRICAO = :DESCRICAO,   ' + sLineBreak +
    '  VL_VENDA = :VL_VENDA,     ' + sLineBreak +
    '  UN = :UN                  ' + sLineBreak +
    'WHERE (ID = :ID)            ';
begin
  if AProduto.Descricao.Trim.IsEmpty then
    raise EDatabaseError.Create('Descrição do produto é obrigatória');

  if AProduto.ValorVenda <= 0 then
    raise EDatabaseError.Create('valor do produto deve ser um valor maior que zero');

  FDConexao := TFDConnection.Create(nil);
  try
    FDConexao.ConnectionDefName := NOME_CONEXAO_FB;
    CountAtu := FDConexao.ExecSQL(SQL_UPDATE,
      [
        Aproduto.Gtin,
        Aproduto.Descricao,
        Aproduto.ValorVenda,
        Aproduto.Unidade,
        AId
      ],
      [
        ftString,
        ftString,
        ftFloat,
        ftString,
        ftInteger
      ]
    );

    if CountAtu <= 0 then
      raise Exception.Create('Nenhum produto foi atualizado');
  finally
    FDConexao.Free;
  end;
end;

end.

