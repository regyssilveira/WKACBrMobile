unit UFrameAtualizar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TFrameAtualizar = class(TFrame)
    Layout1: TLayout;
    btnAtualizar: TButton;
    ProgressBar1: TProgressBar;
    procedure btnAtualizarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DPrincipal;

procedure TFrameAtualizar.btnAtualizarClick(Sender: TObject);
var
  QryExecute: TFDQuery;
  I: Integer;
begin
  QryExecute := TFDQuery.Create(Self);
  try
    DtmPrincipal.tmpProdutos.Open;
    DtmPrincipal.tmpClientes.Open;

    ShowMessage('Começarei a atualizar agora...');

    ProgressBar1.Value := 0;
    ProgressBar1.Max :=
      DtmPrincipal.tmpProdutos.RecordCount +
      DtmPrincipal.tmpClientes.RecordCount;

    QryExecute.Connection := DtmPrincipal.FDConnection1;

    // produtos
    QryExecute.SQL.Text :=
      'INSERT OR REPLACE INTO PRODUTOS                        ' + sLineBreak +
      '  (ID, GTIN, DESCRICAO, VL_VENDA, DT_CRIACAO, UN)      ' + sLineBreak +
      'VALUES                                                 ' + sLineBreak +
      '  (:ID, :GTIN, :DESCRICAO, :VL_VENDA, :DT_CRIACAO, :UN)';

    I := 0;
    QryExecute.Params.ArraySize := DtmPrincipal.tmpProdutos.RecordCount;
    try
      DtmPrincipal.tmpProdutos.First;
      while not DtmPrincipal.tmpProdutos.Eof do
      begin
        QryExecute.Params[0].AsIntegers[I]  := DtmPrincipal.tmpProdutosid.AsInteger;
        QryExecute.Params[1].AsStrings[I]   := DtmPrincipal.tmpProdutosgtin.AsString;
        QryExecute.Params[2].AsStrings[I]   := DtmPrincipal.tmpProdutosdescricao.AsString;
        QryExecute.Params[3].AsFloats[I]    := DtmPrincipal.tmpProdutosvl_venda.AsFloat;
        QryExecute.Params[4].AsDateTimes[I] := DtmPrincipal.tmpProdutosdt_criacao.AsDateTime;
        QryExecute.Params[5].AsStrings[I]   := DtmPrincipal.tmpProdutosun.AsString;

        DtmPrincipal.tmpProdutos.Next;
        ProgressBar1.Value := ProgressBar1.Value + 1;

        I := I + 1;
      end;

      QryExecute.Execute(QryExecute.Params.ArraySize);
    finally
      DtmPrincipal.tmpProdutos.Close;
    end;

    // clientes
    QryExecute.SQL.Text :=
      'INSERT OR REPLACE INTO CLIENTES (ID, NOME, CPF) VALUES (:ID, :NOME, :CPF)';

    I := 0;
    QryExecute.Params.ArraySize := DtmPrincipal.tmpClientes.RecordCount;
    try
      DtmPrincipal.tmpClientes.First;
      while not DtmPrincipal.tmpClientes.Eof do
      begin
        QryExecute.Params[0].AsIntegers[I]  := DtmPrincipal.tmpClientesid.AsInteger;
        QryExecute.Params[1].AsStrings[I]   := DtmPrincipal.tmpClientesnome.AsString;
        QryExecute.Params[2].AsStrings[I]   := DtmPrincipal.tmpClientescpf.AsString;

        DtmPrincipal.tmpClientes.Next;
        ProgressBar1.Value := ProgressBar1.Value + 1;

        I := I + 1;
      end;

      QryExecute.Execute(QryExecute.Params.ArraySize);
    finally
      DtmPrincipal.tmpClientes.Close;
    end;

    ShowMessage('pronto!');
  finally
    QryExecute.DisposeOf;
  end;
end;

end.
