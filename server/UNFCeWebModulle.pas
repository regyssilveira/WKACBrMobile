unit UNFCeWebModulle;

interface

uses
  System.SysUtils,
  System.Classes,
  Web.HTTPApp,
  FireDAC.DApt,

  AuthHandlerU,

  MVCFramework;

type
  TNFCEWebModule = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    FMVC: TMVCEngine;
  public
    { Public declarations }
  end;

var
  WebModuleClass: TComponentClass = TNFCEWebModule;

implementation

{$R *.dfm}

uses
  UNFCeController,
  System.IOUtils,

  MVCFramework.Commons,
  MVCFramework.Middleware.Compression,
  MVCFramework.Middleware.Authentication;

procedure TNFCEWebModule.WebModuleCreate(Sender: TObject);
begin
  FMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      Config[TMVCConfigKey.DocumentRoot]             := TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'www');
      Config[TMVCConfigKey.SessionTimeout]           := '0';
      Config[TMVCConfigKey.DefaultContentType]       := TMVCConstants.DEFAULT_CONTENT_TYPE;
      Config[TMVCConfigKey.DefaultContentCharset]    := TMVCConstants.DEFAULT_CONTENT_CHARSET;
      Config[TMVCConfigKey.AllowUnhandledAction]     := 'false';
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      Config[TMVCConfigKey.ViewPath]                 := 'templates';
      Config[TMVCConfigKey.MaxEntitiesRecordCount]   := '20';
      Config[TMVCConfigKey.ExposeServerSignature]    := 'true';
      Config[TMVCConfigKey.FallbackResource]         := 'index.html';
      Config[TMVCConfigKey.MaxRequestSize]           := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
    end);

  FMVC.AddController(TNFCeController);

  // To enable compression (deflate, gzip) just add this middleware as the last one
  FMVC.AddMiddleware(TMVCCompressionMiddleware.Create);

//  FMVC.AddMiddleware(
//    TMVCCustomAuthenticationMiddleware.Create(
//      TCustomAuth.Create, '/system/usuarios/logados'
//    )
//  );
end;

procedure TNFCEWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.

