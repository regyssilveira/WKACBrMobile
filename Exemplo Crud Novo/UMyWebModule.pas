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
      Config[TMVCConfigKey.DocumentRoot]             := TPath.Combine(ExtractFilePath(GetModuleName(HInstance)), 'www');
      Config[TMVCConfigKey.SessionTimeout]           := '0';
      Config[TMVCConfigKey.DefaultContentType]       := TMVCConstants.DEFAULT_CONTENT_TYPE;
      Config[TMVCConfigKey.DefaultContentCharset]    := TMVCConstants.DEFAULT_CONTENT_CHARSET;
      Config[TMVCConfigKey.AllowUnhandledAction]     := 'false';
      Config[TMVCConfigKey.DefaultViewFileExtension] := 'html';
      Config[TMVCConfigKey.ViewPath]                 := 'templates';
      Config[TMVCConfigKey.MaxEntitiesRecordCount]   := '20';
      Config[TMVCConfigKey.ExposeServerSignature]    := 'false';
      Config[TMVCConfigKey.FallbackResource]         := 'index.html';
      Config[TMVCConfigKey.MaxRequestSize]           := IntToStr(TMVCConstants.DEFAULT_MAX_REQUEST_SIZE);
      Config['redis_connection_string']              := '127.0.0.1:6379';
      Config['redis_connection_key']                 := '';
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
