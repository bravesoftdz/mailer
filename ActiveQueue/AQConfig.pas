unit AQConfig;

interface

uses
  System.JSON, System.Classes, ListenerInfo, System.Generics.Collections, ObjectsMappers,
  System.SysUtils, JsonableInterface;

type
  StringMapper = reference to function(const From: String): String;

type

  /// <summary>
  /// Mutable data type to store the active queue configuration.
  /// It is made mutable in order to be able to populate its fields from a json
  /// using the DMVCFramework means.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAQConfig = class(TInterfacedObject, JSonable)
  const
    PORT_KEY_NAME = 'port';
    IPS_KEY_NAME_LISTENERS = 'listeners-allowed-ips';
    IPS_KEY_NAME_PROVIDERS = 'providers-allowed-ips';
    SUBSCRIPTIONS_KEY_NAME = 'listeners';

  strict private
    FPort: Integer;
    FListenersAllowedIPs: String;
    FProvidersAllowedIPs: String;
    FListenersAllowedIPArray: TArray<String>;
    FProvidersAllowedIPArray: TArray<String>;
    FListeners: TObjectList<TListenerInfo>;
    /// <summary>a anonimous function that trims a string</summary>
    TrimMapper: StringMapper;

    /// <summary>Create a copy of given array. Its purpose is for defencive copying.</summary>
    function ApplyToEach(const Original: TArray<String>; const mapper: StringMapper): TArray<String>;

  public
    constructor Create(const Port: Integer; const ListenersIPs, ProvidersIPs: String; const Listeners: TObjectList<TListenerInfo>); overload;
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

    function ToJson(): TJsonObject;

    /// <summary>Return a list of ips from which the data can be accepted</summary>
    function GetProvidersIps(): TArray<String>;

    /// <summary>Set ip from which the data can be accepted.</summary>
    /// <param name="IPs">Comma-separated list of ips. Trailing white spaces
    /// are to be trimmed</param>
    procedure SetProvidersIPs(const IPs: String);

    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer(PORT_KEY_NAME)]
    property Port: Integer read FPort write FPort;

    /// <summary> comma-separated list of ips from which the subscriptions are allowed.
    /// A subscription request originating from an ip not present in this string is to be ignored.</summary>
    [MapperJSONSer(IPS_KEY_NAME_LISTENERS)]
    property ListenersIPs: String read FListenersAllowedIPs write SetListenersIPs;

    /// <summary> comma-separated list of ips of providers that are allowed to enqueue the items.
    /// Any request to put a request into the queue originating from an ip not present in this string is to be ignored.</summary>
    [MapperJSONSer(IPS_KEY_NAME_PROVIDERS)]
    property ProvidersIPs: String read FProvidersAllowedIPs write SetProvidersIPs;

    /// <summary> list of subscribed listeners</summary>
    [MapperJSONSer(SUBSCRIPTIONS_KEY_NAME)]
    [MapperListOf(TListenerInfo)]
    property Listeners: TObjectList<TListenerInfo> read FListeners write FListeners;

  end;

type
  TAQConfigBuilder = class
  strict private
    FPort: Integer;
    FListenerIPs: String;
    FProviderIPs: String;
    FListeners: TObjectList<TListenerInfo>;
    function Join(const Items: TArray<String>; const Separator: String): String;
  public
    function SetPort(const Port: Integer): TAQConfigBuilder;
    function SetListenerIPs(const IPs: String): TAQConfigBuilder; overload;
    function SetListenerIPs(const IPs: TArray<String>): TAQConfigBuilder; overload;
    function SetProviderIPs(const IPs: String): TAQConfigBuilder; overload;
    function SetProviderIPs(const IPs: TArray<String>): TAQConfigBuilder; overload;
    function SetListeners(const Listeners: TObjectList<TListenerInfo>): TAQConfigBuilder;
    function Build(): TAQConfig;
    constructor Create();

  end;

implementation

uses
  System.Types, System.StrUtils;

{ TAQConfig }

constructor TAQConfig.Create;
begin
  Create(0, '', '', TObjectList<TListenerInfo>.Create());
end;

constructor TAQConfig.Create(const Port: Integer; const ListenersIPs, ProvidersIPs: String; const Listeners: TObjectList<TListenerInfo>);
begin
  TrimMapper := Function(const From: String): String
    begin
      Result := From.Trim();
    End;

  FPort := Port;
  SetListenersIPs(ListenersIPs);
  SetProvidersIPs(ProvidersIPs);

  FListeners := TObjectList<TListenerInfo>.Create();
  SetListeners(Listeners);
end;

destructor TAQConfig.Destroy;
begin
  FListeners.Clear;
  SetLength(FListenersAllowedIPArray, 0);
  SetLength(FProvidersAllowedIPArray, 0);
  TrimMapper := nil;
  inherited;
end;

function TAQConfig.GetListenersIps: TArray<String>;
begin
  Result := ApplyToEach(FListenersAllowedIPArray, TrimMapper);
end;

function TAQConfig.ApplyToEach(const Original: TArray<String>; const Mapper: StringMapper): TArray<String>;
var
  I, S: Integer;
begin
  If Assigned(Original) then
    S := Length(Original)
  else
    S := 0;
  Result := TArray<String>.Create();
  SetLength(Result, S);
  for I := 0 to S - 1 do
    Result[I] := Mapper(Original[I]);
end;

function TAQConfig.GetProvidersIps: TArray<String>;
begin
  Result := ApplyToEach(FProvidersAllowedIPArray, TrimMapper);
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
  Items: TArray<String>;
begin
  /// clean the previously set values
  SetLength(FListenersAllowedIPArray, 0);
  FListenersAllowedIPs := IPs;
  Items := TArray<String>(SplitString(IPs, ','));
  FListenersAllowedIPArray := ApplyToEach(Items, TrimMapper);
end;

procedure TAQConfig.SetProvidersIPs(const IPs: String);
var
  items: TArray<String>;
begin
  /// clean the previously set values
  SetLength(FProvidersAllowedIPs, 0);
  FProvidersAllowedIPs := IPs;
  Items := TArray<String>(SplitString(IPs, ','));
  FProvidersAllowedIPArray := ApplyToEach(Items, TrimMapper);
end;

function TAQConfig.ToJson: TJsonObject;
var
  arr: TJsonArray;
  Listener: TListenerInfo;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TJsonPair.Create(PORT_KEY_NAME, TJsonNumber.Create(FPort)));
  Result.AddPair(TJsonPair.Create(IPS_KEY_NAME_LISTENERS, ListenersIPs));
  Result.AddPair(TJsonPair.Create(IPS_KEY_NAME_PROVIDERS, ProvidersIPs));
  arr := TJSonArray.Create();
  for Listener in FListeners do
    arr.AddElement(Listener.toJson());
  Result.AddPair(TJsonPair.Create(SUBSCRIPTIONS_KEY_NAME, arr));

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
  if Listeners <> nil then
  begin
    for Listener in Listeners do
    begin
      FListeners.Add(TListenerInfoBuilder.Create()
        .SetToken(Listener.token)
        .SetIP(Listener.IP)
        .SetPort(Listener.Port)
        .SetPath(Listener.Path).Build);
    end;
  end;

end;

{ TAQConfigBuilder }

function TAQConfigBuilder.Build: TAQConfig;
begin
  Result := TAQConfig.Create(FPort, FListenerIPs, FProviderIPs, FListeners);
end;

constructor TAQConfigBuilder.Create;
begin
  FPort := 0;
  FListenerIPs := '';
  FProviderIPs := '';
  FListeners := TObjectList<TListenerInfo>.Create();
end;

function TAQConfigBuilder.Join(const Items: TArray<String>; const Separator: String): String;
var
  I, L: Integer;
begin
  Result := '';
  L := Length(Items);
  for I := 0 to L - 2 do
    Result := Result + Items[I] + Separator;
  if L > 0 then
    Result := Result + Items[L - 1];

end;

function TAQConfigBuilder.SetListenerIPs(const IPs: String): TAQConfigBuilder;
begin
  FListenerIPs := IPs;
  Result := Self;
end;

function TAQConfigBuilder.SetListenerIPs(const IPs: TArray<String>): TAQConfigBuilder;
begin
  FListenerIPs := Join(IPs, ',');
  Result := Self;
end;

function TAQConfigBuilder.SetListeners(
  const Listeners: TObjectList<TListenerInfo>): TAQConfigBuilder;
var
  ListenerInfo: TListenerInfo;
begin
  FListeners.Clear;
  for ListenerInfo in Listeners do
  begin
    FListeners.Add(ListenerInfo);
  end;
  Result := Self;

end;

function TAQConfigBuilder.SetPort(const Port: Integer): TAQConfigBuilder;
begin
  FPort := Port;
  Result := Self;
end;

function TAQConfigBuilder.SetProviderIPs(const IPs: TArray<String>): TAQConfigBuilder;
begin
  FProviderIPs := Join(IPs, ',');
  Result := Self;
end;

function TAQConfigBuilder.SetProviderIPs(const IPs: String): TAQConfigBuilder;
begin
  FProviderIPs := IPs;
  Result := Self;
end;

end.
