unit DispatcherModel;

interface

uses
  DispatcherConfig, DispatcherResponce, DispatcherEntry,
  ProviderFactory, System.Generics.Collections, ActiveQueueEntry, Attachment,
  ServerConfig, IpTokenAuthentication, RequestStorageInterface, System.JSON,
  RepositoryConfig, RequestSaverFactory, AQAPIClient, MVCFramework.RESTAdapter,
  AQResponce, DispatcherEntrySender;

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

    FBackEndProxy: IAQAPIClient;
    FBackEndAdapter: TRestAdapter<IAQAPIClient>;

    /// a dumb object to have a thread-safe access to request-related data
    FPendingRequestLock: TObject;

    /// monitors the repository and sends the items to the back end server
    FSender: TDispatcherEntrySender;

    function GetConfig(): TServerConfigImmutable;
    procedure SetConfig(const Config: TServerConfigImmutable);

    function SendToBackEnd(const Requests: TActiveQueueEntries): TAQResponce;

    /// <summary>Dispatch the input request and transform it in a form that the back end server can accept.
    /// <summary>
    /// <param name="Entry">a dispatcher entry to be elaborated</param>
    function DispatchConvert(const Entry: TDispatcherEntry): TActiveQueueEntries;

    /// <summary> Elaborate a single request that has been already:
    /// 1. dispatch the request
    /// 2. convert it to a back-end server compatible format
    /// 3. send to the back-end server
    /// 4. delete the requests that were successefuly passed to the back-end server
    /// </summary>
    function ElaborateSinglePersistedRequest(const Id: String; const Request: TDispatcherEntry): TDispatcherResponce;

    /// <summary>Save given object and return its id.
    /// Throw an  exception in case of failure.</summary>
    function Persist(const Item: TDispatcherEntry): String;

    /// <summary>Split the entry into a set of single actions and pass them to the back end server.</summary>
    function Dispatch(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;

  public

    constructor Create(const RequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>);
    destructor Destroy(); override;

    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP, Token: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;

    function GetRepositoryParams(): TArray<TPair<String, String>>;

    /// <summary>Delete persisted object by its id.
    /// This method serves just for clean up. If it fails, nothing serious happens.
    /// Return true in case of success, false otherwise. </summary>
    function Delete(const Id: String): Boolean;

    /// <summary>Return requests that have to be elaborated. It delegates its
    /// functionality to FRequestSaver which might not be initialized at the moment of this request.</summary>
    function GetPendingRequests(): TDictionary<String, TDispatcherEntry>;

    /// <summary>Performs operations required by the logic of the dispatcher regarding incoming requests.
    /// Throws various exception in case something gets wrong. Otherwise, it must produce a non-null responce.
    /// It does the following:
    /// 1. check authentification
    /// 2. persist the request
    /// 3. dispatch the request
    /// 4. convert it to a back-end server compatible format
    /// 5. send to the back-end server
    /// 6. delete the requests that were successefuly passed to the back-end server
    /// </summary>
    /// <param name="IP">IP address from wich the request comes from</param>
    /// <param name="Request">received request. Assume it is not null.</param>
    function ElaborateSingleRequest(const IP: String; const Request: TDispatcherEntry): TDispatcherResponce;

    procedure ElaboratePendingRequests();

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
  FPendingRequestLock := TObject.Create;
  ListOfProviders := TObjectList<TProvider>.Create;
  ListOfProviders.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create, TOfferteNuoviMandati.Create]);
  FFactory := TProviderFactory.Create(ListOfProviders);
  ListOfProviders.Clear;
  ListOfProviders.DisposeOf;
  FRequestSaverFactory := RequestSaverFactory;

  FSender := nil;

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
  begin
    Result := FRequestSaver.GetPendingRequests()
  end
  else
    Result := TDictionary<String, TDispatcherEntry>.Create();
end;

function TModel.ElaborateSinglePersistedRequest(const Id: String; const Request: TDispatcherEntry): TDispatcherResponce;
var
  SavedAndConverted: TActiveQueueEntries;
  Outcome: TAQResponce;
  Status: Boolean;
  Msg: String;
begin
  SavedAndConverted := DispatchConvert(Request);
  try
    Outcome := SendToBackEnd(SavedAndConverted);
  except
    on E: Exception do
    begin
      Result := TDispatcherResponce.Create(True, Format(TDispatcherResponceMessages.EXCEPTION_REPORT, [Id, E.Message]));
      Outcome := nil;
    end;
  end;
  SavedAndConverted.DisposeOf;
  if Outcome <> nil then
  begin
    // extract the values that will be used later in order to be able to destroy the object
    Status := Outcome.status;
    Msg := Outcome.Msg;
    Outcome.DisposeOf;
    if Status then
    begin
      try
        Delete(Id);
        Result := TDispatcherResponce.Create(True, TDispatcherResponceMessages.SUCCESS);
      except
        on E: Exception do
        begin
          Result := TDispatcherResponce.Create(True, Format(TDispatcherResponceMessages.FAILED_TO_DELETE, [Id, E.Message]));
        end;
      end;
    end
    else
    begin
      Result := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.FAILURE_REPORT, [Id, Msg]));
    end;

  end;
  Writeln('Finish TModel.ElaborateSinglePersistedRequest');
end;

procedure TModel.ElaboratePendingRequests;
var
  PendingRequests: TDictionary<String, TDispatcherEntry>;
  RequestId: String;
  ResponceLocal: TDispatcherResponce;
begin
  if FRequestSaver <> nil then
  begin
    TMonitor.Enter(FPendingRequestLock);
    try
      PendingRequests := GetPendingRequests();

      if (PendingRequests <> nil) then
      begin
        for RequestId in PendingRequests.Keys do
        begin
          Writeln('Send a pending request ' + RequestId + ' to the back end server');
          ResponceLocal := ElaborateSinglePersistedRequest(RequestId, PendingRequests[RequestId]);
          if ResponceLocal <> nil then
          begin
            Writeln(Format('request %s outcome: status %s, message %s', [RequestId, ResponceLocal.Status.ToString, ResponceLocal.msg]));
            ResponceLocal.DisposeOf;
            PendingRequests[RequestId].DisposeOf;
          end
          else
            Writeln('No responce received from the back end server.');
        end;
        PendingRequests.Clear;
        PendingRequests.DisposeOf;
      end;
    finally
      TMonitor.Exit(FPendingRequestLock);
    end;
  end;

end;

function TModel.ElaborateSingleRequest(
  const
  IP:
  String;
  const
  Request:
  TDispatcherEntry): TDispatcherResponce;
var
  Id: String;
begin
  if not(isAuthorised(IP, Request.Token)) then
  begin
    Result := TDispatcherResponce.Create(False, TDispatcherResponceMessages.NOT_AUTHORISED);
  end
  else
  begin
    TMonitor.Enter(FPendingRequestLock);
    try
      try
        Id := Persist(Request);
      except
        on E: Exception do
        begin
          Result := TDispatcherResponce.Create(False, 'Failed to persist the request');
          Id := '';
        end;
      end;
      if (Id <> '') then
      begin
        Result := ElaborateSinglePersistedRequest(Id, Request);
      end;
    finally
      TMonitor.Exit(FPendingRequestLock);
    end;
  end;
end;

function TModel.DispatchConvert(
  const
  Entry:
  TDispatcherEntry): TActiveQueueEntries;
var
  Items: TObjectList<TActiveQueueEntry>;
  ErrorMessages: TStringList;
  ErrorSummary: String;
begin
  Writeln('Start TModel.DispatchConvert');
  ErrorMessages := TStringList.Create;
  try
    Items := Dispatch(Entry);
  except
    on E: Exception do
    begin
      ErrorMessages.Add(E.Message);
    end;
  end;

  if (Items <> nil) then
  begin
    Result := TActiveQueueEntries.Create(FConfig.Token, Items);
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
    raise Exception.Create('Dispatcher has encountered the following error: ' + ErrorSummary);
  end
  else
  begin
    ErrorMessages.DisposeOf;
  end;

  Writeln('Finish TModel.DispatchConvert');

end;

function TModel.Delete(
  const
  Id:
  String): Boolean;
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

  if (FBackEndAdapter <> nil) then
    FBackEndAdapter := nil;
  if (FBackEndProxy <> nil) then
    FBackEndProxy := nil;
  FPendingRequestLock.DisposeOf;

  if FSender <> nil then
    FSender.DisposeOf;

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
  Result := TServerConfigImmutable.Create(
    FConfig.Port,
    FConfig.Clients,
    FConfig.BackEndIP,
    FConfig.BackEndPort,
    FConfig.Token
    );
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

function TModel.isAuthorised(
  const
  IP, Token: String): Boolean;
begin
  Result := (FAuthentication <> nil) AND FAuthentication.isAuthorised(IP, Token);
end;

function TModel.Persist(
  const
  Item:
  TDispatcherEntry): String;
begin
  Writeln('Start persisting the entry');
  Result := FRequestSaver.Save(Item);
  Writeln('Finished persisting the entry');
end;

procedure TModel.SetConfig(const Config: TServerConfigImmutable);
const
  TAG = 'TModel.SetConfig';
var
  IPs, Tokens: TArray<String>;
  Clients: TObjectList<TClient>;
  L, I: Integer;
  RepoConfig: TRepositoryConfig;
  PendingRequests: TDictionary<String, TDispatcherEntry>;
  RequestId: String;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;

  FConfig := Config.Clone;
  RepoConfig := FConfig.Repository;
  FRequestSaver := FRequestSaverFactory.CreateStorage(RepoConfig);

  Writeln(Format('Set up the proxy:  url = %s, port = %d', [GetBackEndIp, GetBackEndPort]));
  FBackEndAdapter := TRestAdapter<IAQAPIClient>.Create();
  FBackEndProxy := FBackEndAdapter.Build(GetBackEndIp(), GetBackEndPort());

  FSender := TDispatcherEntrySender.Create(FrequestSaver, FBackEndProxy);

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

function TModel.SendToBackEnd(const Requests: TActiveQueueEntries): TAQResponce;
begin
  Writeln('Start: TModel.SendToBackEnd');
  Result := FBackEndProxy.PostItems(Requests);
  Writeln('End: TModel.SendToBackEnd');
end;

end.
