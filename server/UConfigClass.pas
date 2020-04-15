unit UConfigClass;

interface

uses
  SysUtils,
  IniFiles;

type
  TTipoAplicacao = (tpNFCe, tpSAT);

  TConfigServer = class(TIniFile)
  const
    S_CONFIG = 'config';
    ID_IP    = 'ip';
    ID_PORTA = 'porta';
    ID_PATH  = 'path';
    ID_TIPO  = 'tipo';
  private
    function GetIP: string;
    procedure SetIP(const Value: string);
    function GetPorta: Integer;
    procedure SetPorta(const Value: Integer);
    function GetPath: string;
    procedure SetPath(const Value: string);
    function GetTipo: TTipoAplicacao;
    procedure SetTipo(const Value: TTipoAplicacao);
  public
    function ConnectionString: string;

    property IP: string read GetIP write SetIP;
    property Porta: Integer read GetPorta write SetPorta;
    property Path: string read GetPath write SetPath;
    property Tipo: TTipoAplicacao read GetTipo write SetTipo;
  end;

var
  ConfigServer: TConfigServer;

implementation

{ TConfigServer }

function TConfigServer.ConnectionString: string;
begin
  Result := Self.IP + '/' + Self.Porta.ToString + ':' + Self.Path;
end;

function TConfigServer.GetIP: string;
begin
  Result := Self.ReadString(S_CONFIG, ID_IP, 'localhost');
end;

function TConfigServer.GetPath: string;
begin
  Result := Self.ReadString(S_CONFIG, ID_PATH, EmptyStr);
end;

function TConfigServer.GetPorta: Integer;
begin
  Result := Self.ReadInteger(S_CONFIG, ID_PORTA, 3050);
end;

function TConfigServer.GetTipo: TTipoAplicacao;
begin
  Result := TTipoAplicacao(Self.ReadInteger(S_CONFIG, ID_TIPO, 0));
end;

procedure TConfigServer.SetIP(const Value: string);
begin
  Self.WriteString(S_CONFIG, ID_IP, Value);
end;

procedure TConfigServer.SetPath(const Value: string);
begin
  Self.WriteString(S_CONFIG, ID_PATH, Value);
end;

procedure TConfigServer.SetPorta(const Value: Integer);
begin
  Self.WriteInteger(S_CONFIG, ID_PORTA, Value);
end;

procedure TConfigServer.SetTipo(const Value: TTipoAplicacao);
begin
  Self.WriteInteger(S_CONFIG, ID_TIPO, Integer(Value));
end;

initialization
  ConfigServer := TConfigServer.Create(ExtractFilePath(ParamStr(0)) + 'config.ini');

finalization
  ConfigServer.Free;

end.
