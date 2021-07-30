unit UFramePedido;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Layouts, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.EngExt,
  Fmx.Bind.DBEngExt, Data.Bind.Components, Data.Bind.DBScope, Data.DB,
  FMX.ListView, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.ListBox;

type
  TFramePedido = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    EdtClienteNome: TEdit;
    EdtClienteCPF: TLabel;
    Label3: TLabel;
    Layout3: TLayout;
    Label4: TLabel;
    TmpItensPedido: TFDMemTable;
    ListView1: TListView;
    TmpItensPedidoId: TIntegerField;
    TmpItensPedidoDescricao: TStringField;
    TmpItensPedidoQuantidade: TIntegerField;
    TmpItensPedidoValorVenda: TFloatField;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    EdtProduto: TComboBox;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    Layout4: TLayout;
    Layout5: TLayout;
    BtnAdicionarProduto: TButton;
    Label5: TLabel;
    EdtQuantidade: TEdit;
    procedure BtnAdicionarProdutoClick(Sender: TObject);
  private

  public
    procedure Limpar;
    procedure Inicializar;
    procedure EnviarPedido;
  end;

implementation

{$R *.fmx}

uses DPrincipal, UPedidoClass;

{ TFramePedido }

procedure TFramePedido.Inicializar;
begin
  Self.Limpar;

  DtmPrincipal.qryProdutos.Close;
  DtmPrincipal.qryProdutos.Open;

  DtmPrincipal.qryClientes.Close;
  DtmPrincipal.qryClientes.Open;
end;

procedure TFramePedido.Limpar;
begin
  EdtClienteNome.Text := EmptyStr;
  EdtClienteCPF.Text  := EmptyStr;

  TmpItensPedido.Close;
  TmpItensPedido.CreateDataSet;

  EdtClienteNome.SetFocus;
end;

procedure TFramePedido.BtnAdicionarProdutoClick(Sender: TObject);
begin
  if EdtProduto.Selected.Text.trim.IsEmpty then
  begin
    EdtProduto.SetFocus;
    raise Exception.Create('Nenhum produto informado!');
  end;

  if EdtQuantidade.Text.ToInteger <= 0 then
  begin
    EdtQuantidade.SetFocus;
    raise Exception.Create('Informe um valor maior que zero para quantidade!');
  end;

  TmpItensPedido.InsertRecord([
    DtmPrincipal.qryProdutosID.AsInteger,
    DtmPrincipal.qryProdutosDESCRICAO.AsString,
    EdtQuantidade.Text.ToInteger,
    DtmPrincipal.qryProdutosVL_VENDA.AsFloat
  ]);
  {
  OU

  TmpItensPedido.Append;
  TmpItensPedidoId         := DtmPrincipal.qryProdutosID.AsInteger;
  TmpItensPedidoDescricao  := DtmPrincipal.qryProdutosDESCRICAO.AsString;
  TmpItensPedidoQuantidade := StrToInt(EdtQuantidade.Text);
  TmpItensPedidoValorVenda := DtmPrincipal.qryProdutosVL_VENDA.AsFloat;
  TmpItensPedido.Post;
  }
end;

procedure TFramePedido.EnviarPedido;
var
  oPedido: TPedido;
  oItemPedido: TPedidoItem;
begin
  if TmpItensPedido.IsEmpty then
    raise Exception.Create('Nenhum item foi adicionado, impossível continuar!');

  oPedido := TPedido.Create;
  try
    oPedido.cpf  := EdtClienteCPF.Text.Trim;
    oPedido.Nome := EdtClienteNome.Text.Trim;

    TmpItensPedido.DisableControls;
    try
      TmpItensPedido.First;
      while not TmpItensPedido.Eof do
      begin
        oItemPedido := TPedidoItem.Create;
        oItemPedido.Id         := TmpItensPedidoId.AsInteger;
        oItemPedido.Descricao  := TmpItensPedidoDescricao.AsString;
        oItemPedido.Valor      := TmpItensPedidoValorVenda.AsFloat;
        oItemPedido.Quantidade := TmpItensPedidoQuantidade.AsInteger;

        oPedido.Itens.Add(oItemPedido);
        TmpItensPedido.Next;
      end;
    finally
      TmpItensPedido.EnableControls;
    end;

    DtmPrincipal.Resp := DtmPrincipal.Cli
                           .Resource('/api/pedido')
                           .doPOST<TPedido>(oPedido, False);

    if DtmPrincipal.Resp.HasError then
      raise Exception.Create(DtmPrincipal.Resp.ResponseText);

    ShowMessage('Pedido Enviado!');
    Self.Limpar;

    DtmPrincipal.GetPDFFromPedido(1, 1);
  finally
    oPedido.DisposeOf;
  end;
end;

end.
