unit AQConfig;

interface

uses
  System.JSON, System.Classes, ListenerInfo, System.Generics.Collections, ObjectsMappers;

type

  /// <sumary>
  /// Mutable data type to store the active queue configuration.
  /// It is made mutable in order to be able to populate its fields from a json
  /// using the DMVCFramework means.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAQConfig = class
  const
    PORT_KEY_NAME = 'port';
    IPS_KEY_NAME = 'ips';
    SUBSCRIPTIONS_KEY_NAME = 'subscriptions';
  strict private
    FPort: Integer;
    FIPs: TArray<String>;
    FListeners: TObjectList<TListenerInfo>;
    function GetIps(): TArray<String>;
  public
    constructor Create(const Port: Integer; const IPs: TStringList);
    destructor Destroy; override;
    /// <summary>Creates a new instance with values taken from given json object.</summary>
    /// <param name="jo">values of this object are to be used to initialize properties
    /// of returned instance.</name>
    class function LoadFromJson(const jo: TJsonObject): TAQConfig;

    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;

    /// <summary> white list of ips from which the subscriptions are allowed.
    /// Subscription request coming from any other ip is to be ignored.</summary>
    [MapperJSONSer('ips')]
    property IPs: TArray<String> read GetIPs write FIPs;
    /// <summary> list of subscribed listeners</summary>
    [MapperJSONSer('listeners')]
    property Listeners: TObjectList<TListenerInfo> read FListeners write FListeners;

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
  FListeners := TObjectList<TListenerInfo>.Create();
  S := IPs.Count;
  Setlength(FIPs, S);
  for I := 0 to S - 1 do
    FIPs[I] := IPs[I];
end;

destructor TAQConfig.Destroy;
begin
  FListeners.Clear;
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
  Port, ListenerNum: Integer;
  Item, PortJValue, IPsJValue, ListenersJValue: TJsonValue;
  IPs: TStringList;
  Listeners: TArray<TListenerInfo>;
  ipsJArr, ListenersJArr: TJsonArray;
  I: Integer;
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
  ListenersJValue := jo.GetValue(SUBSCRIPTIONS_KEY_NAME);
  if (ListenersJValue <> nil) AND (ListenersJValue is TJsonArray) then
  begin
    ListenersJArr := ListenersJValue as TJsonArray;
    ListenerNum := ListenersJArr.Count;
    Listeners := TArray<TListenerInfo>.Create();
    SetLength(Listeners, ListenerNum);
    // for I := 0 to ListenerNum - 1 do
    // Listeners[I] := ListenersJArr.Items[I];
  end;
  Result := TAQConfig.Create(Port, IPs);
end;

end.
