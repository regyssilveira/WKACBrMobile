unit UBaseController;

interface

uses
  dfe.service,
  UDatamoduleInterface,

  MVCFramework,
  MVCFramework.Commons;

type
  TBaseController = class(TMVCController)
  private
    FService: TDFService;
    FDatamodule: IDatamodule;
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;

    property Service: TDFService read FService write FService;
    property Datamodule: IDatamodule read FDatamodule write FDatamodule;
  end;

implementation

uses
  UPoolConnection, UConfigClass, DNFCe, DSAT;

{ TBaseController }

procedure TBaseController.OnBeforeAction(Context: TWebContext;
  const AActionName: string; var Handled: Boolean);
begin
  FService := TDFService.Create;

  case ConfigServer.Tipo of
    tpNFCe : FDatamodule := TDtmNFCe.Create(nil);
    tpSAT  : FDatamodule := TDtmSAT.Create(nil);
    tpMFe  : FDatamodule := TDtmSAT.Create(nil);
  end;

  inherited;
end;

procedure TBaseController.OnAfterAction(Context: TWebContext;
  const AActionName: string);
begin
  FService.DisposeOf;
  FDatamodule := nil;
  inherited;
end;

end.
