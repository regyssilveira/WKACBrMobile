library nfceserver;

uses
  Winapi.ActiveX,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  UNFCeWebModulle in '..\UNFCeWebModulle.pas' {NFCEWebModule: TWebModule},
  AuthHandlerU in '..\AuthHandlerU.pas',
  UNFCeClass in '..\..\comum\UNFCeClass.pas',
  UNFCeController in '..\UNFCeController.pas',
  UBaseController in '..\UBaseController.pas',
  DNFCe in '..\DNFCe.pas' {DtmNFCe: TDataModule},
  UConfigClass in '..\UConfigClass.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
