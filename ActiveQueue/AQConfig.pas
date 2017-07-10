unit AQConfig;

interface

uses
  System.JSON, System.Classes, ObjectsMappers,
  System.SysUtils, JsonableInterface, System.Generics.Collections, Client, ListenerInfo;

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
  strict private
  const
    PORT_KEY = 'port';
    CLIENTS_KEY = 'clients';
    TOKEN_KEY = 'token';
    CONSUMER_IP_WHITELIST_KEY = 'consumer-ip-whitelist';
    CONSUMERS_KEY = 'consumers';
  protected
  var
    FPort: Integer;
    FToken: String;
    FClients: TObjectList<TClient>;
    FConsumerWhiteListIps: String;
    FConsumers: TObjectList<TListenerInfo>;

  public
    constructor Create(const Port: Integer; const TheClients: TObjectList<TClient>; const Token: String; const ConsumerWhiteList: String); overload;
    constructor Create(); overload;

    // /// <summary>Set the listeners. Performs a defencive copying.</summary>
    // procedure SetListeners(const Listeners: TObjectList<TListenerInfo>);
    //
    // /// <summary>Get the listeners. Performs a defencive copying.</summary>
    // function GetListeners(): TObjectList<TListenerInfo>;

    destructor Destroy; override;

    // /// <summary>Return a list of ips from which the subscriptions are allowed</summary>
    // function GetListenersIps(): TArray<String>;
    //
    // /// <summary>Set ip from which the subscription requests are allowed.</summary>
    // /// <param name="IPs">Comma-separated list of ips. Trailing white spaces
    // /// are to be trimmed</param>
    // procedure SetListenersIPs(const IPs: String);

    function ToJson(): TJsonObject;

    /// <summary>Return a list of ips from which the data can be accepted</summary>
    // function GetProvidersIps(): TArray<String>;

    /// <summary>Set ip from which the data can be accepted.</summary>
    /// <param name="IPs">Comma-separated list of ips. Trailing white spaces
    /// are to be trimmed</param>
    // procedure SetProvidersIPs(const IPs: String);

    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer(PORT_KEY)]
    property Port: Integer read FPort write FPort;

    /// <summary> Token that identifies the server.</summary>
    [MapperJSONSer(TOKEN_KEY)]
    property Token: String read FToken write FToken;

    /// <summary> List of clients that are allowed to make requests to this server.</summary>
    [MapperJSONSer(CLIENTS_KEY)]
    [MapperListOf(TClient)]
    property Clients: TObjectList<TClient> read FClients write FClients;

    /// <summary> List of clients that are allowed to make requests to this server.</summary>
    [MapperJSONSer(CONSUMER_IP_WHITELIST_KEY)]
    property ConsumerWhitelist: String read FConsumerWhiteListIps write FConsumerWhiteListIps;

    /// <summary> List of consumers (listeners) that are subscribed to this service.</summary>
    [MapperJSONSer(CONSUMERS_KEY)]
    [MapperListOf(TListenerInfo)]
    property Consumers: TObjectList<TListenerInfo> read FConsumers write FConsumers;



    // /// <summary> comma-separated list of ips from which the subscriptions are allowed.
    // /// A subscription request originating from an ip not present in this string is to be ignored.</summary>
    // [MapperJSONSer(IPS_KEY_NAME_LISTENERS)]
    // property ListenersIPs: String read FConsumerWhiteListIps write SetListenersIPs;

    /// <summary> comma-separated list of ips of providers that are allowed to enqueue the items.
    /// Any request to put a request into the queue originating from an ip not present in this string is to be ignored.</summary>
    // [MapperJSONSer(CLIENTS_KEY)]
    // property ProvidersIPs: String read FProvidersAllowedIPs write SetProvidersIPs;

  end;

type
  TAQConfigImmutable = class(TAQConfig)
  strict private
    function GetClients: TObjectList<TClient>;
    function GetConsumers: TObjectList<TListenerInfo>;
  public
    constructor Create(const Port: Integer; const Token, WhiteList: String; const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TListenerInfo>); overload;
    constructor Create(const Config: TAQConfig); overload;
    function Clone(): TAQConfigImmutable;

    /// override the parent fields by making them read-only
    property Port: Integer read FPort;
    property Token: String read FToken;
    property ConsumerWhitelist: String read FConsumerWhitelistIPs;
    property Clients: TObjectList<TClient> read GetClients;
    property Consumers: TObjectList<TListenerInfo> read GetConsumers;

  end;

implementation

uses
  System.Types, System.StrUtils;

{ TAQConfig }

constructor TAQConfig.Create;
begin
  FClients := TObjectList<TClient>.Create();
  FConsumers := TObjectList<TListenerInfo>.Create();
end;

constructor TAQConfig.Create(const Port: Integer; const TheClients: TObjectList<TClient>; const Token: String; const ConsumerWhiteList: String);
var
  Client: TClient;
  I, L: Integer;
  Items: TArray<String>;
begin
  Create();
  FPort := Port;
  FToken := Token;
  FConsumerWhiteListIps := ConsumerWhiteList;
  for Client in TheClients do
    FClients.Add(TClient.Create(Client.IP, Client.Token));
end;

destructor TAQConfig.Destroy;
begin
  FClients.Clear;
  FClients.DisposeOf;
  FConsumers.Clear;
  FConsumers.DisposeOf;
  inherited;
end;

// function TAQConfig.GetListenersIps: TArray<String>;
// begin
// Result := ApplyToEach(FConsumerWhiteListIpArray, TrimMapper);
// end;

// function TAQConfig.ApplyToEach(const Original: TArray<String>; const Mapper: StringMapper): TArray<String>;
// var
// I, S: Integer;
// begin
// If Assigned(Original) then
// S := Length(Original)
// else
// S := 0;
// Result := TArray<String>.Create();
// SetLength(Result, S);
// for I := 0 to S - 1 do
// Result[I] := Mapper(Original[I]);
// end;

// function TAQConfig.GetProvidersIps: TArray<String>;
// begin
// Result := ApplyToEach(FClients, TrimMapper);
// end;

// function TAQConfig.GetListeners: TObjectList<TListenerInfo>;
// var
// listener: TListenerInfo;
// builder: TListenerInfoBuilder;
// begin
// Result := TObjectList<TListenerInfo>.Create();
// if Assigned(FListeners) then
// begin
// for listener in FListeners do
// begin
// builder := TListenerInfoBuilder.Create();
// Result.Add(builder
// .SetToken(Listener.token)
// .SetIP(Listener.IP)
// .SetPort(Listener.Port)
// .SetPath(Listener.Path).Build);
// builder.DisposeOf;
// end;
// end;
//
// end;

// procedure TAQConfig.SetListenersIPs(const IPs: String);
// var
// Items: TArray<String>;
// begin
// /// clean the previously set values
// SetLength(FConsumerWhiteListIpArray, 0);
// FConsumerWhiteListIps := IPs;
// Items := TArray<String>(SplitString(IPs, ','));
// FConsumerWhiteListIpArray := ApplyToEach(Items, TrimMapper);
// end;

// procedure TAQConfig.SetProvidersIPs(const IPs: String);
// var
// items: TArray<String>;
// begin
/// clean the previously set values
// SetLength(FProvidersAllowedIPs, 0);
// FProvidersAllowedIPs := IPs;
// Items := TArray<String>(SplitString(IPs, ','));
// FClients := ApplyToEach(Items, TrimMapper);
// end;

function TAQConfig.ToJson: TJsonObject;
begin
  Result := Mapper.ObjectToJSONObject(Self);
end;

// procedure TAQConfig.SetListeners(const Listeners: TObjectList<TListenerInfo>);
//
// var
// Listener: TListenerInfo;
// begin
// if Assigned(FListeners) then
// begin
// FListeners.Clear;
// FListeners.DisposeOf;
// end;
// FListeners := TObjectList<TListenerInfo>.Create();
// if Listeners <> nil then
// begin
// for Listener in Listeners do
// begin
// FListeners.Add(TListenerInfoBuilder.Create()
// .SetToken(Listener.token)
// .SetIP(Listener.IP)
// .SetPort(Listener.Port)
// .SetPath(Listener.Path).Build);
// end;
// end;
//
// end;

{ TAQConfigBuilder }

{ TAQConfigImmutable }

function TAQConfigImmutable.Clone: TAQConfigImmutable;
begin
  Result := TAQConfigImmutable.Create(Fport, FToken, FConsumerWhiteListIps, FClients, FConsumers);
end;

constructor TAQConfigImmutable.Create(const Config: TAQConfig);
begin
  if Config = nil then
    raise Exception.Create('Can not create an immutable config from a nil object!');
  Create(Config.Port, Config.Token, Config.ConsumerWhitelist, Config.Clients, Config.Consumers);
end;

constructor TAQConfigImmutable.Create(const Port: Integer; const Token, WhiteList: String;
  const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TListenerInfo>);
var
  AClient: TClient;
  AConsumer: TListenerInfo;

begin
  FPort := Port;
  FToken := Token;
  FConsumerWhiteListIps := WhiteList;
  FClients := TObjectList<TClient>.Create();
  FConsumers := TObjectList<TListenerInfo>.Create();
  if TheClients <> nil then
  begin
    for AClient in TheClients do
      FClients.Add(AClient.Clone());
  end;
  if TheConsumers <> nil then
  begin
    for AConsumer in TheConsumers do
      FConsumers.Add(AConsumer.Clone());
  end;

end;

function TAQConfigImmutable.GetClients: TObjectList<TClient>;
var
  AClient: TClient;
begin
  Result := TObjectList<TClient>.Create;
  for AClient in FClients do
  begin
    Result.Add(AClient.Clone());
  end;
end;

function TAQConfigImmutable.GetConsumers: TObjectList<TListenerInfo>;
var
  AConsumer: TListenerInfo;
begin
  Result := TObjectList<TListenerInfo>.Create;
  for AConsumer in FConsumers do
  begin
    Result.Add(AConsumer.Clone());
  end;
end;

end.
