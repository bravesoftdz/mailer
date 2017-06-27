unit ReceptionModel;

interface

uses
  Responce, ProviderFactory, FrontEndRequest, ActiveQueueSettings,
  Web.HTTPApp, System.Generics.Collections, Client, ClientFullRequest, Authentication,
  ReceptionConfig;

type
  TReceptionModel = class(TObject)

  const
    /// name of the key that contains a token in a json
    TOKEN_KEY = 'token';
  strict private
    FFactory: TProviderFactory;
    FClients: TArray<TClient>;
    FSettings: TActiveQueueSettings;
    FAuthentication: TAuthentication;

    /// <summary>client setter. Perform the defencieve copying.</summary>
    procedure SetClients(const clients: TObjectList<TClient>);
    /// <summary>return a copy of clients.</summary>
    function GetClients(): TObjectList<TClient>;

    function GetSettings: TActiveQueueSettings;

    /// <summary> Return true if the list of clients contains a one with given IP and token.
    /// Otherwise, return false.
    /// </summary>
    function isAuthenticated(const IP, Token: String): Boolean;
    procedure SetSettings(const Value: TActiveQueueSettings);

    procedure SetConfig(const Value: TReceptionConfig);
  private
    function GetBackEndUrl: String;
    function GetBackEndPort: Integer;

  public

    /// <summary>
    /// Elaborate an action from a client.</summary>
    /// <param name="Requestor">client name</param>
    /// <param name="anAction">an action name that the client requests to perform</param>
    /// <param name="IP">client IP</param>
    /// <param name="Request">request obtained from the client</param>
    function Elaborate(const Requestor: string; const anAction: string; const IP: String; const Token: String; const Request: TClientFullRequest): TResponce;

    property clients: TObjectList<TClient> read GetClients write SetClients;

    property Config: TReceptionConfig write SetConfig;

    property BackEndUrl: String read GetBackEndUrl;

    property BackEndPort: Integer read GetBackEndPort;

    property BackEndSettings: TActiveQueueSettings read GetSettings write SetSettings;
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  Provider, Action, System.Contnrs,
  VenditoriSimple, SoluzioneAgenti, System.JSON, System.SysUtils,
  ObjectsMappers, ClientRequest;

{ TMailerModel }

constructor TReceptionModel.Create;
var
  Providers: TObjectList<TProvider>;
begin
  Writeln('Model create');
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
  FClients := TArray<TClient>.Create();
  Providers.Clear;
  Providers.DisposeOf;
end;

destructor TReceptionModel.Destroy;
var
  I, S: Integer;
begin
  Writeln('Model destroy');
  S := Length(FClients);
  for I := 0 to S - 1 do
    FClients[I].DisposeOf();
  SetLength(FClients, 0);
  FFactory.DisposeOf;
  FSettings.DisposeOf;
  if FAuthentication <> nil then
    FAuthentication.DisposeOf;

end;

function TReceptionModel.Elaborate(const Requestor, anAction, IP, Token: String;
  const Request: TClientFullRequest): TResponce;
var
  Provider: TProvider;
  Action: TAction;
  Responce: TResponce;
begin
  if isAuthenticated(IP, Token) then
  begin
    Provider := FFactory.FindByName(Requestor);
    if (Provider <> nil) then
    begin
      Action := Provider.FindByName(anAction);
    end;
    if (Action <> nil) then
    begin
      Responce := Action.Elaborate(Request, FSettings);
    end
    else
    begin
      Responce := TResponce.Create;
      Responce.msg := 'Action not allowed.';
    end;
  end
  else
  begin
    Responce := TResponce.Create;
    Responce.msg := 'Access denied';
  end;
  Result := Responce;

end;

function TReceptionModel.GetBackEndPort: Integer;
begin
  Result := FSettings.Port;
end;

function TReceptionModel.GetBackEndUrl: String;
begin
  Result := FSettings.Url;
end;

function TReceptionModel.GetClients: TObjectList<TClient>;
begin
  if FAuthentication = nil then
    Result := TObjectList<TClient>.Create
  else
    Result := FAuthentication.GetClients;
end;

procedure TReceptionModel.SetClients(const clients: TObjectList<TClient>);
begin
  if FAuthentication <> nil then
    raise Exception.Create('Reception model can instantiate authentication class only once!');
  FAuthentication := TAuthentication.Create(clients);
end;

procedure TReceptionModel.SetConfig(const Value: TReceptionConfig);
var
  BackEndSettings: TActiveQueueSettings;
begin
  SetClients(Value.Clients);
  BackEndSettings := TActiveQueueSettings.Create(Value.BackEndUrl, Value.BackEndPort);
  SetSettings(BackEndSettings);
  BackEndSettings.DisposeOf;
end;

function TReceptionModel.GetSettings: TActiveQueueSettings;
begin
  Result := TActiveQueueSettings.Create(FSettings.Url, FSettings.Port);
end;

function TReceptionModel.isAuthenticated(const IP, Token: String): Boolean;
var
  aClient: TClient;
begin
  if (FAuthentication = nil) then
  begin
    Result := False;
  end
  else
  begin
    aClient := TClient.Create(IP, Token);
    Result := FAuthentication.isAuthenticated(aClient);
    aClient.DisposeOf;
  end;
end;

procedure TReceptionModel.SetSettings(const Value: TActiveQueueSettings);
begin
  FSettings := TActiveQueueSettings.Create(Value.Url, Value.Port);
end;

end.
