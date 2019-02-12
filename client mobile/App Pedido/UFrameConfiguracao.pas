unit UFrameConfiguracao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrameConfiguracao = class(TFrame)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Label1: TLabel;
    EdtIP: TEdit;
    Label2: TLabel;
    EdtPorta: TEdit;
  private

  public
    procedure CarregarConfiguracoes;
    procedure SalvarConfiguracoes;
  end;

implementation

{$R *.fmx}

uses
  UConfigClass, FMX.DialogService.Async;

procedure TFrameConfiguracao.SalvarConfiguracoes;
begin
  TDialogServiceAsync.MessageDialog(
    'Deseja gravar e utilizar as configurações feitas?',
    System.UITypes.TMsgDlgType.mtConfirmation,
    [System.UITypes.TMsgDlgBtn.mbYes, System.UITypes.TMsgDlgBtn.mbNo],
    System.UITypes.TMsgDlgBtn.mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
      begin
        ConfigFile.IpServidor := EdtIP.Text;
        ConfigFile.Porta      := StrToInt(EdtPorta.Text);
      end;
    end
  );
end;

procedure TFrameConfiguracao.CarregarConfiguracoes;
begin
  EdtIP.Text    := ConfigFile.IpServidor;
  EdtPorta.Text := ConfigFile.Porta.ToString;
end;

end.
