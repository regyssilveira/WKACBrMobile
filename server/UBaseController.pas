unit UBaseController;

interface

uses
  dfe.service,

  UNFCeWebModulle,
  MVCFramework,
  MVCFramework.Commons;

type
  TBaseController = class(TMVCController)
  private
    FService: TDFService;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;

    property Service: TDFService read FService write FService;
  end;

implementation

uses
  UPoolConnection;

{ TBaseController }

procedure TBaseController.OnBeforeAction(Context: TWebContext;
  const AActionName: string; var Handled: Boolean);
begin
  FService := TDFService.Create;
  inherited;
end;

procedure TBaseController.OnAfterAction(Context: TWebContext;
  const AActionName: string);
begin
  FService.DisposeOf;
  inherited;
end;

end.
