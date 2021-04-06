unit UPrincipal;

interface

uses
  System.IOUtils,
  System.Permissions,

  {$IFDEF ANDROID}
    Androidapi.JNI.GraphicsContentViewText,
    Androidapi.JNI.JavaTypes,
    Androidapi.JNI.Net,
    Androidapi.JNI.Os,
    Androidapi.Helpers,
  {$ENDIF}

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.TabControl, FMX.Controls.Presentation, FMX.Objects,
  UFrameConfiguracao, UFrameAtualizar, UFramePedido, System.Actions,
  FMX.ActnList, FMX.MultiView;

type
  TForm1 = class(TForm)
    ToolBar1: TToolBar;
    TbcPrincipal: TTabControl;
    TabMenu: TTabItem;
    TabConfiguracao: TTabItem;
    TabVenda: TTabItem;
    Layout2: TLayout;
    Label1: TLabel;
    GridPanelLayout1: TGridPanelLayout;
    layPedido: TLayout;
    Image1: TImage;
    Label2: TLabel;
    LayAtualizar: TLayout;
    Image3: TImage;
    Label4: TLabel;
    LayConfiguracao: TLayout;
    Image4: TImage;
    Label5: TLabel;
    rectPedido: TRectangle;
    rectAtualizar: TRectangle;
    RectConfigurar: TRectangle;
    FrameConfiguracao1: TFrameConfiguracao;
    TabAtualizacao: TTabItem;
    FrameAtualizar1: TFrameAtualizar;
    FramePedido1: TFramePedido;
    ActionList1: TActionList;
    ChangeTabAction1: TChangeTabAction;
    ActionList2: TActionList;
    ChangeTabAction2: TChangeTabAction;
    MultiView1: TMultiView;
    Label3: TLabel;
    BtnVoltar: TSpeedButton;
    BtnConfirmar: TSpeedButton;
    StyleBook1: TStyleBook;
    BtnRequisitarPermissoes: TButton;
    procedure BtnVoltarClick(Sender: TObject);
    procedure BtnConfirmarClick(Sender: TObject);
    procedure TbcPrincipalChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure rectPedidoClick(Sender: TObject);
    procedure rectAtualizarClick(Sender: TObject);
    procedure RectConfigurarClick(Sender: TObject);
    procedure BtnRequisitarPermissoesClick(Sender: TObject);
    procedure OnRequestPermissions(Sender: TObject; const APermissions: TArray<string>;
      const AGrantResults: TArray<TPermissionStatus>);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  DPrincipal;

procedure TForm1.TbcPrincipalChange(Sender: TObject);
begin
  BtnVoltar.Visible    := TbcPrincipal.ActiveTab <> TabMenu;
  BtnConfirmar.Visible := TbcPrincipal.ActiveTab <> TabMenu;
end;

procedure TForm1.BtnConfirmarClick(Sender: TObject);
begin
  // botão de confirmar
  case TbcPrincipal.TabIndex of
    1:
      begin
        FramePedido1.EnviarPedido;
      end;

    2:
      begin
        FrameConfiguracao1.SalvarConfiguracoes;
      end;
  end;
end;

procedure TForm1.BtnRequisitarPermissoesClick(Sender: TObject);
begin
  PermissionsService.RequestPermissions(
    [
      JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE),
      JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE)
    ],
    OnRequestPermissions
  );
end;

procedure TForm1.OnRequestPermissions(Sender: TObject; const APermissions: TArray<string>;
  const AGrantResults: TArray<TPermissionStatus>);
begin
  if (Length(AGrantResults) = 2) and
     (AGrantResults[0] = TPermissionStatus.Granted) and
     (AGrantResults[1] = TPermissionStatus.Granted) then
  begin
    ShowMessage('Você um usuário legal, obrigado por liberar o acesso a memória!')
  end
  else
    ShowMessage('Sem acesso a memória você tera problema ao finalizar o pedido!');
end;

procedure TForm1.BtnVoltarClick(Sender: TObject);
begin
  ChangeTabAction1.Tab := TabMenu;
  ChangeTabAction1.Execute;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char;
  Shift: TShiftState);
begin
  if Key = vkBack then
  begin
    if BtnVoltar.Visible then
      BtnVoltarClick(BtnVoltar);
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  MultiView1.Visible := False;
  TbcPrincipal.ActiveTab := TabMenu;

  TbcPrincipalChange(TbcPrincipal);
  FrameConfiguracao1.CarregarConfiguracoes;
end;

procedure TForm1.rectAtualizarClick(Sender: TObject);
begin
  ChangeTabAction1.Tab := TabAtualizacao;
  ChangeTabAction1.Execute;
end;

procedure TForm1.RectConfigurarClick(Sender: TObject);
begin
  ChangeTabAction1.Tab := TabConfiguracao;
  ChangeTabAction1.Execute;
end;

procedure TForm1.rectPedidoClick(Sender: TObject);
begin
  FramePedido1.Inicializar;

  ChangeTabAction1.Tab := TabVenda;
  ChangeTabAction1.Execute;
end;

end.

