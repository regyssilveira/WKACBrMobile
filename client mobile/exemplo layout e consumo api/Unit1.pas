unit Unit1;

interface

uses
  MVCFramework.RESTClient,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, System.Rtti,
  FMX.Grid.Style, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.Grid,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, Fmx.Bind.Grid, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.Components, Data.Bind.Grid, Data.Bind.DBScope,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Layouts, FMX.Edit;

type
  TForm1 = class(TForm)
    tbProdutos: TFDMemTable;
    tbClientes: TFDMemTable;
    tbProdutosid: TIntegerField;
    tbProdutosgtin: TStringField;
    tbProdutosdescricao: TStringField;
    tbProdutosvl_venda: TFloatField;
    tbProdutosdt_criacao: TDateField;
    tbProdutosun: TStringField;
    tbClientesid: TIntegerField;
    tbClientesnome: TStringField;
    tbClientescpf: TStringField;
    Layout1: TLayout;
    Button2: TButton;
    Button1: TButton;
    Layout2: TLayout;
    Memo1: TMemo;
    Layout3: TLayout;
    Layout4: TLayout;
    ListView1: TListView;
    ListView2: TListView;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkListControlToField1: TLinkListControlToField;
    BindSourceDB2: TBindSourceDB;
    LinkListControlToField2: TLinkListControlToField;
    Layout5: TLayout;
    SpeedButton1: TSpeedButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure tbProdutosAfterOpen(DataSet: TDataSet);
    procedure tbClientesAfterOpen(DataSet: TDataSet);
  private
    FResponse: IRESTResponse;
    FCli: TRESTClient;
  public
    property Cli: TRESTClient read FCli write FCli;
  end;

var
  Form1: TForm1;

implementation

uses
  MVCFramework.DataSet.Utils;

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FCli := TRESTClient.Create('http://192.168.88.28', 8080);

  tbClientes.CreateDataSet;
  tbProdutos.CreateDataSet;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FCli.Free;
end;




procedure TForm1.Button1Click(Sender: TObject);
begin
  tbProdutos.Close;
  tbProdutos.Open;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  tbClientes.Close;
  tbClientes.Open;
end;

procedure TForm1.tbClientesAfterOpen(DataSet: TDataSet);
begin
  FResponse := Cli.doGET('/nfce/clientes', []);
  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText)
  else
    Memo1.Lines.Text := FResponse.BodyAsString;

  DataSet.DisableControls;
  try
    tbClientes.LoadFromJSONArrayString(FResponse.BodyAsString);
    tbClientes.First;
  finally
    DataSet.EnableControls;
  end;
end;

procedure TForm1.tbProdutosAfterOpen(DataSet: TDataSet);
begin
  FResponse := Cli.doGET('/nfce/produtos', ['0', '50']);
  if FResponse.HasError then
    raise Exception.Create(FResponse.ResponseText)
  else
    Memo1.Lines.Text := FResponse.BodyAsString;

  DataSet.DisableControls;
  try
    tbProdutos.LoadFromJSONArrayString(FResponse.BodyAsString);
    tbProdutos.First;
  finally
    DataSet.EnableControls;
  end;
end;

end.
