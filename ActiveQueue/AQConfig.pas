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
    IPS_KEY_NAME_LISTENERS = 'ip-listeners';
    IPS_KEY_NAME_PROVIDERS = 'ip-providers';
    SUBSCRIPTIONS_KEY_NAME = 'subscriptions';
  strict private
    FPort: Integer;
    ///
    FListenersIPs: String;
    FIPList: TArray<String>;
    FListeners: TObjectList<TListenerInfo>;

  public
    constructor Create(const Port: Integer; const IPs: String; const Listeners: TObjectList<TListenerInfo>); overload;
    constructor Create(const Port: Integer; const IPs: String); overload;
    constructor Create(); overload;

    /// <summary>Set the listeners. Performs a defencive copying.</summary>
    procedure SetListeners(const Listeners: TObjectList<TListenerInfo>);

    /// <summary>Get the listeners. Performs a defencive copying.</summary>
    function GetListeners(): TObjectList<TListenerInfo>;

    destructor Destroy; override;

    /// <summary>Return a list of ips from which the subscriptions are allowed</summary>
    function GetListenersIps(): TArray<String>;

    /// <summary>Set ip from which the subscription requests are allowed.</summary>
    /// <param name="IPs">Comma-separated list of ips. Trailing white spaces
    /// are to be trimmed</param>
    procedure SetListenersIPs(const IPs: String);

    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;

    /// <summary> comma-separated list of ips from which the subscriptions are allowed.
    /// A subscription request originating from an ip not present in this string is to be ignored.</summary>
    [MapperJSONSer('ips')]
    property ListenersIPs: String read FListenersIPs write SetListenersIPs;

    /// <summary> comma-separated list of ips of providers that are allowed to enqueue the items.
    /// Any request to put a request into the queue originating from an ip not present in this string is to be ignored.</summary>
    [MapperJSONSer('providers-ips')]
    property ProvidersIPs: String read FListenersIPs write SetListenersIPs;

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
begin
  Create(Port, IPs, TObjectList<TListenerInfo>.Create());
end;

constructor TAQConfig.Create;
begin
  Create(0, '', TObjectList<TListenerInfo>.Create());
end;

constructor TAQConfig.Create(const Port: Integer; const IPs: String;
  const Listeners: TObjectList<TListenerInfo>);
var
  I, S: Integer;
  IPsArr: TArray<String>;
begin
  FPort := Port;
  FListenersIPs := IPs;
  FIPList := TArray<String>.Create();
  SetListenersIPs(IPs);
  FListeners := TObjectList<TListenerInfo>.Create();
  SetListeners(Listeners);
end;

destructor TAQConfig.Destroy;
begin
  FListeners.Clear;
  SetLength(FIPList, 0);
  inherited;
end;

function TAQConfig.GetListenersIps: TArray<String>;
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

function TAQConfig.GetListeners: TObjectList<TListenerInfo>;
var
  listener: TListenerInfo;
begin
  Result := TObjectList<TListenerInfo>.Create();
  if Assigned(FListeners) then
  begin
    for listener in FListeners do
      Result.Add(TListenerInfoBuilder.Create()
        .SetToken(Listener.token)
        .SetIP(Listener.IP)
        .SetPort(Listener.Port)
        .SetPath(Listener.Path).Build);
  end;

end;

procedure TAQConfig.SetListenersIPs(const IPs: String);
var
  items: TStringDynArray;
  S, I: Integer;
begin
  /// clean the previously set values
  SetLength(FIPList, 0);
  FListenersIPs := IPs;
  Items := SplitString(IPs, ',');
  S := Length(items);
  SetLength(FIPList, S);
  for I := 0 to S - 1 do
    FIPList[I] := Items[I].Trim;
end;

procedure TAQConfig.SetListeners(const Listeners: TObjectList<TListenerInfo>);
var
  Listener: TListenerInfo;
begin
  if Assigned(FListeners) then
  begin
    FListeners.Clear;
    FListeners.DisposeOf;
  end;
  FListeners := TObjectList<TListenerInfo>.Create();
  for Listener in Listeners do
  begin
    FListeners.Add(TListenerInfoBuilder.Create()
      .SetToken(Listener.token)
      .SetIP(Listener.IP)
      .SetPort(Listener.Port)
      .SetPath(Listener.Path).Build);
  end;

end;

end.
