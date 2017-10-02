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

    // function SendToBackEnd(const Requests: TActiveQueueEntries): TAQResponce;

    /// <summary>Save given object and return its id.
    /// Throw an  exception in case of failure.</summary>
    function Persist(const Item: TDispatcherEntry): String;

  public

    constructor Create(const RequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>);
    destructor Destroy(); override;

    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP, Token: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;

    function GetRepositoryParams(): TArray<TPair<String, String>>;

    /// <summary>Return requests that have to be elaborated. It delegates its
    /// functionality to FRequestSaver which might not be initialized at the moment of this request.</summary>
    function GetPendingRequests(): TDictionary<String, TDispatcherEntry>;

    /// <summary>Perform authentication check and if it passes, persist the request.
    /// Once the request is persisted, then it is a dispatcher sender to take care of the request.
    /// <param name="IP">IP address from wich the request comes from</param>
    /// <param name="Request">received request. Assume it is not null.</param>
    function ElaborateSingleRequest(const IP: String; const Request: TDispatcherEntry): TDispatcherResponce;

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

function TModel.GetPendingRequests(): TDictionary<String, TDispatcherEntry>;
begin
  if FRequestSaver <> nil then
  begin
    Result := FRequestSaver.GetPendingRequests()
  end
  else
    Result := TDictionary<String, TDispatcherEntry>.Create();
end;

function TModel.ElaborateSingleRequest(const IP: String; const Request: TDispatcherEntry): TDispatcherResponce;
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
        Result := TDispatcherResponce.Create(True, Format('The request has been persisted, id="%s".', [id]));
      except
        on E: Exception do
        begin
          Result := TDispatcherResponce.Create(False, 'Failed to persist the request');
          Id := '';
        end;
      end;
      // if (Id <> '') then
      // begin
      // Result := ElaborateSinglePersistedRequest(Id, Request);
      // end;
    finally
      TMonitor.Exit(FPendingRequestLock);
    end;
  end;
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

  FSender := TDispatcherEntrySender.Create(FrequestSaver, FBackEndProxy, FConfig.Token);

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
