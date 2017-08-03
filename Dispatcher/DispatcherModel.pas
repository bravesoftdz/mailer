unit DispatcherModel;

interface

uses
  DispatcherConfig, DispatcherResponce, DispatcherEntry,
  ProviderFactory, System.Generics.Collections, ActiveQueueEntry, Attachment,
  ServerConfig, IpTokenAuthentication, RequestStorageInterface, System.JSON,
  RepositoryConfig, RequestSaverFactory;

type
  TModel = class(TObject)

  strict private
  var
    FConfig: TServerConfigImmutable;
    FAuthentication: TIpTokenAuthentication;
    FFactory: TProviderFactory;
    // A class that persist the requests. It gets initialized in SetConfig() method.
    FRequestSaver: IRequestStorage<TDispatcherEntry>;
    FRequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>;

    function GetConfig(): TServerConfigImmutable;
    procedure SetConfig(const Config: TServerConfigImmutable);

  public

    constructor Create(const RequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>);
    destructor Destroy(); override;

    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP, Token: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;

    function GetRepositoryParams(): TArray<TPair<String, String>>;

    /// <summary>Split the entry into a set of single actions and pass them to the back end server.</summary>
    function Dispatch(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;

    /// <summary>Save given object and return its id.
    /// Throw an  exception in case of failure.</summary>
    function Persist(const Obj: TJsonObject): String;

    /// <summary>Delete persisted object by its id.
    /// This method serves just for clean up. If it fails, nothing serious happens.
    /// Return true in case of success, false otherwise. </summary>
    function Delete(const Id: String): Boolean;

    /// <summary>Persist the given request and transform it in a form that the back end server can accept.
    /// The method first tries to persist the request. If it fails, it remembers the error and tries
    /// to accomplish the second step - dispatch the request and convert the result into a form for the
    /// back end server.
    /// Return a pair whose key is an id under which the entry has been persisted (in case of success)
    /// and value is an instance for the back end server.<summary>
    ///
    /// <param name="Entry">a dispatcher entry to be elaborated</param>
    function PersistDispatchConvert(const Entry: TDispatcherEntry): TPair<String, TActiveQueueEntries>;

    /// <summary>Return requests that have to be elaborated. It delegates its
    /// functionality to FRequestSaver which might not be initialized at the moment of this request.</summary>
    function GetPendingRequests(): TDictionary<String, TDispatcherEntry>;

    property Config: TServerConfigImmutable read GetConfig write SetConfig;

  end;

implementation

uses
  Provider, VenditoriSimple, SoluzioneAgenti, Actions, OfferteNuoviMandati,
  System.SysUtils, Client, System.Classes, RequestToFileSystemStorage, MVCFramework.Logger;

{ TModel }

constructor TModel.Create(const RequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>);
var
  ListOfProviders: TObjectList<TProvider>;
begin
  ListOfProviders := TObjectList<TProvider>.Create;
  ListOfProviders.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create, TOfferteNuoviMandati.Create]);
  FFactory := TProviderFactory.Create(ListOfProviders);
  ListOfProviders.Clear;
  ListOfProviders.DisposeOf;
  FRequestSaverFactory := RequestSaverFactory;

end;

function TModel.Dispatch(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;
var
  Actions: TObjectList<TAction>;
  Action: TAction;
  Token: String;
  Attachments: TObjectList<TAttachment>;
  BackEndEntry: TActiveQueueEntry;
  AQTmp: TActiveQueueEntry;
begin
  Actions := FFactory.FindActions(Entry.Origin, Entry.Action);
  Result := TObjectList<TActiveQueueEntry>.Create();
  Token := FConfig.Token;
  try
    for Action in Actions do
    begin
      Attachments := Entry.Attachments;
      try
        BackEndEntry := Action.MapToBackEndEntry(Entry.Content, Attachments, Token);
        Result.Add(BackEndEntry);
      except
        on E: Exception do
        begin
          Actions.Clear;
          Actions.DisposeOf();
          raise Exception.Create('Failed to create back-end entries: ' + e.Message);
        end;
      end;
    end;
  finally
    Actions.Clear;
    Actions.DisposeOf();
  end;
end;

function TModel.GetPendingRequests(): TDictionary<String, TDispatcherEntry>;
begin
  if FRequestSaver <> nil then
    Result := FRequestSaver.GetPendingRequests()
  else
    Result := nil;
end;

function TModel.PersistDispatchConvert(const Entry: TDispatcherEntry): TPair<String, TActiveQueueEntries>;
var
  jo: TJsonObject;
  ID: String;
  Items: TObjectList<TActiveQueueEntry>;
  ErrorMessages: TStringList;
  ErrorSummary: String;
begin
  ErrorMessages := TStringList.Create;
  jo := Entry.toJson();
  try
    ID := Persist(jo);
  except
    on E: Exception do
    begin
      ErrorMessages.Add(E.Message);
    end;
  end;
  if jo <> nil then
  begin
    jo.DisposeOf;
  end;

  try
    Items := Dispatch(Entry);
  except
    on E: Exception do
    begin
      ErrorMessages.Add(E.Message);
    end;
  end;

  if (ID <> '') AND (Items <> nil) then
  begin
    Result := TPair<String, TActiveQueueEntries>.Create(ID, TActiveQueueEntries.Create(FConfig.Token, Items));
  end;
  if Items <> nil then
  begin
    Items.Clear;
    Items.DisposeOf;
  end;

  if ErrorMessages.Count > 0 then
  begin
    ErrorSummary := ErrorMessages.Text;
    ErrorMessages.DisposeOf;
    raise Exception.Create('Dispatcher has encountered the following errors: ' + ErrorSummary);
  end
  else
  begin
    ErrorMessages.DisposeOf;
  end;

end;

function TModel.Delete(const Id: String): Boolean;
begin
  Result := FRequestSaver.Delete(Id);
end;

destructor TModel.Destroy;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  if FAuthentication <> nil then
    FAuthentication.DisposeOf;
  FFactory.DisposeOf;
  FRequestSaver := nil;
  inherited;
end;

function TModel.GetBackEndIp: String;
begin
  Result := FConfig.BackEndIp
end;

function TModel.GetBackEndPort: Integer;
begin
  Result := FConfig.BackEndPort
end;

function TModel.GetClientIps: TArray<String>;
begin
  Result := FAuthentication.GetIps();
end;

function TModel.GetConfig: TServerConfigImmutable;
begin
  Result := TServerConfigImmutable.Create(FConfig.Port, FConfig.Clients, FConfig.BackEndIP, FConfig.BackEndPort, FConfig.Token);
end;

function TModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port;
end;

function TModel.GetRepositoryParams: TArray<TPair<String, String>>;
begin
  if FConfig <> nil then
    Result := FRequestSaver.GetParams()
  else
    Result := nil;
end;

function TModel.isAuthorised(const IP, Token: String): Boolean;
begin
  Result := (FAuthentication <> nil) AND FAuthentication.isAuthorised(IP, Token);
end;

function TModel.Persist(const Obj: TJsonObject): String;
begin
  Result := FRequestSaver.Save(Obj);
end;

procedure TModel.SetConfig(const Config: TServerConfigImmutable);
const
  TAG = 'TModel.SetConfig';
var
  IPs, Tokens: TArray<String>;
  Clients: TObjectList<TClient>;
  L, I: Integer;
  RepoConfig: TRepositoryConfig;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;

  FConfig := Config.Clone;
  RepoConfig := FConfig.Repository;
  FRequestSaver := FRequestSaverFactory.CreateStorage(RepoConfig);

  IPs := TArray<String>.Create();
  Tokens := TArray<String>.Create();
  Clients := Config.Clients;
  L := Clients.Count;
  SetLength(IPs, L);
  SetLength(Tokens, L);
  for I := 0 to L - 1 do
  begin
    IPs[I] := Clients[I].IP;
    Tokens[I] := Clients[I].Token;
  end;
  FAuthentication := TIpTokenAuthentication.Create(IPs, Tokens);
  SetLength(IPs, 0);
  SetLength(Tokens, 0);
  Clients.Clear;
  Clients.DisposeOf();
  if RepoConfig <> nil then
    RepoConfig.DisposeOf;

end;

end.
