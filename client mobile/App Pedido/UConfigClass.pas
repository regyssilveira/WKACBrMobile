unit UConfigClass;

interface

uses
  System.IniFiles, System.Classes, System.SysUtils;

type
  TConfigFile = class(TIniFile)
  private
    function GetIpServidor: String;
    function GetPorta: Integer;
    procedure SetIpServidor(const Value: String);
    procedure SetPorta(const Value: Integer);
  public
    property IpServidor: String read GetIpServidor write SetIpServidor;
    property Porta: Integer     read GetPorta      write SetPorta;
  end;

var
  ConfigFile: TConfigFile;

implementation

uses
  System.IOUtils;

{ TConfigFile }

function TConfigFile.GetIpServidor: String;
begin
  Result := Self.ReadString('CONFIG', 'IpServidor', '');
  if (Pos('http', Result) <= 0) and not(Result.Trim.IsEmpty) then
    Result := 'http://' + Result;
end;

function TConfigFile.GetPorta: Integer;
begin
  Result := Self.ReadInteger('CONFIG', 'Porta', 8080);
end;

procedure TConfigFile.SetIpServidor(const Value: String);
begin
  Self.WriteString('CONFIG', 'IpServidor', Value);
  Self.UpdateFile;
end;

procedure TConfigFile.SetPorta(const Value: Integer);
begin
  Self.WriteInteger('CONFIG', 'Porta', Value);
  Self.UpdateFile;
end;

initialization
  ConfigFile := TConfigFile.Create(
    TPath.Combine(TPath.GetDocumentsPath, 'AppPedido.ini')
  );

finalization
  ConfigFile.DisposeOf;

end.
