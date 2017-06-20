unit DispatcherConfig;

interface

uses
  System.JSON;

type
  TDispatcherConfig = class(TObject)
  strict private
  const
    PORT_KEY = 'port';

  var
    FPort: Integer;
  public
    class
      function CreateFromJson(const Json: TJsonObject): TDispatcherConfig;
    constructor Create(const Port: Integer); overload;
    destructor Destroy(); override;
    property Port: Integer read FPort;
  end;

implementation

uses
  System.SysUtils;

{ TDispatcherConfig }

class function TDispatcherConfig.CreateFromJson(const Json: TJsonObject): TDispatcherConfig;
var
  Port: Integer;
  JValue: TJsonValue;
begin
  JValue := Json.GetValue(PORT_KEY);
  if JValue <> nil then
  begin
    try
      Port := strtoint(JValue.value);
    except
      on E: Exception do
        Port := -1;
    end;
  end;
  if Port > 0 then
    Result := TDispatcherConfig.Create(Port)
  else
    raise Exception.Create('DipatcherConfig: no valid port number is found in the config. file.');
end;

constructor TDispatcherConfig.Create(const Port: Integer);
begin
  FPort := Port;
end;

destructor TDispatcherConfig.Destroy;
begin
  inherited;
end;

end.
