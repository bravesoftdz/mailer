unit AQModel;

interface

uses
  AQSubscriptionResponce, AQSubscriptionEntry, ActiveQueueEntry,
  System.Classes, Consumer, ListenerProxyInterface,
  ConditionInterface, AQConfig, JsonSaver, Client, RequestStorageInterface,
  System.Generics.Collections, RequestSaverFactory, RepositoryConfig, MVCFramework.Logger;

type
  /// <summary> A model corresponding to the ActiveQueue controller. </summary>
  TActiveQueueModel = class(TObject)
    /// Representation invariant:
    /// All conditions must hold:
    /// 1. lock objects are non null: FSubscriptionsLock, FProvidersLock, FQueueLock, FProvidersLock
    /// 2. FSubscriptionRegister and  FProxyRegister must have the same set of keys
    /// 3. FIPs length is defined and is not less than zero
    ///
  strict private
  const
    WHITELIST_IP_SEPARATOR = ',';
    TAG = 'TActiveQueueModel';

  var
    /// a dumb lock object for managing the access to the  subscription register
    FConsumerLock: TObject;

    /// a dumb lock object for managing the access to the providers' ips
    FClientLock: TObject;

    /// a dumb lock object for managing the access to the queue items
    FQueueLock: TObject;

    /// <summary>port number at which this service operates</sumamry>
    FPort: Integer;

    /// <summary>an authentication token that this service should provide for some requests</summaary>
    FToken: String;

    /// <summary>Current configuration </summary>
    // FConfig: TAQConfigImmutable;

    /// <summary>Path to a file into which an updated version of the configuration is to be saved</summary>
    FTargetConfigPath: String;

    /// <summary>The index of the consumers. The index is a map from tokens to corresponding consumer. </summary>
    FConsumerIndex: TDictionary<String, TConsumer>;

    /// <summary>The index of the clients. The index is a map from tokens to corresponding clients.</summary>
    FClientIndex: TDictionary<String, TClient>;

    /// <summary>A set of consumer white list ips. Since Delphi has no data type for hash set,
    /// a TDictionry is used with dumb values (always set to true).</summary>
    FConsumerWhiteListHashSet: TDictionary<String, Boolean>;

    /// <summary>A map of proxies corresponding to currently subscribed listeners.
    /// Each pair is composed of a key that is a token issued during the subscription
    /// and a value that is a proxy server of the listener associated with the token.</summary>
    FConsumerProxyIndex: TDictionary<String, IConsumerProxy>;

    /// <summary>a map from categories to consumer tokens. Each consumer has a category and once
    /// the subscription process succeeds, the consumer gets assigned a token.
    /// This variable serves to quickly find all consumers of given category.</summary>
    FConsumerCategoryToTokens: TDictionary<String, TStringList>;

    /// items of the queue
    FItems: TQueue<TPair<String, TActiveQueueEntry>>;

    /// <summary>Set the IPs from which the subscriptions can be accepted.</summary>
    FListenersIPs: TArray<String>;

    /// <summary>Set the IPs from which the data to enqueue can be accepted.</summary>
    FProvidersIPs: TArray<String>;

    /// <summary>Suggestion for the file name under which the model state is to be saved</summary>
    FStateFilePath: String;

    /// <summary>Suggestion for the file name under which the model state is to be saved</summary>
    FQueueFilePath: String;

    /// <summary>a class instance by means of which the AQ state is persisted<summary>
    FStateSaver: TJsonSaver;

    /// <summary>a class responsable for persisting incoming requests. It is instantiated by
    /// the factory FRequestSaverFactory once the configuration is set.<summary>
    FRequestsStorage: IRequestStorage<TActiveQueueEntry>;

    /// <summary>a factory that produces a required file saver instance based on config file.
    FRequestSaverFactory: TRequestSaverFactory<TActiveQueueEntry>;

    FRequestRepoConfig: TRepositoryConfig;

    /// <summary>The number of the subscriptions</sumamry>
    function GetNumOfSubscriptions: Integer;

    /// <summary>Return true if given the consumer index contains a client with given ip and port.</summary>
    function IsSubscribed(const IP: String; const Port: Integer): Boolean;

    /// <summary>Check the consistency of the reresenation</summary>
    procedure checkRep();

    /// <summary>Notify all subscribed listeners of given categories that the queue state has changed.
    /// NB: each listeners is notified in a separate thread. It might be a problem if the
    /// number of listeners is high.</summary>
    procedure NotifyListeners(const Categories: TStringList);

    /// <sumary>Inform the listeners that they should cancel items satisfying the condition</summary>
    procedure BroadcastCancel(const Condition: ICondition);


    /// <summary>Return true if a given string is equal to at least one string in the array.
    /// <param name="Haystack">an array of string to search in. Assume that the haystack remains unchanged during the method's execution.</param>
    /// <param name="Needle">a string to find</param>
    function Contains(const Haystack: TArray<String>; const Needle: String): Boolean;

    /// <summary>Create an index of clients. Assume that that there is no pair of clients with
    /// equal tokens.</summary>
    function CreateClientIndex(const TheClients: TObjectList<TClient>): TDictionary<String, TClient>;

    /// <summary>Create an index of consumers. Assume that that there is no pair of consumers with
    /// equal tokens. Only those consumers are inserted into the index, whose IP is in the whitelist.</summary>
    /// <param name="TheConsumers">a list of consumers</param>
    /// <param name="WhiteList">a hash set of IPs. If a consumer IP is in this set, then that consumer is
    /// added to the index. Otherwise it is ignored.</param>
    function CreateConsumerIndex(const TheConsumers: TObjectList<TConsumer>; const WhiteList: TDictionary<String, Boolean>): TDictionary<String, TConsumer>;

    /// <summary>Create an index of consumer proxy servers. </summary>
    function CreateConsumerProxyIndex(const ConsumerIndex: TDictionary<String, TConsumer>): TDictionary<String, IConsumerProxy>;

    /// <summary>Create an index of consumer tokens by consumer's category.</summary>
    function CreateCategoryToTokenMap(const Index: TDictionary<String, TConsumer>): TDictionary<String, TStringList>;

    /// <summary>Create a hash set from a comma seprated string.</summary>
    function CommaSeparatedStrToHashSet(const Data, Separator: String): TDictionary<String, Boolean>;

    function GetConfig: TAQConfigImmutable;

    /// <summary>Set the state of the model.</summary>
    /// This method is placed here in order to be able to persist the model state changes
    /// (mostly due to the adding/cancelling the listeners) in real time mode: once a change occurs,
    /// the new state is saved.
    procedure SetConfig(const Config: TAQConfigImmutable);

    function GetPort: Integer;

    function GetToken: String;

    function GetClients: TObjectList<TClient>;

    function GetConsumerIPWhitelist: String;

    procedure SetTargetConfigPath(const Value: String);

    /// <summary>Notify given listener.
    /// The method creates a separate thread in which notifies the listener.
    /// NB: in current implementation, it there is N listeners, then N threads are created which may
    // cause a problem for bigger N. </summary>
    procedure NotifyListenerInSeparateThread(const Listener: IConsumerProxy);

    /// <summary>Get a copy of the configuration of the repository responsable for storing incoming requests
    function GetRequestRepositoryParams: TArray<TPair<String, String>>;

    /// <summary>Return true iff given IP is among those from which a subscription can be accepted.</summary>
    function IsIpInWhiteList(const IP: String): Boolean;

  public
    /// <summary>Create a subscription </summary>
    /// <param name="IP">IP from which the subscription request has arrived</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddConsumer(const IP: String; const Data: TAQSubscriptionEntry): TAQSubscriptionResponce;

    /// <summary>Get all subscribed listeners</summary>
    function GetConsumers(): TObjectList<TConsumer>;

    /// <summary>Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscrifption is to be cancelled</param>
    /// <param name="Token">token associated with the subscription</param>
    function CancelConsumer(const Ip, Token: String): TAQSubscriptionResponce;

    /// get not more that N items from the queue.
    function GetItems(const Ip: String; const Token: String; const N: Integer): TObjectList<TActiveQueueEntry>;

    /// <summary>Add multiple items (that are supposed to be already saved into the storage) to the queue.
    /// </summary>
    /// <param name="Ids">map of ids to corresponding items. </param>
    /// <returns>True in case of success, False otherwise</returns>
    function Enqueue(const IdToItem: TDictionary<String, TActiveQueueEntry>): Boolean;

    /// <summary> Get the IPs from which the subscriptions can be accepted.</summary>
    function GetListenersIPs: TArray<String>;

    /// <summary> Get the IPs from which the requests to enqueue the data can be accepted.</summary>
    function GetProvidersIPs: TArray<String>;

    /// <summary>Return true iff given IP corresponds to the token.</summary>
    function IsAllowedClient(const Token, IP: String): Boolean;

    /// <summary>Get the requests from the repository that have to be elaborated</summary>
    function GetPendingRequests(): TDictionary<String, TActiveQueueEntry>;

    /// <summary> the number of subscriptions </summary>
    property numOfSubscriptions: Integer read GetNumOfSubscriptions;

    /// <summary>the number of a port to which this service is bound</summary>
    property Port: Integer read GetPort;

    /// <summary>AQ token used for authentification</summary>
    property Token: String read GetToken;

    property Config: TAQConfigImmutable read GetConfig write SetConfig;

    property TargetConfigPath: String read FTargetConfigPath write SetTargetConfigPath;

    property ConsumerIPWhitelist: String read GetConsumerIPWhitelist;

    /// <summary>A copy of  the clients</summary>
    property Clients: TObjectList<TClient> read GetClients;

    property RequestRepositoryParams: TArray < TPair < String, String >> read GetRequestRepositoryParams;

    /// <summary>Save the state of the Active Queue server into a file</summary>
    procedure PersistState();


    procedure SetQueuePath(const path: String);

    /// <summary>Persist given items and return a map from ids to those items. </summary>
    function PersistRequests(const Items: TObjectList<TActiveQueueEntry>): TDictionary<String, TActiveQueueEntry>;

    constructor Create(const RequestSaverFactory: TRequestSaverFactory<TActiveQueueEntry>);
    destructor Destroy(); override;
  end;

implementation

uses
  System.SysUtils, MVCFramework.RESTAdapter, System.JSON, System.IOUtils,
  JsonableInterface, System.RegularExpressions;
{ TActiveQueueModel }

function TActiveQueueModel.Enqueue(const IdToItem: TDictionary<String, TActiveQueueEntry>): Boolean;
var
  id: String;
  Categories: TStringList;
  Category: String;
begin
  Writeln('Start TActiveQueueModel.Enqueue');
  Writeln('Acquiring FQueueLock');
  TMonitor.Enter(FQueueLock);
  Writeln('FQueueLock Acquired');
  Categories := TStringList.Create;
  try
    try
      for id in IdToItem.Keys do
      begin
        FItems.Enqueue(TPair<String, TActiveQueueEntry>.Create(id, IdToItem[id].Clone()));
        Category := IdToItem[id].Category;
        if Categories.IndexOf(category) = -1 then
        begin
          categories.Add(category);
        end;
      end;
      Result := True;
    except
      on E: Exception do
      begin
        Log.error('Enqueue: Error while adding to the queue: ' + E.Message, TAG);
        Result := False;
      end;
    end;
    NotifyListeners(Categories);
    Categories.Clear;
    Categories.DisposeOf;
  finally
    Writeln('Releasing FQueueLock');
    TMonitor.Exit(FQueueLock);
    Writeln('FQueueLock Released');
  end;
  Writeln('End TActiveQueueModel.Enqueue');

end;

function TActiveQueueModel.AddConsumer(const IP: String; const data: TAQSubscriptionEntry): TAQSubscriptionResponce;
var
  Token: String;
  Guid: TGUID;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Writeln('Subscribe: ' + ip + ', data: port ' + data.Port.ToString + ', category' + data.Category);
    if Data = nil then
    begin
      Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.NO_SUBSCRIPTION_DATA, '');
    end
    else
    begin
      if Not(IsIpInWhiteList(Ip)) then
        Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.NOT_AUTHORISED, '')
      else
      begin
        if IsSubscribed(IP, data.Port) then
        begin
          Writeln('This IP is already subscribed');
          Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.ALREADY_SUBSCRIBED, '');
        end
        else
        begin
          Repeat
            CreateGUID(Guid);
            Token := TRegEx.Replace(Guid.ToString, '[^a-zA-Z0-9_]', '');
          until Not(FConsumerIndex.ContainsKey(Token));
          // create a copy of the object
          FConsumerIndex.Add(Token, TConsumer.Create(Ip, data.Port, Token, data.Category));
          FConsumerProxyIndex.Add(Token, TRestAdapter<IConsumerProxy>.Create().Build(Ip, Data.Port));
          if not(FConsumerCategoryToTokens.ContainsKey(data.Category)) then
          begin
            FConsumerCategoryToTokens.Add(data.Category, TStringList.Create());
          end;
          FConsumerCategoryToTokens[data.Category].Append(Token);
          Writeln('Add token ' + token + ' to category ' + data.Category);
          Writeln('category ' + data.Category + ' now contains ' + FConsumerCategoryToTokens[data.Category].Count.ToString + ' tokens');

          Result := TAQSubscriptionResponce.Create(True, TAQSubscriptionResponceMessages.SUBSCRIBE_SUCCESS, Token);
        end;
      end;
    end;
    CheckRep();
  finally
    Writeln('Releasing FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('FConsumerLock released');
  end;
end;

procedure TActiveQueueModel.BroadcastCancel(const Condition: ICondition);
var
  Listener: TPair<String, IConsumerProxy>;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    for Listener in FConsumerProxyIndex do
    begin
      try
        Listener.Value.Cancel(Condition);
      except
        on E: Exception do
          Writeln(E.Message);
      end;
    end;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
end;


function TActiveQueueModel.GetPendingRequests(): TDictionary<String, TActiveQueueEntry>;
begin
  Writeln('Acquiring FQueueLock');
  TMonitor.Enter(FQueueLock);
  Writeln('FQueueLock Acquired');
  try
    if FRequestsStorage <> nil then
      Result := FRequestsStorage.GetPendingRequests
    else
      Result := nil;
  finally
    Writeln('Releasing FQueueLock');
    TMonitor.Exit(FQueueLock);
    Writeln('FQueueLock Released');
  end;
end;


function TActiveQueueModel.CancelConsumer(const Ip, Token: String): TAQSubscriptionResponce;
var
  Consumer: TConsumer;
  Category: String;
  Pos: Integer;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Writeln('Unsubscribe: ip = ' + ip + ', token ' + Token);
    if Not(IsIpInWhiteList(Ip)) then
      Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.NOT_AUTHORISED, '')
    else
    begin
      if (FConsumerIndex.ContainsKey(Token)) then
      begin
        Consumer := FConsumerIndex[Token];
        Category := Consumer.Category;
        if (Consumer.Ip = Ip) then
        begin
          Consumer.DisposeOf;
          FConsumerIndex.Remove(Token);
          FConsumerProxyIndex[Token] := nil;
          FConsumerProxyIndex.Remove(Token);

          Pos := FConsumerCategoryToTokens[Category].IndexOf(Token);
          if Pos <> -1 then
            FConsumerCategoryToTokens[Category].Delete(Pos)
          else
            Writeln('Consistency problem: category ' + category + ' contains no token ' + Token);

          Writeln('Unsubscribe successefuly ');
          Result := TAQSubscriptionResponce.Create(True, 'unsubscribed', '');
        end
        else
        begin
          Writeln('Unsubscribe fail: IP does not correpospond to the token');
          Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.NOT_AUTHENTICATED, '');
        end;

      end
      else
      begin
        Writeln('Unsubscribe fail: FConsumerIndex does not contain this token.');
        Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.NOT_SUBSCRIBED, '');
      end;
      CheckRep();
    end;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
end;

procedure TActiveQueueModel.CheckRep;
var
  IsOk: Boolean;
  Token, Category, Report: String; { TODO -oAndrew : skip it in the production }
  Errors: TStringList;

begin
{$IFDEF DEBUG}
  Writeln('Acquiring FQueueLock');
  TMonitor.Enter(FQueueLock);
  Writeln('FQueueLock Acquired');
  try
    Errors := TStringList.Create;
    if (FConsumerLock = nil) then
      Errors.Append('FConsumerLock is expected to be non-nil');
    if (FClientLock = nil) then
      Errors.Append('FClientLock is expected to be non-nil');
    // if (FListenersIPs = nil) then
    // Errors.Append('FListenersIPs is expected to be non-nil');
    if not((FConsumerIndex <> nil) AND (FConsumerProxyIndex <> nil) AND (FConsumerProxyIndex.Count = FConsumerIndex.Count)) then
      Errors.Append('FConsumerProxyIndex and FConsumerIndex must have the same length');

    if FConsumerProxyIndex <> nil then
    begin
      for Token in FConsumerProxyIndex.Keys do
        if Not(FConsumerIndex.ContainsKey(Token)) then
          Errors.Append('FConsumerProxyIndex contains token ' + Token + ' that FConsumerIndex does not.');
    end;
    if (FConsumerIndex <> nil) then
    begin
      for Token in FConsumerIndex.Keys do
        if Token <> FConsumerIndex[Token].token then
          Errors.Append('Consumer token mismatch: ' + Token);
    end;
    if FConsumerCategoryToTokens <> nil then
    begin
      for Category in FConsumerCategoryToTokens.Keys do
      begin
        for Token in FConsumerCategoryToTokens[Category] do
        begin
          if FConsumerIndex[Token].Category <> Category then
            Errors.Append('Token ' + Token + ':  expected category ' + FConsumerIndex[Token].Category + ', actual: ' + Category);
        end;
      end;
    end;

    Report := Errors.Text;
    Errors.Clear;
    Errors.DisposeOf;
    if Report = '' then
      Writeln('AQModel internal representation is OK')
    else
      raise Exception.Create('TActiveQueueModel representation check errors: ' + Report);

  finally
    Writeln('Releasing FQueueLock');
    TMonitor.Exit(FQueueLock);
    Writeln('FQueueLock Released');
  end;
{$ENDIF}
end;

function TActiveQueueModel.CommaSeparatedStrToHashSet(const Data, Separator: String): TDictionary<String, Boolean>;
var
  Item, Key: String;
  Items: TArray<string>;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Result := TDictionary<String, Boolean>.Create();
    Items := Data.Split([Separator]);
    for Item in Items do
    begin
      Key := Trim(Item);
      if (Key <> '') AND Not(Result.ContainsKey(Key)) then
        Result.Add(Key, True);
    end;
    Items := nil;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
end;

function TActiveQueueModel.Contains(const Haystack: TArray<String>; const Needle: String): Boolean;
var
  S, I: Integer;
begin
  Result := False;
  S := Length(Haystack);
  for I := 0 to S - 1 do
  begin
    if (Haystack[I].Equals(Needle)) then
    begin
      Result := True;
      break;
    end;
  end;
end;

constructor TActiveQueueModel.Create(const RequestSaverFactory: TRequestSaverFactory<TActiveQueueEntry>);
begin
  Writeln('Creating a model...');
  FConsumerLock := TObject.Create;
  FQueueLock := TObject.Create;
  FClientLock := TObject.Create;
  FConsumerIndex := TDictionary<String, TConsumer>.Create;
  FConsumerProxyIndex := TDictionary<String, IConsumerProxy>.Create();
  FItems := TQueue < TPair < String, TActiveQueueEntry >>.Create();
  SetLength(FListenersIPs, 0);
  SetLength(FProvidersIPs, 0);
  FConsumerCategoryToTokens := TDictionary<String, TStringList>.Create();
  FRequestSaverFactory := RequestSaverFactory;
  CheckRep();
end;

function TActiveQueueModel.CreateCategoryToTokenMap(
  const Index: TDictionary<String, TConsumer>): TDictionary<String, TStringList>;
var
  AConsumer: TConsumer;
  AToken: String;
  ACategory: String;
begin
  Result := TDictionary<String, TStringList>.Create;
  for AToken in Index.Keys do
  begin
    ACategory := Index[AToken].Category;
    if not(Result.ContainsKey(ACategory)) then
    begin
      Result.Add(ACategory, TStringList.Create);
    end;
    Result[ACategory].Append(AToken);
    Writeln('Stub: adding token ' + AToken + ' to the category ' + ACategory);
  end;
end;

function TActiveQueueModel.CreateClientIndex(const TheClients: TObjectList<TClient>): TDictionary<String, TClient>;
var
  item: TClient;
  Token: String;
  ErrorMessage: String;
begin
  Writeln('Acquiring FClientLock');
  TMonitor.Enter(FClientLock);
  Writeln('FClientLock Acquired');
  try
    ErrorMessage := '';
    Result := TDictionary<String, TClient>.Create();
    for Item in TheClients do
    begin
      Token := Item.Token;
      if Result.ContainsKey(Token) then
      begin
        ErrorMessage := 'A pair of clients with a token ' + Token + ' is found!';
        Break;
      end
      else
      begin
        Result.Add(Token, Item.Clone);
      end;
    end;
  finally
    TMonitor.Exit(FClientLock);
  end;
  if ErrorMessage <> '' then
    raise Exception.Create(ErrorMessage);
end;

function TActiveQueueModel.CreateConsumerIndex(
  const TheConsumers: TObjectList<TConsumer>; const WhiteList: TDictionary<String, Boolean>): TDictionary<String, TConsumer>;
var
  item: TConsumer;
  Token, ErrorMessage: String;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    ErrorMessage := '';
    Result := TDictionary<String, TConsumer>.Create();
    if WhiteList <> nil then
      for Item in TheConsumers do
      begin
        if Whitelist.ContainsKey(Item.IP) then
        begin
          Token := Item.Token;
          if Result.ContainsKey(Token) then
          begin
            ErrorMessage := 'A pair of consumers with a token ' + Token + ' is found!';
            Break;
          end
          else
          begin
            Result.Add(Token, Item.Clone);
          end;
        end;
      end;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
  if ErrorMessage <> '' then
    raise Exception.Create(ErrorMessage);
end;

function TActiveQueueModel.CreateConsumerProxyIndex(
  const ConsumerIndex: TDictionary<String, TConsumer>): TDictionary<String, IConsumerProxy>;
var
  Adapter: TRestAdapter<IConsumerProxy>;
  Token: String;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Result := TDictionary<String, IConsumerProxy>.Create();
    for Token in ConsumerIndex.Keys do
    begin
      Adapter := TRestAdapter<IConsumerProxy>.Create();
      Result.add(Token, Adapter.Build(ConsumerIndex[Token].Ip, ConsumerIndex[Token].Port));
      // Adapter := nil;
    end;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
end;

destructor TActiveQueueModel.Destroy;
var
  Key, Category: String;
begin
  Writeln('Start destroying the model...');
  Writeln('Destroying three lock objects...');
  FConsumerLock.DisposeOf;
  FQueueLock.DisposeOf;
  FClientLock.DisposeOf;
  // remove objects from the register and clean the register afterwards
  Writeln('Iterate over FConsumerIndex ...');
  if FConsumerIndex <> nil then
  begin
    Writeln('FConsumerIndex is not nil');
    for Key in FConsumerIndex.Keys do
    begin
      Writeln('Destroying key ' + Key);
      FConsumerIndex[Key].DisposeOf;
    end;
    Writeln('Cleaning and disposing FConsumerIndex...');
    FConsumerIndex.Clear;
    FConsumerIndex.DisposeOf;
    for Category in FConsumerCategoryToTokens.Keys do
    begin
      FConsumerCategoryToTokens[Category].DisposeOf;
    end;
    FConsumerCategoryToTokens.Clear;
    FConsumerCategoryToTokens.DisposeOf();
  end;

  Writeln('Iterate over FClientIndex...');
  if FClientIndex <> nil then
  begin
    Writeln('FClientIndex is not nil');
    for Key in FClientIndex.Keys do
    begin
      Writeln('Destroying key ' + Key);
      FClientIndex[Key].DisposeOf;
    end;
    Writeln('Cleaning and disposing FClientIndex...');
    FClientIndex.Clear;
    FClientIndex.DisposeOf;
  end;

  Writeln('Cleaning and disposing FConsumerWhiteListHashSet...');
  if FConsumerWhiteListHashSet <> nil then
  begin
    Writeln('FConsumerWhiteListHashSet is not nil');
    FConsumerWhiteListHashSet.Clear;
    FConsumerWhiteListHashSet.DisposeOf;
  end;

  Writeln('Itearet over FConsumerProxyIndex...');
  for Key in FConsumerProxyIndex.Keys do
  begin
    Writeln('Set to nil ' + Key);
    FConsumerProxyIndex[Key] := nil;
  end;
  Writeln('Cleaning and disposing FConsumerProxyIndex...');
  FConsumerProxyIndex.Clear;
  FConsumerProxyIndex.DisposeOf;

  Writeln('Cleaning and disposing FItems...');
  FItems.Clear;
  FItems.DisposeOf;
  SetLength(FListenersIPs, 0);

  if FStateSaver <> nil then
  begin
    Writeln('Disposing FStateSaver...');
    FStateSaver.DisposeOf;
  end;

  Writeln('Setting storages to nil...');
  FRequestsStorage := nil;
  FRequestRepoConfig.DisposeOf;

  Writeln('Setting factories to nil...');
  FRequestSaverFactory.DisposeOf;

  Writeln('Finish destroying the model...');
  inherited;

end;

function TActiveQueueModel.GetClients: TObjectList<TClient>;
var
  Item: String;
begin
  Writeln('Acquiring FClientLock');
  TMonitor.Enter(FClientLock);
  Writeln('FClientLock Acquired');
  try
    Result := TObjectList<TClient>.Create();
    for Item in FClientIndex.Keys do
      Result.Add(FClientIndex[Item].Clone())
  finally
    TMonitor.Exit(FClientLock);
  end;
end;

function TActiveQueueModel.GetConfig: TAQConfigImmutable;
var
  TheClients: TObjectList<TClient>;
  TheConsumers: TObjectList<TConsumer>;
begin
  TheClients := GetClients();
  TheConsumers := GetConsumers();
  Result := TAQConfigImmutable.Create(FPort, FToken, ConsumerIPWhitelist, TheClients, TheConsumers, FRequestRepoConfig);
  TheClients.Clear;
  TheClients.DisposeOf;
  TheConsumers.Clear;
  TheConsumers.DisposeOf;
end;

function TActiveQueueModel.GetConsumerIPWhitelist: String;
var
  builder: TStringBuilder;
  Key, ExtraSymbolAtEnd: String;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Builder := TStringBuilder.Create();
    for Key in FConsumerWhiteListHashSet.Keys do
      Builder.Append(Key + WHITELIST_IP_SEPARATOR);
    ExtraSymbolAtEnd := Builder.ToString;
    if ExtraSymbolAtEnd <> '' then
      Result := copy(ExtraSymbolAtEnd, 1, Length(ExtraSymbolAtEnd) - Length(WHITELIST_IP_SEPARATOR))
    else
      Result := ExtraSymbolAtEnd;
    Builder.DisposeOf;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
end;

function TActiveQueueModel.GetItems(const Ip: String; const Token: String; const N: Integer): TObjectList<TActiveQueueEntry>;
var
  Size, ReturnSize, I: Integer;
  Item: TPair<String, TActiveQueueEntry>;
begin
  Result := TObjectList<TActiveQueueEntry>.Create();
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    if (N >= 0) AND FConsumerIndex.ContainsKey(Token) then
    begin
      Writeln('Acquiring FQueueLock');
      TMonitor.Enter(FQueueLock);
      Writeln('FQueueLock Acquired');
      Size := FItems.Count;
      if Size < N then
        ReturnSize := Size
      else
        ReturnSize := N;
      for I := 0 to ReturnSize - 1 do
      begin
        Item := FItems.Dequeue;
        FRequestsStorage.Delete(Item.Key);
        Result.Add(Item.Value.Clone);
        Item.Value.DisposeOf;
      end;
      Writeln('Releasing FQueueLock');
      TMonitor.Exit(FQueueLock);
      Writeln('FQueueLock Released');
    end;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
  Writeln('Returning ' + Result.Count.ToString + ' item in request for ' + N.ToString + ' ones.');
end;

function TActiveQueueModel.GetListenersIPs: TArray<String>;
var
  I, S: Integer;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    If Assigned(FListenersIPs) then
      S := Length(FListenersIPs)
    else
      S := 0;
    Result := TArray<String>.Create();
    SetLength(Result, S);
    for I := 0 to S - 1 do
      Result[I] := FListenersIPs[I];
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  Result := FConsumerIndex.Count;
  Writeln('Releasing the lock FConsumerLock');
  TMonitor.Exit(FConsumerLock);
  Writeln('Lock FConsumerLock released');
end;

function TActiveQueueModel.GetPort: Integer;
begin
  Result := FPort
end;

function TActiveQueueModel.GetToken: String;
begin
  Result := FToken
end;

function TActiveQueueModel.GetProvidersIPs: TArray<String>;
var
  I, S: Integer;
begin
  Writeln('Acquiring FClientLock');
  TMonitor.Enter(FClientLock);
  Writeln('FClientLock Acquired');
  try
    If Assigned(FProvidersIPs) then
      S := Length(FProvidersIPs)
    else
      S := 0;
    Result := TArray<String>.Create();
    SetLength(Result, S);
    for I := 0 to S - 1 do
      Result[I] := FProvidersIPs[I];
  finally
    Writeln('Releasing FClientLock');
    TMonitor.Exit(FClientLock);
    Writeln('FClientLock Released');
  end;
end;

function TActiveQueueModel.GetRequestRepositoryParams: TArray<TPair<String, String>>;
begin
  if FRequestsStorage <> nil then
    Result := FRequestsStorage.GetParams
  else
    Result := nil;
end;

function TActiveQueueModel.GetConsumers: TObjectList<TConsumer>;
var
  Token: String;
begin
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Result := TObjectList<TConsumer>.Create();
    for Token in FConsumerIndex.Keys do
      Result.Add(FConsumerIndex[Token].Clone())
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;

end;

function TActiveQueueModel.IsAllowedClient(const Token, IP: String): Boolean;
begin
  Writeln('Acquiring FClientLock');
  TMonitor.Enter(FClientLock);
  Writeln('FClientLock Acquired');
  try
    Result := FClientIndex.ContainsKey(Token) AND (FClientIndex[Token].IP = IP)
  finally
    Writeln('Releasing FClientLock');
    TMonitor.Exit(FClientLock);
    Writeln('FClientLock released');
  end;
end;

function TActiveQueueModel.IsIpInWhiteList(const IP: String): Boolean;
begin
  /// do not acquire the lock of FConsumerLock,
  /// since this method gets called from methods that has already acquired the lock.
  /// If you try to acquire the lock, the application enters in a deadlock.
  Result := FConsumerWhiteListHashSet.ContainsKey(IP);
end;

function TActiveQueueModel.IsSubscribed(const IP: String; const Port: Integer): Boolean;
var
  aConsumer: TConsumer;
  Key: String;
  Obj: TObject;
begin
  Obj := FConsumerLock;
  Result := False;
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(Obj);
  Writeln('Lock FConsumerLock acquired');
  try
    for Key in FConsumerIndex.Keys do
    begin
      aConsumer := FConsumerIndex[Key];
      if (aConsumer.IP = IP) AND (aConsumer.Port = Port) then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(Obj);
    Writeln('Lock FConsumerLock released');
  end;

end;

procedure TActiveQueueModel.NotifyListenerInSeparateThread(const Listener: IConsumerProxy);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      id: Integer;
    begin
      id := TThread.CurrentThread.ThreadID;
      Writeln(Format('Thread %d started', [id]));
      if Listener <> nil then
      begin
        try
          Listener.Notify();
        except
          on E: Exception do
            Writeln(E.Message);
        end;
      end
      else
        Writeln('Listener is null');
      Writeln(Format('Thread %d finished', [id]));
    end
    ).Start;

end;

procedure TActiveQueueModel.NotifyListeners(const Categories: TStringList);
var
  Token: String;
  Category: String;
  Tokens: TStringList;
begin
  Writeln('Start TTActiveQueueModel.NotifyListeners');
  Writeln('Acquiring the lock FConsumerLock');
  TMonitor.Enter(FConsumerLock);
  Writeln('Lock FConsumerLock acquired');
  try
    Tokens := TStringList.Create();
    for Category in Categories do
    begin
      if FConsumerCategoryToTokens.ContainsKey(Category) then
      begin
        for Token in FConsumerCategoryToTokens[Category] do
        begin
          Tokens.Add(Token);
        end;
      end
      else
        Writeln('Category ' + Category + ' has no listeners');
    end;
    for Token in Tokens do
    begin
      Writeln(Format('Notify listener %3s', [Token]));
      NotifyListenerInSeparateThread(FConsumerProxyIndex[Token]);
      Writeln(Format('Listener %3s has been notified', [Token]));
    end;
    Tokens.Clear;
    Tokens.DisposeOf;
  finally
    Writeln('Releasing the lock FConsumerLock');
    TMonitor.Exit(FConsumerLock);
    Writeln('Lock FConsumerLock released');
  end;
  Writeln('End TTActiveQueueModel.NotifyListeners');
end;


procedure TActiveQueueModel.SetQueuePath(const Path: String);
begin
  FQueueFilePath := Path;
end;

procedure TActiveQueueModel.SetTargetConfigPath(const Value: String);
begin
  FStateSaver := TJsonSaver.Create(Value);
end;

procedure TActiveQueueModel.SetConfig(const Config: TAQConfigImmutable);
var
  Consumers: TObjectList<TConsumer>;
  Clients: TObjectList<TClient>;
  Requests: TDictionary<String, TActiveQueueEntry>;
begin
  if Config = nil then
    raise Exception.Create('Can not set configuration to a null object!');

  /// set up primitive types
  FPort := Config.Port;
  FToken := Config.Token;

  /// set up clients
  Clients := Config.Clients;
  FClientIndex := CreateClientIndex(Clients);
  Clients.Clear;
  Clients.DisposeOf;

  /// set up the consumer whitelist
  FConsumerWhiteListHashSet := CommaSeparatedStrToHashSet(Config.ConsumerWhitelist, WHITELIST_IP_SEPARATOR);

  /// set up the consumers
  Consumers := Config.Consumers;
  FConsumerIndex.DisposeOf;
  FConsumerIndex := CreateConsumerIndex(Consumers, FConsumerWhiteListHashSet);
  FConsumerCategoryToTokens.Clear;
  FConsumerCategoryToTokens.DisposeOf;
  FConsumerCategoryToTokens := CreateCategoryToTokenMap(FConsumerIndex);
  Consumers.Clear;
  Consumers.DisposeOf;

  /// set up consumer proxies
  if (FConsumerIndex.Count > 0) then
  begin
    FConsumerProxyIndex.Clear;
    FConsumerProxyIndex.DisposeOf;
  end;
  FConsumerProxyIndex := CreateConsumerProxyIndex(FConsumerIndex);

  FRequestRepoConfig := Config.RequestsRepository;
  FRequestsStorage := FRequestSaverFactory.CreateStorage(FRequestRepoConfig);
  try
    Requests := FRequestsStorage.GetPendingRequests;
    Enqueue(Requests);
  finally
    if Requests <> nil then
    begin
      Requests.Clear;
      Requests.DisposeOf;
    end;

  end;

end;

function TActiveQueueModel.PersistRequests(const Items: TObjectList<TActiveQueueEntry>): TDictionary<String, TActiveQueueEntry>;
var
  Item: TActiveQueueEntry;
  Id: String;
begin
  Writeln('Start TActiveQueueModel.PersistRequests');
  Writeln('Acquiring FQueueLock');
  TMonitor.Enter(FQueueLock);
  Writeln('FQueueLock Acquired');
  try
    Result := TDictionary<String, TActiveQueueEntry>.Create;
    for Item in Items do
    begin
      try
        Id := FRequestsStorage.Save(Item);
      except
        on E: Exception do
        begin
          Writeln('TActiveQueueModel.PersistRequests exception: ' + E.Message);
          Result.DisposeOf;
          raise Exception.Create('AQ model storage failed to save an item. Reason: ' + E.Message);
        end;
      end;
      Result.Add(Id, Item);
    end;
  finally
    Writeln('Releasing FQueueLock');
    TMonitor.Exit(FQueueLock);
    Writeln('FQueueLock Released');
  end;
  Writeln('End TActiveQueueModel.PersistRequests');

end;

procedure TActiveQueueModel.PersistState;
var
  State: TAQConfigImmutable;
begin
  State := GetConfig();
  FStateSaver.save(State);
  State.DisposeOf;
end;

end.
