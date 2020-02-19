unit UBaseController;

interface

uses
  UNFCeWebModulle,
  MVCFramework,
  MVCFramework.Commons,

  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB,
  FireDAC.Comp.Client, FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB;

type
  TBaseController = class(TMVCController)
  protected
    FWebModule: TNFCEWebModule;
    FDConexao: TFDConnection;

    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  UPoolConnection;

{ TBaseController }

procedure TBaseController.OnBeforeAction(Context: TWebContext;
  const AActionName: string; var Handled: Boolean);
begin
  // como seria para guardar uma variavel que acessa o webmodule
  if not Assigned(FWebModule) then
    FWebModule := GetCurrentWebModule as TNFCEWebModule;

  // criando uma conexão somente para o controler e usando o pool connection
  if not Assigned(FDConexao) then
    FDConexao := TFDConnection.Create(nil);

  FDConexao.ConnectionDefName := NOME_CONEXAO_FB;

  inherited;
end;

procedure TBaseController.OnAfterAction(Context: TWebContext;
  const AActionName: string);
begin
  FDConexao.Free;

  inherited;
end;

end.
