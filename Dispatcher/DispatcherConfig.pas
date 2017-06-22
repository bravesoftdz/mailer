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

  var
    FPort: Integer;
    FClientIPs: String;
  public
    class
      function CreateFromJson(const Json: TJsonObject): TDispatcherConfig;
    destructor Destroy(); override;
    constructor Create(const Port: Integer; const ClientIPs: String);
    property Port: Integer read FPort;
    property ClientIPs: String read FClientIPs;
  end;

implementation

uses
  System.SysUtils, System.StrUtils;

{ TDispatcherConfig }

class function TDispatcherConfig.CreateFromJson(const Json: TJsonObject): TDispatcherConfig;
var
  Port: Integer;
  IPs: String;
begin
  Port := GetIntValue(Json, PORT_KEY, -1);
  if Port <= 0 then
  begin
    raise Exception.Create('DipatcherConfig: port number must be a positive integer.');
  end;
  IPs := GetStrValue(Json, CLIENT_WHITELIST_KEY, '');
  Result := TDispatcherConfig.Create(Port, IPs);
end;

constructor TDispatcherConfig.Create(const Port: Integer; const ClientIPs: String);
begin
  FPort := Port;
  FClientIPs := ClientIPs;
end;

destructor TDispatcherConfig.Destroy;
begin
  inherited;
end;

end.
