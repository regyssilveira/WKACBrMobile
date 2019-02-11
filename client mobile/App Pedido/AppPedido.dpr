program AppPedido;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'UPrincipal.pas' {Form1},
  UConfigClass in 'UConfigClass.pas',
  UFrameConfiguracao in 'UFrameConfiguracao.pas' {FrameConfiguracao: TFrame},
  UFrameAtualizar in 'UFrameAtualizar.pas' {FrameAtualizar: TFrame},
  DPrincipal in 'DPrincipal.pas' {DtmPrincipal: TDataModule},
  UFramePedido in 'UFramePedido.pas' {FramePedido: TFrame},
  UNFCeClass in '..\..\comum\UNFCeClass.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Portrait];
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TDtmPrincipal, DtmPrincipal);
  Application.Run;
end.
