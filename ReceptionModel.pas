unit ReceptionModel;

interface

uses
  Responce, ProviderFactory, FrontEndRequest, ActiveQueueSettings,
  Web.HTTPApp, System.Generics.Collections, Client, ClientFullRequest, Authentication;

type
  TReceptionModel = class

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

  public
    /// <summary>
    /// Elaborate an action from a requestor. The request might contain a plain
    /// text data and attachments.</summary>
    /// <param name="Requestor">who requests the action</param>
    /// <param name="anAction">what action should be performed</param>
    /// <param name="aData">a json in a string form (i.e., "{'key': value, ...}")
    /// It should contain a key "token" with a valid value in order to be taken into considration.
    /// </param>
    /// <param name="AttachedFiles">provided files to be passed to the executor</param>
    function Elaborate(const Requestor: string; const anAction: string; const aData: string; const IP: String; const AttachedFiles: TAbstractWebRequestFiles)
      : TResponce; deprecated 'Use SomeOtherProp instead';

    /// <summary>
    /// Elaborate an action from a client.</summary>
    /// <param name="Requestor">client name</param>
    /// <param name="anAction">an action name that the client requests to perform</param>
    /// <param name="IP">client IP</param>
    /// <param name="Request">request obtained from the client</param>
    function Elaborate2(const Requestor: string; const anAction: string; const IP: String; const Request: TClientFullRequest): TResponce;

    property clients: TObjectList<TClient> read GetClients write SetClients;

    property BackEndSettings: TActiveQueueSettings read GetSettings write SetSettings;
    constructor Create();
    destructor Destroy();
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
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
  FClients := TArray<TClient>.Create();
end;

destructor TReceptionModel.Destroy;
begin
  SetLength(FClients, 0);
  FFactory.DisposeOf;
end;

function TReceptionModel.Elaborate(const Requestor: string; const anAction: string;
  const aData: string; const IP: string; const AttachedFiles: TAbstractWebRequestFiles)
  : TResponce;
var
  AJson: TJsonObject;
  Request: TFrontEndRequest;
  Provider: TProvider;
  Action: TAction;
  Responce: TResponce;
  Input: TClientRequest;
  Token: String;
begin
  try
    AJSon := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(aData), 0) as TJSONObject;
    Token := AJSon.GetValue(TOKEN_KEY).Value;
    if (AJson <> nil) then
    begin
      Input := Mapper.JSONObjectToObject<TClientRequest>(AJSon);
    end;
  except
    on E: Exception do
    begin
      AJSon := nil;
    end;
  end;

  // ----- add authorisation control here -----

  Request := TFrontEndRequest.Create(Input, AttachedFiles);
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
    Responce.msg := 'authorization missing...';
  end;
  Result := Responce;

end;

function TReceptionModel.Elaborate2(const Requestor, anAction, IP: String;
  const Request: TClientFullRequest): TResponce;
var
  Provider: TProvider;
  Action: TAction;
  Responce: TResponce;
begin
  if isAuthenticated(IP, Request.FRequest.Token) then
  begin
    Provider := FFactory.FindByName(Requestor);
    if (Provider <> nil) then
    begin
      Action := Provider.FindByName(anAction);
    end;
    if (Action <> nil) then
    begin
      Responce := Action.Elaborate2(Request, FSettings);
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

function TReceptionModel.GetClients: TObjectList<TClient>;
var
  item: TClient;
begin
  Result := TObjectList<TClient>.Create;
  for Item in FClients do
  begin
    Result.Add(TClient.Create(Item.IP, Item.Token));
  end;

end;

function TReceptionModel.GetSettings: TActiveQueueSettings;
begin
  Result := TActiveQueueSettings.Create(FSettings.Url, FSettings.Port);
end;

function TReceptionModel.isAuthenticated(const IP, Token: String): Boolean;
var
  Client: TClient;
begin
  if (FAuthentication = nil) then
  begin
    Result := False;
  end
  else
  begin
    Result := FAuthentication.isAuthenticated(TClient.Create(IP, Token));
  end;
end;

procedure TReceptionModel.SetClients(const clients: TObjectList<TClient>);
var
  L, I: Integer;
begin
  if FAuthentication <> nil then
    raise Exception.Create('Reception model can instantiate authentication class only once!');
  FAuthentication := TAuthentication.Create(clients);
end;

procedure TReceptionModel.SetSettings(const Value: TActiveQueueSettings);
begin
  FSettings := TActiveQueueSettings.Create(Value.Url, Value.Port);
end;

end.
