unit AQModel;

interface

uses
  AQSubscriptionResponce, AQSubscriptionEntry, ActiveQueueEntry,
  System.Classes, Consumer, System.Generics.Collections, ListenerProxyInterface,
  ConditionInterface, AQConfig, JsonSaver, Client;

type
  TAQSubscriptionResponceMessages = class abstract(TObject)
  const
  var
  NO_SUBSCRIPTION_DATA = 'No subscription data is found.';
  NOT_AUTHORISED = 'Not authorised';
  ALREADY_SUBSCRIBED = 'Already subscribed';
  SUBSCRIBE_SUCCESS = 'Successfully subscribed.';
  UNSUBSCRIBE_SUCCESS = 'Successfully unsubscribed.';
  NOT_AUTHENTICATED = 'Wrong token.';
  NOT_SUBSCRIBED = 'Not subscribed';
  end;

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

    /// items of the queue
    FItems: TQueue<TActiveQueueEntry>;

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

    /// <summary>a class instance by means of which the queue is persisted<summary>
    FQueueSaver: TJsonSaver;

    /// <summary>The number of the subscriptions</sumamry>
    function GetNumOfSubscriptions: Integer;

    /// <summary>Return true if given the consumer index contains a client with given ip and port.</summary>
    function IsSubscribed(const IP: String; const Port: Integer): Boolean;

    /// <summary>Check the consistency of the reresenation</summary>
    procedure checkRep();

    /// <summary>Notify all subscribed listeners that the queue state has changed.
    /// NB: each listeners is notified in a separate thread. It might be a problem if the
    /// number of listeners is high.</summary>
    procedure NotifyListeners();

    /// <sumary>Inform the listeners that they should cancel items satisfying the condition</summary>
    procedure BroadcastCancel(const Condition: ICondition);

    /// <sumary>Cancel local items of the queue for which the condition is true.</summary>
    function CancelLocal(const Condition: ICondition): Integer;

    /// a helper function that joins all elements using given delimiter
    function Join(const Items: TArray<String>; const delimiter: String): String;

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

    /// <summary>Create a hash set from a comma seprated string.</summary>
    function CommaSeparatedStrToHashSet(const Data, Separator: String): TDictionary<String, Boolean>;

    function GetConfig: TAQConfigImmutable;

    /// <summary>Set the state of the model.</summary>
    /// This method is placed here in order to be able to persist the model state changes
    /// (mostly due to the adding/cancelling the listeners) in real time mode: once a change occurs,
    /// the new state is saved.
    procedure SetConfig(const Config: TAQConfigImmutable);

    function GetPort: Integer;

    function GetClients: TObjectList<TClient>;

    function GetConsumerIPWhitelist: String;
  private
    procedure SetTargetConfigPath(const Value: String);

  public
    /// <summary>Create a subscription </summary>
    /// <param name="IP">IP from which the subscription request has arrived</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddConsumer(const IP: String; const Data: TAQSubscriptionEntry): TAQSubscriptionResponce;

    /// <summary>Get all subscribed listeners</summary>
    function GetConsumers(): TObjectList<TConsumer>;

    /// <summary>Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    /// <param name="Token">token associated with the subscription</param>
    function CancelConsumer(const Ip, Token: String): TAQSubscriptionResponce;

    /// get not more that N items from the queue.
    function GetItems(const Ip: String; const Token: String; const N: Integer): TObjectList<TActiveQueueEntry>;

    /// <summary>Add many items to the pull</summary>
    /// <param name="Items">list of elements to be added to the queue</param>
    /// <param name="IP">ip of the computer from which the request originates</param>
    /// <returns>True in case of success, False otherwise</returns>
    function Enqueue(const IP: String; const Items: TObjectList<TActiveQueueEntry>): Boolean;

    /// <summary> Get the IPs from which the subscriptions can be accepted.</summary>
    function GetListenersIPs: TArray<String>;

    /// <summary> Get the IPs from which the requests to enqueue the data can be accepted.</summary>
    function GetProvidersIPs: TArray<String>;

    /// <summary>Return true iff given IP is among those from which a subscription can be accepted.</summary>
    function IsIpInWhiteList(const IP: String): Boolean;

    /// <summary>Return true iff given IP is among those from which data can be enqueued.</summary>
    function IsAllowedProvider(const IP: String): Boolean;

    /// <summary>Cancel local items of the queue for which the condition is true. Then informs the
    /// listeners to cancel the items that satisfy the condition.
    /// Returns the number of items cancelled from the local storage, or -1 of the request comes from a
    /// computer with non-allowed IP.</summary>
    function Cancel(const IP: string; const Condition: ICondition): Integer;

    procedure SetQueue(const FilePath: String; const Items: TObjectList<TActiveQueueEntry>);

    /// <summary> the number of subscriptions </summary>
    property numOfSubscriptions: Integer read GetNumOfSubscriptions;

    /// <summary>the number of a port to which this service is bound</summary>
    property Port: Integer read GetPort;

    property Config: TAQConfigImmutable read GetConfig write SetConfig;

    property TargetConfigPath: String read FTargetConfigPath write SetTargetConfigPath;

    property ConsumerIPWhitelist: String read GetConsumerIPWhitelist;

    /// <summary>A copy of  the clients</summary>
    property Clients: TObjectList<TClient> read GetClients;

    /// <summary>Save the state of the Active Queue server into a file</summary>
    procedure PersistState();

    /// <summary>Persist the queue in its current state</summary>
    procedure PersistQueue();

    procedure SetQueuePath(const path: String);

    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  System.SysUtils, MVCFramework.RESTAdapter, System.JSON, System.IOUtils,
  JsonableInterface, System.RegularExpressions;
{ TActiveQueueModel }

function TActiveQueueModel.Enqueue(const IP: String; const Items: TObjectList<TActiveQueueEntry>): Boolean;
var
  item: TActiveQueueEntry;
begin
  Writeln('Enqueueing ' + inttostr(Items.Count) + ' item(s)');
  TMonitor.Enter(FQueueLock);
  try
    try
      for item in Items do
      begin
        FItems.Enqueue(item);
        Writeln('Item added to the queue...');
      end;
      Result := True;
      Writeln('returning true');
    except
      on E: Exception do
      begin
        Writeln('Error while adding to the queue: ' + E.Message);
        Result := False;
      end;
    end;
  finally
    TMonitor.Exit(FQueueLock);
  end;
  NotifyListeners();

end;

function TActiveQueueModel.AddConsumer(const IP: String; const data: TAQSubscriptionEntry): TAQSubscriptionResponce;
var
  Token: String;
  Guid: TGUID;
begin
  TMonitor.Enter(FConsumerLock);
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
          Result := TAQSubscriptionResponce.Create(True, TAQSubscriptionResponceMessages.SUBSCRIBE_SUCCESS, Token);
        end;
      end;
    end;
    CheckRep();
  finally
    TMonitor.Exit(FConsumerLock);
  end;

end;

procedure TActiveQueueModel.BroadcastCancel(const Condition: ICondition);
var
  Listener: TPair<String, IConsumerProxy>;
begin
  TMonitor.Enter(FConsumerLock);
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
    TMonitor.Exit(FConsumerLock);
  end;
end;

function TActiveQueueModel.Cancel(const IP: string; const Condition: ICondition): Integer;
begin
  if (IsAllowedProvider(IP)) then
  begin
    Result := CancelLocal(Condition);
    BroadcastCancel(Condition);
  end
  else
    Result := -1;
end;

function TActiveQueueModel.CancelLocal(const Condition: ICondition): Integer;
// var
// item: TActiveQueueEntry;
begin
  TMonitor.Enter(FQueueLock);
  Result := 0;
  try
    Writeln('cancelling an item is not yet implemented when FItems is of TQueue type');
    // for Item in FItems do
    // begin
    // if Condition.Satisfy(Item) then
    // begin
    // FItems.Remove(Item);
    // Result := Result + 1;
    // end;
    // end;
  finally
    TMonitor.Exit(FQueueLock);
  end;
end;

function TActiveQueueModel.CancelConsumer(const Ip, Token: String): TAQSubscriptionResponce;
var
  subscription: TConsumer;
begin
  TMonitor.Enter(FConsumerLock);
  try
    Writeln('Unsubscribe: ip = ' + ip + ', token ' + Token);
    if Not(IsIpInWhiteList(Ip)) then
      Result := TAQSubscriptionResponce.Create(False, TAQSubscriptionResponceMessages.NOT_AUTHORISED, '')
    else
    begin
      if (FConsumerIndex.ContainsKey(Token)) then
      begin
        subscription := FConsumerIndex[Token];
        if (subscription.Ip = Ip) then
        begin
          subscription.DisposeOf;
          FConsumerIndex.Remove(Token);
          FConsumerProxyIndex[Token] := nil;
          FConsumerProxyIndex.Remove(Token);
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
    TMonitor.Exit(FConsumerLock);
  end;
end;

procedure TActiveQueueModel.checkRep;
var
  IsOk: Boolean;
  Token: String; { TODO -oAndrew : skip it in the production }
begin
  TMonitor.Enter(FQueueLock);
  try
    IsOk := (FConsumerLock <> nil) AND (FClientLock <> nil)
      AND (Length(FListenersIPs) >= 0)
      AND (FConsumerIndex <> nil)
      AND (FConsumerProxyIndex <> nil)
      AND (FConsumerProxyIndex.Count = FConsumerIndex.Count);

    if IsOk then
    begin
      for Token in FConsumerProxyIndex.Keys do
        if Not(FConsumerIndex.ContainsKey(Token)) then
        begin
          raise Exception.Create('Inconsistent rep of TActiveQueueModel: token mismatch');
        end;
    end
    else
      raise Exception.Create('Inconsistent rep of TActiveQueueModel');
  finally
    TMonitor.Exit(FQueueLock);
  end;

end;

function TActiveQueueModel.CommaSeparatedStrToHashSet(const Data, Separator: String): TDictionary<String, Boolean>;
var
  Item, Key: String;
  Items: TArray<string>;
begin
  TMonitor.Enter(FConsumerLock);
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
    TMonitor.Exit(FConsumerLock);
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

constructor TActiveQueueModel.Create();
begin
  Writeln('Creating a model...');
  FConsumerLock := TObject.Create;
  FQueueLock := TObject.Create;
  FClientLock := TObject.Create;
  FConsumerIndex := TDictionary<String, TConsumer>.Create;
  FConsumerProxyIndex := TDictionary<String, IConsumerProxy>.Create();
  FItems := TQueue<TActiveQueueEntry>.Create();
  SetLength(FListenersIPs, 0);
  SetLength(FProvidersIPs, 0);

  // FQueueSaver := TJsonSaver.Create();
  CheckRep();
end;

function TActiveQueueModel.CreateClientIndex(const TheClients: TObjectList<TClient>): TDictionary<String, TClient>;
var
  item: TClient;
  Token: String;
  ErrorMessage: String;
begin
  TMonitor.Enter(FClientLock);
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
  TMonitor.Enter(FConsumerLock);
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
    TMonitor.Exit(FConsumerLock);
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
  TMonitor.Enter(FConsumerLock);
  try
    Result := TDictionary<String, IConsumerProxy>.Create();
    for Token in ConsumerIndex.Keys do
    begin
      Adapter := TRestAdapter<IConsumerProxy>.Create();
      Result.add(Token, Adapter.Build(ConsumerIndex[Token].Ip, ConsumerIndex[Token].Port));
      // Adapter := nil;
    end;
  finally
    TMonitor.Exit(FConsumerLock);
  end;
end;

destructor TActiveQueueModel.Destroy;
var
  Key: String;
begin
  Writeln('Destroying the model...');
  FConsumerLock.DisposeOf;
  FQueueLock.DisposeOf;
  FClientLock.DisposeOf;
  // remove objects from the register and clean the register afterwards
  for Key in FConsumerIndex.Keys do
  begin
    FConsumerIndex[Key].DisposeOf;
  end;
  FConsumerIndex.Clear;
  FConsumerIndex.DisposeOf;

  for Key in FClientIndex.Keys do
  begin
    FClientIndex[Key].DisposeOf;
  end;
  FClientIndex.Clear;
  FClientIndex.DisposeOf;

  FConsumerWhiteListHashSet.Clear;
  FConsumerWhiteListHashSet.DisposeOf;

  FConsumerProxyIndex.Clear;
  FConsumerProxyIndex.DisposeOf;
  FItems.Clear;
  FItems.DisposeOf;
  SetLength(FListenersIPs, 0);
  if FStateSaver <> nil then
    FStateSaver.DisposeOf;

  FQueueSaver.Disposeof;
  inherited;

end;

function TActiveQueueModel.GetClients: TObjectList<TClient>;
var
  Item: String;
begin
  TMonitor.Enter(FClientLock);
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
  Result := TAQConfigImmutable.Create(FPort, FToken, ConsumerIPWhitelist, TheClients, TheConsumers);
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
  TMonitor.Enter(FConsumerLock);
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
    TMonitor.Exit(FConsumerLock);
  end;
end;

function TActiveQueueModel.GetItems(const Ip: String; const Token: String; const N: Integer): TObjectList<TActiveQueueEntry>;
var
  Size, ReturnSize, I: Integer;
begin
  Result := TObjectList<TActiveQueueEntry>.Create();
  TMonitor.Enter(FConsumerLock);
  try
    if (N >= 0) AND FConsumerIndex.ContainsKey(Token) then
    begin
      TMonitor.Enter(FQueueLock);
      Size := FItems.Count;
      if Size < N then
        ReturnSize := Size
      else
        ReturnSize := N;
      for I := 0 to ReturnSize - 1 do
      begin
        Result.Add(FItems.Dequeue);
      end;
      TMonitor.Exit(FQueueLock);
    end;
  finally
    TMonitor.Exit(FConsumerLock);
  end;
  Writeln('Returning ' + Result.Count.ToString + ' item in request for ' + N.ToString + ' ones.');
end;

function TActiveQueueModel.GetListenersIPs: TArray<String>;
var
  I, S: Integer;
begin
  TMonitor.Enter(FConsumerLock);
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
    TMonitor.Exit(FConsumerLock);
  end;
end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FConsumerLock);
  Result := FConsumerIndex.Count;
  TMonitor.Exit(FConsumerLock);
end;

function TActiveQueueModel.GetPort: Integer;
begin
  Result := FPort
end;

function TActiveQueueModel.GetProvidersIPs: TArray<String>;
var
  I, S: Integer;
begin
  TMonitor.Enter(FClientLock);
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
    TMonitor.Exit(FClientLock);
  end;
end;

function TActiveQueueModel.GetConsumers: TObjectList<TConsumer>;
var
  Token: String;
begin
  TMonitor.Enter(FConsumerLock);
  try
    Result := TObjectList<TConsumer>.Create();
    for Token in FConsumerIndex.Keys do
      Result.Add(FConsumerIndex[Token].Clone())
  finally
    TMonitor.Exit(FConsumerLock);
  end;

end;

function TActiveQueueModel.IsAllowedProvider(const IP: String): Boolean;
begin
  TMonitor.Enter(FClientLock);
  try
    Result := Contains(FProvidersIPs, IP);
  finally
    TMonitor.Exit(FClientLock);
  end;
end;

function TActiveQueueModel.IsIpInWhiteList(const IP: String): Boolean;
begin
  TMonitor.Enter(FConsumerLock);
  try
    Result := FConsumerWhiteListHashSet.ContainsKey(IP);
  finally
    TMonitor.Exit(FConsumerLock);
  end;
end;

function TActiveQueueModel.IsSubscribed(const IP: String; const Port: Integer): Boolean;
var
  aConsumer: TConsumer;
  Key: String;
begin
  Result := False;
  TMonitor.Enter(FConsumerLock);
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
    TMonitor.Exit(FConsumerLock);
  end;

end;

function TActiveQueueModel.Join(const Items: TArray<String>; const delimiter: String): String;
var
  I, L: Integer;
begin
  Result := '';
  L := Length(Items);
  for I := 0 to L - 2 do
    Result := Result + Items[I] + delimiter;
  if L > 0 then
    Result := Result + Items[L - 1];

end;

procedure TActiveQueueModel.NotifyListeners;
var
  Token: String;
  // Listener: IListenerProxy;
begin
  Writeln('Notifying the listeners');
  TMonitor.Enter(FConsumerLock);
  try
    for Token in FConsumerProxyIndex.Keys do
      TThread.CreateAnonymousThread(
        procedure
        var
          Listener: IConsumerProxy;
        begin
          Listener := FConsumerProxyIndex[Token];
          if Listener <> nil then
            try
              Listener.Notify();
              Writeln(Format('Listener at %s:%d is notified.', [FConsumerIndex[Token].IP, FConsumerIndex[Token].Port]));
            except
              on E: Exception do
                Writeln(E.Message);
            end;
        end
        ).Start;
  finally
    TMonitor.Exit(FConsumerLock);
  end;
end;

procedure TActiveQueueModel.SetQueue(const FilePath: String; const Items: TObjectList<TActiveQueueEntry>);
begin
  // raise Exception.Create('TActiveQueueModel.SetQueue is not implemented');
  Writeln('Here, the queue must be saved, but it is yet to be done');
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
  Consumers.Clear;
  Consumers.DisposeOf;

  /// set up consumer proxies
  if (FConsumerIndex.Count > 0) then
  begin
    FConsumerProxyIndex.Clear;
    FConsumerProxyIndex.DisposeOf;
  end;
  FConsumerProxyIndex := CreateConsumerProxyIndex(FConsumerIndex);

end;

procedure TActiveQueueModel.PersistQueue;
var
  Request: TActiveQueueEntry;
  items: TList<Jsonable>;
begin
  TMonitor.Enter(FQueueLock);
  try
    Items := TList<Jsonable>.Create();
    for Request in FItems do
    begin
      Items.Add(Request as Jsonable);
    end;
    Writeln('At this moment, the queue must be saved somewhere, but it is not...');
    // FQueueSaver.SaveMulti(FQueueFilePath, Items);
    Items.Clear;
    Items.DisposeOf;
  finally
    TMonitor.Exit(FQueueLock);
  end;
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
