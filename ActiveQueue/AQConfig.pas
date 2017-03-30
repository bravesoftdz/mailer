unit AQConfig;

interface

uses
  System.JSON, System.Classes;

type
  /// <sumary>
  /// Immutable data type to store the active queue configuration.
  /// </summary>
  TAQConfig = class
  const
    PORT_KEY_NAME = 'port';
    IPS_KEY_NAME = 'ips';

  strict private
    FPort: Integer;
    FIPs: TArray<String>;
    function GetIps(): TArray<String>;
  public
    constructor Create(const Port: Integer; const IPs: TStringList);
    destructor Destroy; override;
    /// <summary>Creates a new instance with values taken from given json object.</summary>
    /// <param name="jo">values of this object are to be used to initialize properties
    /// of returned instance.</name>
    class function LoadFromJson(const jo: TJsonObject): TAQConfig;

    /// <summary> Port at which the program accepts the connections.</summary>
    property Port: Integer read FPort;

    /// <summary> white list of ips from which the subscriptions are allowed.
    /// Subscription request coming from any other ip is to be ignored.</summary>
    property IPs: TArray<String> read GetIPs;

  end;

implementation

uses
  System.SysUtils;

{ TAQConfig }

constructor TAQConfig.Create(const Port: Integer; const IPs: TStringList);
var
  I, S: Integer;
begin
  FPort := Port;
  FIPs := TArray<String>.Create();
  S := IPs.Count;
  Setlength(FIPs, S);
  for I := 0 to S - 1 do
    FIPs[I] := IPs[I];
end;

destructor TAQConfig.Destroy;
begin
  inherited;
end;

function TAQConfig.GetIps: TArray<String>;
var
  I, S: Integer;
begin
  If Assigned(FIPs) then
    S := Length(FIPs)
  else
    S := 0;
  Result := TArray<String>.Create();
  SetLength(Result, S);
  for I := 0 to S - 1 do
    Result[I] := FIPs[I];
end;

class function TAQConfig.LoadFromJson(const jo: TJsonObject): TAQConfig;
var
  Port: Integer;
  Item, PortJValue, IPsJValue: TJsonValue;

  IPs: TStringList;
  ipsJArr: TJsonArray;
begin
  PortJValue := jo.getValue(PORT_KEY_NAME);
  if PortJValue <> nil then
    try
      Port := PortJValue.Value.ToInteger;
    except
      on E: Exception do
      begin
        Port := 0;
      end;
    end;
  IPsJValue := jo.GetValue(IPS_KEY_NAME);
  if (IPsJValue <> nil) AND (IPsJValue is TJsonArray) then
  begin
    ipsJArr := IPsJValue as TJsonArray;
    IPs := TStringList.Create;
    for Item in IPsJArr do
      IPs.Add(item.Value);
  end;
  Result := TAQConfig.Create(Port, IPs);
end;

end.
