unit DispatcherConfig;

interface

uses
  System.JSON, Configuration;

type
  TDispatcherConfig = class(TConfiguration)
  strict private
  const
    PORT_KEY = 'port';
    CLIENT_WHITELIST_KEY = 'client-whitelist-ip';
    BACKEND_IP_KEY = 'backend-ip';
    BACKEND_PORT_KEY = 'backend-port';
    TOKEN_KEY = 'token';

  var
    FPort: Integer;
    FClientIPs: String;
    FBackEndIp: String;
    FBackEndPort: Integer;
    FToken: String;
  public
    class
      function CreateFromJson(const Json: TJsonObject): TDispatcherConfig;
    destructor Destroy(); override;
    constructor Create(const Port: Integer; const ClientIPs: String; const BackEndIp: String; const BackEndPort: Integer; const Token: String);
    property Port: Integer read FPort;
    property ClientIPs: String read FClientIPs;
    property BackEndIp: String read FBackEndIp;
    property Token: String read FToken;
    property BackEndPort: Integer read FBackEndPort;
  end;

implementation

uses
  System.SysUtils, System.StrUtils;

{ TDispatcherConfig }

class function TDispatcherConfig.CreateFromJson(const Json: TJsonObject): TDispatcherConfig;
var
  Port, BackEndPort: Integer;
  IPs, BackEndIp, Token: String;
begin
  Port := GetIntValue(Json, PORT_KEY, -1);
  if Port <= 0 then
  begin
    raise Exception.Create('DipatcherConfig: port number must be a positive integer.');
  end;
  IPs := GetStrValue(Json, CLIENT_WHITELIST_KEY, '');
  BackEndIP := GetStrValue(Json, BACKEND_IP_KEY, '');
  Token := GetStrValue(Json, TOKEN_KEY, '');
  BackEndPort := GetIntValue(Json, BACKEND_PORT_KEY, -1);
  Result := TDispatcherConfig.Create(Port, IPs, BackEndIP, BackEndPort, Token);
end;

constructor TDispatcherConfig.Create(const Port: Integer; const ClientIPs: String; const BackEndIp: String; const BackEndPort: Integer; const Token: String);
begin
  FPort := Port;
  FClientIPs := ClientIPs;
  FBackEndPort := BackEndPort;
  FBackEndIp := BackEndIp;
  FToken := Token;
end;

destructor TDispatcherConfig.Destroy;
begin
  inherited;
end;

end.
