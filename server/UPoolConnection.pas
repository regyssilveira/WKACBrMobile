unit UPoolConnection;

interface

uses
  System.SysUtils, System.Classes,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, Data.DB, FireDAC.Comp.Client,
  FireDAC.Phys.FBDef, FireDAC.Phys.IBBase, FireDAC.Phys.FB;

procedure ConfigurarPoolConnection;

const
  NOME_CONEXAO_FB = 'CONEXAO_SERVIDOR_DMC';

implementation

uses
  UConfigClass;

procedure ConfigurarPoolConnection;
var
  oParametros: TStringList;
begin
  FDManager.Close;

  oParametros := TStringList.Create;
  try
    oParametros.Clear;
    oParametros.Add('DriverID=FB');
    oParametros.Add('User_Name=sysdba');
    oParametros.Add('Password=masterkey');
    oParametros.Add('Protocol=TCPIP');
    oParametros.Add('CharacterSet=WIN1252');
    oParametros.Add('Server='   + ConfigServer.IP);
    oParametros.Add('Port='     + ConfigServer.Porta.ToString);
    oParametros.Add('Database=' + ConfigServer.Path);

    // parametros para o controle do pool se necessário e quiser alterar
    //oParametros.Add('POOL_MaximumItems=50');
    //oParametros.Add('POOL_ExpireTimeout=9000');
    //oParametros.Add('POOL_CleanupTimeout=900000');

    FDManager.AddConnectionDef(NOME_CONEXAO_FB, 'FB', oParametros);
    FDManager.Open;
  finally
    oParametros.Free;
  end;
end;

end.
