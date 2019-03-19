unit UMyWebModule;

interface

uses
  System.SysUtils,
  System.Classes,

  Web.HTTPApp,

  MVCFramework;

type
  TMyWebModule = class(TWebModule)
    procedure WebModuleCreate(Sender: TObject);
    procedure WebModuleDestroy(Sender: TObject);
  private
    FMVC: TMVCEngine;
  public

  end;

var
  WebModuleClass: TComponentClass = TMyWebModule;

implementation

{$R *.dfm}

uses
  UMyController,

  System.IOUtils,
  System.Generics.Collections,

  MVCFramework.Commons,
  MVCFramework.Middleware.Compression,
  MVCFramework.Server,
  MVCFramework.Server.Impl,
  MVCFramework.Middleware.Authentication;

procedure TMyWebModule.WebModuleCreate(Sender: TObject);
begin
  FMVC := TMVCEngine.Create(Self,
    procedure(Config: TMVCConfig)
    begin
      //enable static files
      Config[TMVCConfigKey.DocumentRoot] := TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'www');
      // session timeout (0 means session cookie)
      Config[TMVCConfigKey.SessionTimeout] := '0';
      //default content-type
      Config[TMVCConfigKey.DefaultContentType] := TMVCConstants.DEFAULT_CONTENT_TYPE;
      //default content charset
      Config[TMVCConfigKey.DefaultContentCharset] := TMVCConstants.DEFAULT_CONTENT_CHARSET;
      //unhandled actions are permitted?
      Config[TMVCConfigKey.AllowUnhandledAction] := 'false';
      //default view file extension
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      //view path
      Config[TMVCConfigKey.ViewPath] := 'templates';
      //Max Record Count for automatic Entities CRUD
      Config[TMVCConfigKey.MaxEntitiesRecordCount] := '20';
      //Enable Server Signature in response
      Config[TMVCConfigKey.ExposeServerSignature] := 'false';
      // Define a default URL for requests that don't map to a route or a file (useful for client side web app)
      Config[TMVCConfigKey.FallbackResource] := 'index.html';
      // Max request size in bytes
      Config[TMVCConfigKey.MaxRequestSize] := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
    end);

  FMVC.AddController(TMyController);

  // To enable compression (deflate, gzip) just add this middleware as the last one
  FMVC.AddMiddleware(TMVCCompressionMiddleware.Create);

  FMVC.AddMiddleware(
    TMVCBasicAuthenticationMiddleware.Create(
      TMVCDefaultAuthenticationHandler.New
      .SetOnAuthentication(
        procedure(const AUserName, APassword: string;
          AUserRoles: TList<string>; var IsValid: Boolean;
          const ASessionData: TDictionary<String, String>)
        begin
          IsValid := AUserName.Equals('usu') and APassword.Equals('123');
        end
      )
    )
  );
end;

procedure TMyWebModule.WebModuleDestroy(Sender: TObject);
begin
  FMVC.Free;
end;

end.
