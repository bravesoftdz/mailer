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
    FIPs: String;
    FIPList: TArray<String>;
    FListeners: TObjectList<TListenerInfo>;

  public
    constructor Create(const Port: Integer; const IPs: String); overload;
    constructor Create(); overload;
    destructor Destroy; override;
    /// <summary>Creates a new instance with values taken from given json object.</summary>
    /// <param name="jo">values of this object are to be used to initialize properties
    /// of returned instance.</name>
    class function LoadFromJson(const jo: TJsonObject): TAQConfig;

    /// <summary>Return a list of ips from which the seubscriptions are allowed</summary>
    function GetIps(): TArray<String>;
    /// <summary>Set ip from which the subscription requests are allowed.</summary>
    /// <param name="IPs">Comma-separated list of ips. Trailing white spaces
    /// are to be trimmed</param>
    procedure SetIPs(const IPs: String);

    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;

    /// <summary> comma-separated list of ips from which the subscriptions are allowed.
    /// Any subscription request originating from any other ip is to be ignored.</summary>
    [MapperJSONSer('ips')]
    property IPs: String read FIPs write setIPs;
    /// <summary> list of subscribed listeners</summary>
    [MapperJSONSer('listeners')]
    [MapperListOf(TListenerInfo)]
    property Listeners: TObjectList<TListenerInfo> read FListeners write FListeners;

  end;

implementation

uses
  System.SysUtils, System.Types, System.StrUtils;

{ TAQConfig }

constructor TAQConfig.Create(const Port: Integer; const IPs: String);
var
  I, S: Integer;
  IPsArr: TArray<String>;
  items: TStringDynArray;
begin
  FPort := Port;
  FIPs := IPs;
  FIPList := TArray<String>.Create();
  FListeners := TObjectList<TListenerInfo>.Create();
  SetIPs(IPs);
end;

constructor TAQConfig.Create;
begin
  FListeners := TObjectList<TListenerInfo>.Create();
  FIPs := '';
  FIPList := TArray<String>.Create();
  Setlength(FIPList, 0);
end;

destructor TAQConfig.Destroy;
begin
  FListeners.Clear;
  SetLength(FIPList, 0);
  inherited;
end;

function TAQConfig.GetIps: TArray<String>;
var
  I, S: Integer;
begin
  If Assigned(FIPList) then
    S := Length(FIPList)
  else
    S := 0;
  Result := TArray<String>.Create();
  SetLength(Result, S);
  for I := 0 to S - 1 do
    Result[I] := FIPList[I];
end;

class function TAQConfig.LoadFromJson(const jo: TJsonObject): TAQConfig;
var
  Port, ListenerNum: Integer;
  Item, PortJValue, IPsJValue, ListenersJValue: TJsonValue;
  IPs: String;
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
  if (IPsJValue <> nil) then
  begin
    IPs := IPsJValue.Value;
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

procedure TAQConfig.SetIPs(const IPs: String);
var
  items: TStringDynArray;
  S, I: Integer;
begin
  /// clean the previously set values
  SetLength(FIPList, 0);
  FIPs := IPs;
  Items := SplitString(IPs, ',');
  S := Length(items);
  SetLength(FIPList, S);
  for I := 0 to S - 1 do
    FIPList[I] := Items[I].Trim;
end;

end.
