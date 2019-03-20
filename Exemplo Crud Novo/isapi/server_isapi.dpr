library server_isapi;

uses
  Winapi.ActiveX,
  System.Win.ComObj,
  Web.WebBroker,
  Web.Win.ISAPIApp,
  Web.Win.ISAPIThreadPool,
  ProdutosClass in '..\ProdutosClass.pas',
  ProdutosService in '..\ProdutosService.pas',
  UMyController in '..\UMyController.pas',
  UMyWebModule in '..\UMyWebModule.pas' {MyWebModule: TWebModule},
  UPoolConnection in '..\UPoolConnection.pas';

{$R *.res}

exports
  GetExtensionVersion,
  HttpExtensionProc,
  TerminateExtension;

begin
  CreatePoolConnection;

  CoInitFlags := COINIT_MULTITHREADED;
  Application.Initialize;
  Application.WebModuleClass := WebModuleClass;
  Application.Run;
end.
