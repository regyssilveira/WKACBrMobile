program NFCServerGUI;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  UPrincipal in 'UPrincipal.pas' {Form1},
  AuthHandlerU in '..\AuthHandlerU.pas',
  DNFCe in '..\DNFCe.pas' {DtmNFCe: TDataModule},
  UBaseController in '..\UBaseController.pas',
  UConfigClass in '..\UConfigClass.pas',
  UNFCeController in '..\UNFCeController.pas',
  UNFCeWebModulle in '..\UNFCeWebModulle.pas' {NFCEWebModule: TWebModule},
  UNFCeClass in '..\..\comum\UNFCeClass.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
