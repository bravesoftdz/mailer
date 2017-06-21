unit DispatcherConfig;

interface

uses
  System.JSON;

type
  TDispatcherConfig = class(TObject)
  strict private
  const
    PORT_KEY = 'port';
    CLIENT_WHITELIST_KEY = 'client-whitelist-ip';

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
  aString, aString2: String;
  JValue, JValue2: TJsonValue;
begin
  JValue := Json.GetValue(PORT_KEY);
  aString := JValue.value;
  if JValue <> nil then
  begin
    try
      Port := strtoint(aString);
    except
      on E: Exception do
        raise Exception.Create('DipatcherConfig: port number ' + aString + ' found in the config. file is not an integer.');
    end;
  end;
  JValue2 := Json.GetValue(CLIENT_WHITELIST_KEY);
  if JValue2 <> nil then
    aString2 := JValue.Value
  else
    aString2 := '';

  Result := TDispatcherConfig.Create(Port, aString2);

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
