unit ServerConfig;

interface

uses
  System.Generics.Collections, Client, ObjectsMappers;

type

  [MapperJSONNaming(JSONNameLowerCase)]
  TServerConfig = class(TObject)
  strict private
  const
    PORT_KEY = 'port';
    CLIENTS_KEY = 'clients';
    BACKEND_IP_KEY = 'backend-ip';
    BACKEND_PORT_KEY = 'backend-port';
    TOKEN_KEY = 'token';

  var
    FPort: Integer;
    FBackEndPort: Integer;
    FBackEndIP: String;
    FToken: String;
    FClients: TObjectList<TClient>;
    procedure SetClients(const Value: TObjectList<TClient>);
    function GetClients: TObjectList<TClient>;

  public
    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer(PORT_KEY)]
    property Port: Integer read FPort write FPort;

    /// <summary> Url of the backend service accepts the connections.</summary>
    [MapperJSONSer(BACKEND_IP_KEY)]
    property BackEndIP: String read FBackEndIP write FBackEndIP;

    /// <summary>Token that should be given to the backend server for authorisation.</summary>
    [MapperJSONSer(TOKEN_KEY)]
    property Token: String read FToken write FToken;

    /// <summary> Port at which the backend service accepts the connections.</summary>
    [MapperJSONSer(BACKEND_PORT_KEY)]
    property BackEndPort: Integer read FBackEndPort write FBackEndPort;

    /// <summary>List of clients from which the requests are accepted.</summary>
    [MapperJSONSer(CLIENTS_KEY)]
    [MapperListOf(TClient)]
    property Clients: TObjectList<TClient> read GetClients write SetClients;

    constructor Create(); overload;
    constructor Create(const Port: Integer; const Clients: TObjectList<TClient>; const BackEndIp: String; const BackEndPort: Integer; const Token: String); overload;
    destructor Destroy(); override;
  end;

implementation

{ TReceptionConfig }

constructor TServerConfig.Create;
begin
  FClients := TObjectList<TClient>.Create();
end;

constructor TServerConfig.Create(const Port: Integer; const Clients: TObjectList<TClient>; const BackEndIp: String; const BackEndPort: Integer; const Token: String);
begin
  Create();
  FPort := Port;
  FBackEndPort := BackEndPort;
  FBackEndIp := BackEndIp;
  FToken := Token;
  SetClients(Clients);
end;

destructor TServerConfig.Destroy;
begin
  FClients.Clear;
  FClients.DisposeOf;
end;

function TServerConfig.GetClients: TObjectList<TClient>;
var
  Client: TClient;
begin
  Result := TObjectList<TClient>.Create;
  for Client in Clients do
    Result.Add(TClient.Create(Client.IP, Client.Token));
end;

procedure TServerConfig.SetClients(const Value: TObjectList<TClient>);
var
  Client: TClient;
begin
  FClients.Clear;
  for Client in Value do
  begin
    FClients.Add(TClient.Create(Client.IP, Client.Token));
  end;

end;

end.
