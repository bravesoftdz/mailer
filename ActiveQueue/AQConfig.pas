unit AQConfig;

interface

uses
  System.JSON, System.Classes, ObjectsMappers,
  System.SysUtils, JsonableInterface, System.Generics.Collections, Client, Consumer,
  RepositoryConfig;

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
    REPO_REQUESTS_KEY = 'repository-requests';
    REPO_CONSUMERS_KEY = 'repository-consumers';
  protected
  var
    FPort: Integer;
    FToken: String;
    FClients: TObjectList<TClient>;
    FConsumerWhiteListIps: String;
    FConsumers: TObjectList<TConsumer>;
    FRepoRequests: TRepositoryConfig;

  public
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

    /// <summary>Configuration for request repository</summary>
    [MapperJSONSer(REPO_REQUESTS_KEY)]
    property RequestsRepository: TRepositoryConfig read FRepoRequests write FRepoRequests;
  end;

type

  /// <summary>Immutable version of TAQConfig.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAQConfigImmutable = class(TAQConfig)
  strict private
    function GetClients: TObjectList<TClient>;
    function GetConsumers: TObjectList<TConsumer>;
  private
    function GetRepoRequests: TRepositoryConfig;
  public
    // constructor Create(const Port: Integer; const Token, WhiteList: String; const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TConsumer>); overload;
    constructor Create(const Config: TAQConfig); overload;
    function Clone(): TAQConfigImmutable;

    /// override the parent fields by making them read-only
    [MapperTransient]
    constructor Create(const Port: Integer; const Token, WhiteList: String;
      const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TConsumer>;
      const RepoRequests: TRepositoryConfig); overload;
    property Port: Integer read FPort;
    [MapperTransient]
    property Token: String read FToken;
    [MapperTransient]
    property ConsumerWhitelist: String read FConsumerWhitelistIPs;
    [MapperTransient]
    property Clients: TObjectList<TClient> read GetClients;
    [MapperTransient]
    property Consumers: TObjectList<TConsumer> read GetConsumers;
    [MapperTransient]
    property RequestsRepository: TRepositoryConfig read GetRepoRequests;

  end;

implementation

uses
  System.Types, System.StrUtils;

{ TAQConfig }

constructor TAQConfig.Create;
begin
  FClients := TObjectList<TClient>.Create();
  FConsumers := TObjectList<TConsumer>.Create();
  FRepoRequests := TRepositoryConfig.Create;
end;

destructor TAQConfig.Destroy;
begin
  FClients.Clear;
  FClients.DisposeOf;
  FConsumers.Clear;
  FConsumers.DisposeOf;
  FRepoRequests.DisposeOf;
  inherited;
end;

function TAQConfig.ToJson: TJsonObject;
var
  ja1, ja2: TJsonArray;
  AConsumer: TConsumer;
  AClient: TClient;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TJsonPair.Create(PORT_KEY, TJsonNumber.Create(Port)));
  Result.AddPair(TOKEN_KEY, FToken);
  Result.AddPair(CONSUMER_IP_WHITELIST_KEY, FConsumerWhiteListIps);
  ja1 := TJsonArray.Create();
  for AConsumer in FConsumers do
  begin
    ja1.AddElement(AConsumer.ToJson);
  end;
  Result.AddPair(CONSUMERS_KEY, ja1);
  ja2 := TJsonArray.Create();
  for AClient in FClients do
  begin
    ja2.AddElement(AClient.toJson());
  end;
  Result.AddPair(CLIENTS_KEY, ja2);
  Result.AddPair(REPO_REQUESTS_KEY, FRepoRequests.ToJson);
end;

{ TAQConfigImmutable }

function TAQConfigImmutable.Clone: TAQConfigImmutable;
begin
  Result := TAQConfigImmutable.Create(Fport, FToken, FConsumerWhiteListIps, FClients, FConsumers, FRepoRequests);
end;

constructor TAQConfigImmutable.Create(const Config: TAQConfig);
begin
  if Config = nil then
    raise Exception.Create('Can not create an immutable config from a nil object!');
  Create(Config.Port, Config.Token, Config.ConsumerWhitelist, Config.Clients, Config.Consumers, Config.RequestsRepository);
end;

constructor TAQConfigImmutable.Create(const Port: Integer; const Token, WhiteList: String;
  const TheClients: TObjectList<TClient>; const TheConsumers: TObjectList<TConsumer>; const RepoRequests: TRepositoryConfig);
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
  FRepoRequests := RepoRequests.Clone;

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

function TAQConfigImmutable.GetRepoRequests: TRepositoryConfig;
begin
  Result := FRepoRequests.Clone();
end;

end.
