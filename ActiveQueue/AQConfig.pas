unit AQConfig;

interface

uses
  System.JSON, System.Classes, ObjectsMappers,
  System.SysUtils, JsonableInterface, System.Generics.Collections, Client, Consumer;

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
    FConsumers: TObjectList<TConsumer>;

  public
    constructor Create(const Port: Integer; const TheClients: TObjectList<TClient>; const Token: String; const ConsumerWhiteList: String); overload;
    constructor Create(); overload;
    destructor Destroy; override;

    function ToJson(): TJsonObject;

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
    [MapperListOf(TConsumer)]
    property Consumers: TObjectList<TConsumer> read FConsumers write FConsumers;
  end;

type
  /// <summary>Immutable version of TAQConfig.</summary>
  TAQConfigImmutable = class(TAQConfig)
  strict private
    function GetClients: TObjectList<TClient>;
    function GetConsumers: TObjectList<TConsumer>;
  public
    constructor Create(const Port: Integer; const Token, WhiteList: String; const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TConsumer>); overload;
    constructor Create(const Config: TAQConfig); overload;
    function Clone(): TAQConfigImmutable;

    /// override the parent fields by making them read-only
    property Port: Integer read FPort;
    property Token: String read FToken;
    property ConsumerWhitelist: String read FConsumerWhitelistIPs;
    property Clients: TObjectList<TClient> read GetClients;
    property Consumers: TObjectList<TConsumer> read GetConsumers;

  end;

implementation

uses
  System.Types, System.StrUtils;

{ TAQConfig }

constructor TAQConfig.Create;
begin
  FClients := TObjectList<TClient>.Create();
  FConsumers := TObjectList<TConsumer>.Create();
end;

constructor TAQConfig.Create(const Port: Integer; const TheClients: TObjectList<TClient>; const Token: String; const ConsumerWhiteList: String);
var
  Client: TClient;
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

function TAQConfig.ToJson: TJsonObject;
begin
  Result := Mapper.ObjectToJSONObject(Self);
end;

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
  const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TConsumer>);
var
  AClient: TClient;
  AConsumer: TConsumer;

begin
  FPort := Port;
  FToken := Token;
  FConsumerWhiteListIps := WhiteList;
  FClients := TObjectList<TClient>.Create();
  FConsumers := TObjectList<TConsumer>.Create();
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

function TAQConfigImmutable.GetConsumers: TObjectList<TConsumer>;
var
  AConsumer: TConsumer;
begin
  Result := TObjectList<TConsumer>.Create;
  for AConsumer in FConsumers do
  begin
    Result.Add(AConsumer.Clone());
  end;
end;

end.
