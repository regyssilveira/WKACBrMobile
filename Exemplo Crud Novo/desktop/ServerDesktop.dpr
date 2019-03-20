program ServerDesktop;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  FormUnit1 in 'FormUnit1.pas' {Form1},
  ProdutosClass in '..\ProdutosClass.pas',
  ProdutosService in '..\ProdutosService.pas',
  UMyController in '..\UMyController.pas',
  UMyWebModule in '..\UMyWebModule.pas' {MyWebModule: TWebModule},
  UPoolConnection in '..\UPoolConnection.pas';

{$R *.res}

begin
  CreatePoolConnection;

  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;

  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
