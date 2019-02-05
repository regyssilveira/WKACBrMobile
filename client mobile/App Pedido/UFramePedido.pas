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
    Label1: TLabel;
    EdtClienteNome: TEdit;
    Edit2: TEdit;
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
    EdtQuantidade: TEdit;
    Label5: TLabel;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    BtnAdicionarProduto: TButton;
    procedure BtnAdicionarProdutoClick(Sender: TObject);
  private

  public
    procedure Inicilizar;
    procedure Limpar;
    procedure EnviarPedido;
  end;

implementation

{$R *.fmx}

uses DPrincipal, UNFCeClass;

{ TFramePedido }

procedure TFramePedido.Inicilizar;
begin
  Self.Limpar;

end;

procedure TFramePedido.Limpar;
begin
  EdtClienteNome.Text := '';
  EdtClienteCPF.Text  := '';

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

  if StrToInt(EdtQuantidade.Text) <= 0 then
  begin
    EdtQuantidade.SetFocus;
    raise Exception.Create('Informe um valor maior que zero para quantidade!');
  end;

  TmpItensPedido.InsertRecord([
    DtmPrincipal.qryProdutosID.AsInteger,
    DtmPrincipal.qryProdutosDESCRICAO.AsString,
    StrToInt(EdtQuantidade.Text),
    DtmPrincipal.qryProdutosVL_VENDA.AsFloat
  ]);
end;

procedure TFramePedido.EnviarPedido;
var
  oPedido: TNFCe;
  oItemPedido: TNFCeItem;
begin
  if TmpItensPedido.IsEmpty then
    raise Exception.Create('Nenhum item foi adicionado, imposs�vel continuar!');

  oPedido := TNFCe.Create;
  try
    oPedido.cpf  := EdtClienteCPF.Text;
    oPedido.Nome := EdtClienteNome.Text;

    TmpItensPedido.First;
    while not TmpItensPedido.Eof do
    begin
      oItemPedido := TNFCeItem.Create;
      oItemPedido.Id         := TmpItensPedidoId.AsInteger;
      oItemPedido.Descricao  := TmpItensPedidoDescricao.AsString;
      oItemPedido.Valor      := TmpItensPedidoValorVenda.AsFloat;
      oItemPedido.Quantidade := TmpItensPedidoQuantidade.AsInteger;

      oPedido.Itens.Add(oItemPedido);
      TmpItensPedido.Next;
    end;

    DtmPrincipal.InicializarRESTClient;
    DtmPrincipal.Resp := DtmPrincipal.Cli.doPOST('/nfce/nfce', [], oPedido.AsJsonString);
    if DtmPrincipal.Resp.HasError then
      raise Exception.Create(DtmPrincipal.Resp.ResponseText);

    ShowMessage('Pedido Enviado!');
    Self.Limpar;
  finally
    oPedido.DisposeOf;
  end;
end;

end.