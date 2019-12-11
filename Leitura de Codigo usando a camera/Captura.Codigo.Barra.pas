unit Captura.Codigo.Barra;

interface

uses
  //System.Permissions,
  System.Threading,

  ZXing.BarcodeFormat,
  ZXing.ReadResult,
  ZXing.ScanManager,

  FMX.Platform,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  System.Math.Vectors, FMX.StdCtrls, FMX.Media, FMX.Controls3D, FMX.ScrollBox,
  FMX.Memo, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts, FMX.Edit;

type
  TFrmCapturaCodigoBarra = class(TForm)
    Layout2: TLayout;
    ToolBar1: TToolBar;
    btnMenu: TButton;
    lblScanStatus: TLabel;
    imgCamera: TImage;
    Camera1: TCamera;
    CameraComponent1: TCameraComponent;
    ToolBar2: TToolBar;
    Label1: TLabel;
    Layout1: TLayout;
    BtnVoltar: TSpeedButton;
    Layout3: TLayout;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CameraComponent1SampleBufferReady(Sender: TObject;
      const ATime: TMediaTime);
    procedure BtnVoltarClick(Sender: TObject);
  private
    FscanBitmap: TBitmap;
//    FPermissionCamera : String;
    FScanManager: TScanManager;
    FScanInProgress: Boolean;
    FFrameTake: Integer;
    FEditRecebe: TEdit;
    FCodigoBarra: string;

    function AppEvent(AAppEvent: TApplicationEvent; AContext: TObject): Boolean;
//    procedure CameraPermissionRequestResult(Sender: TObject;
//      const APermissions: TArray<string>;
//      const AGrantResults: TArray<TPermissionStatus>);
//    procedure ExplainReason(Sender: TObject; const APermissions: TArray<string>;
//      const APostRationaleProc: TProc);
    procedure GetImage;
  public
    class function ShowCapturaCodigoBarra(AOwner: TComponent; AEditRecebe: TEdit): string;

    property EditRecebe: TEdit read FEditRecebe write FEditRecebe;
  end;

var
  FrmCapturaCodigoBarra: TFrmCapturaCodigoBarra;

implementation

uses
{$IFDEF ANDROID}
  Androidapi.Helpers,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Os,
{$ENDIF}
  FMX.DialogService, Principal;

{$R *.fmx}

class function TFrmCapturaCodigoBarra.ShowCapturaCodigoBarra(
  AOwner: TComponent; AEditRecebe: TEdit): string;
begin
  Result := '';
  AEditRecebe.Text := '';

  FrmCapturaCodigoBarra.EditRecebe := AEditRecebe;
  FrmCapturaCodigoBarra.ShowModal(
    procedure(Resposta: TModalResult)
    begin
      if Resposta = mrOK then
      begin

      end;
    end
  );
end;

procedure TFrmCapturaCodigoBarra.GetImage;
var
  ReadResult: TReadResult;
begin
  CameraComponent1.SampleBufferToBitmap(imgCamera.Bitmap, True);

  if (FScanInProgress) then
    exit;

  inc(FFrameTake);
  if (FFrameTake mod 4 <> 0) then
    exit;

  FscanBitmap.Assign(imgCamera.Bitmap);
  ReadResult := nil;

  TTask.Run(
    procedure
    begin
      try
        FScanInProgress := True;
        try
          ReadResult := FScanManager.Scan(FscanBitmap);
        except
          on E: Exception do
          begin
            TThread.Synchronize(nil,
              procedure
              begin
                lblScanStatus.Text := E.Message;
              end);

            exit;
          end;
        end;

        TThread.Synchronize(nil,
          procedure
          begin
            if (ReadResult <> nil) then
            begin
              FCodigoBarra := ReadResult.Text.Trim;
              if not FCodigoBarra.IsEmpty then
              begin
                CameraComponent1.Active := False;
                Self.EditRecebe.Text    := FCodigoBarra;

                Self.Close;
                Self.ModalResult := mrOk;
              end;
            end;
          end
        );
      finally
        ReadResult.Free;
        FScanInProgress := false;
      end;
    end
  );
end;

function TFrmCapturaCodigoBarra.AppEvent(AAppEvent: TApplicationEvent;
AContext: TObject): Boolean;
begin
  Result := False;

  case AAppEvent of
    TApplicationEvent.WillBecomeInactive,
    TApplicationEvent.EnteredBackground,
    TApplicationEvent.WillTerminate:
      begin
        CameraComponent1.Active := false;
        Result := True;
      end;
  end;
end;

//procedure TFrmCapturaCodigoBarra.CameraPermissionRequestResult(
//  Sender: TObject; const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
//begin
//  if (Length(AGrantResults) = 1) and (AGrantResults[0] = TPermissionStatus.Granted) then
//  begin
//    CameraComponent1.Active    := False;
//    CameraComponent1.Quality   := FMX.Media.TVideoCaptureQuality.CaptureSettings;
//    CameraComponent1.Kind      := FMX.Media.TCameraKind.BackCamera;
//    CameraComponent1.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
//    CameraComponent1.Active    := True;
//    lblScanStatus.Text         := '';
//    FCodigoBarra               := '';
//  end
//  else
//    TDialogService.ShowMessage('Não foi possível utilizar a camêra pois não foram concedidads as permissões de uso!')
//end;
//
//procedure TFrmCapturaCodigoBarra.ExplainReason(
//  Sender: TObject; const APermissions: TArray<string>; const APostRationaleProc: TProc);
//begin
//  TDialogService.ShowMessage(
//    'O aplicativo precisa de acesso a camêra para continuar...',
//    procedure(const AResult: TModalResult)
//    begin
//      APostRationaleProc;
//    end
//  );
//end;

procedure TFrmCapturaCodigoBarra.FormCreate(Sender: TObject);
var
  AppEventSvc: IFMXApplicationEventService;
begin
  FscanBitmap := TBitmap.Create;

  if TPlatformServices.Current.SupportsPlatformService
    (IFMXApplicationEventService, IInterface(AppEventSvc)) then
  begin
    AppEventSvc.SetApplicationEventHandler(AppEvent);
  end;

  lblScanStatus.Text := '';
  FFrameTake   := 0;
  FScanManager := TScanManager.Create(TBarcodeFormat.Auto, nil);

//  {$IFDEF ANDROID}
//  FPermissionCamera := JStringToString(TJManifest_permission.JavaClass.CAMERA);
//  {$EndIf}
end;

procedure TFrmCapturaCodigoBarra.FormDestroy(Sender: TObject);
begin
  CameraComponent1.Active := false;
  FScanManager.Free;
  FscanBitmap.Free;
end;

procedure TFrmCapturaCodigoBarra.FormShow(Sender: TObject);
begin
//  PermissionsService.RequestPermissions(
//    [FPermissionCamera],
//    CameraPermissionRequestResult,
//    ExplainReason
//  );

  lblScanStatus.Text         := '';
  FCodigoBarra               := '';

  CameraComponent1.Active    := False;
  CameraComponent1.Quality   := FMX.Media.TVideoCaptureQuality.PhotoQuality;
  CameraComponent1.Kind      := FMX.Media.TCameraKind.BackCamera;
  CameraComponent1.FocusMode := FMX.Media.TFocusMode.ContinuousAutoFocus;
  CameraComponent1.Active    := True;
end;

procedure TFrmCapturaCodigoBarra.CameraComponent1SampleBufferReady(
  Sender: TObject; const ATime: TMediaTime);
begin
  TThread.Synchronize(TThread.CurrentThread, GetImage);
end;

procedure TFrmCapturaCodigoBarra.BtnVoltarClick(Sender: TObject);
begin
  CameraComponent1.Active := False;

  Self.EditRecebe.Text := '';

  Self.Close;
  Self.ModalResult := mrCancel;
end;

end.
