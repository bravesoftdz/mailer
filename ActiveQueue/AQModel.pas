unit AQModel;

interface

uses
  ActiveQueueResponce, SubscriptionData, ActiveQueueEntry,
  System.Classes, ListenerInfo, System.Generics.Collections, ListenerProxyInterface,
  ConditionInterface, AQConfig, JsonSaver, Client;

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
  var
    /// a dumb lock object for managing the access to the  subscription register
    FListenersLock: TObject;

    /// a dumb lock object for managing the access to the providers' ips
    FProvidersLock: TObject;

    /// a dumb lock object for managing the access to the queue items
    FQueueLock: TObject;

    /// <summary>Current configuration </summary>
    FConfig: TAQConfig;

    /// <summary>Path to a file into which an updated version of the configuration is to be saved</summary>
    FTargetConfigPath: String;

    /// <summary>A dictionary for subscriptions: the keys are unique ids assigned
    /// to the subscriptions, the values are objects containing subscription information</summary>
    FSubscriptionRegister: TDictionary<String, TSubscriptionData>;

    /// <summary>A map of proxies corresponding to currently subscribed listeners.
    /// Each pair is composed of a key that is a token issued during the subscription
    /// and a value that is a proxy server of the listener associated with the token.</summary>
    FProxyRegister: TDictionary<String, IListenerProxy>;

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

    /// <summary>Return true if given subscription data is already present in the register.</summary>
    function IsSubscribed(const Data: TSubscriptionData): Boolean;

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

    /// <summary> Set the IPs from which the subscriptions can be accepted.</summary>
    procedure SetListenersIPs(const IPs: TArray<String>);

    /// <summary> Set the IPs from which the requests to enqueue the data can be accepted.</summary>
    procedure SetProvidersIPs(const IPs: TArray<String>);

    /// <summary>Set the listeners</summary>
    procedure SetListeners(const Listeners: TObjectList<TListenerInfo>);

    function GetConfig: TAQConfig;

    /// <summary>Set the state of the model.</summary>
    /// This method is placed here in order to be able to persist the model state changes
    /// (mostly due to the adding/cancelling the listeners) in real time mode: once a change occurs,
    /// the new state is saved.
    procedure SetConfig(const Config: TAQConfig);

    function GetPort: Integer;

    function GetClients: TObjectList<TClient>;

  public
    /// <summary>Create a subscription </summary>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Data: TSubscriptionData): TActiveQueueResponce;

    /// <summary>Get all subscribed listeners</summary>
    function GetListeners(): TObjectList<TListenerInfo>;

    /// <summary>Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    /// <param name="Token">token associated with the subscription</param>
    function CancelSubscription(const Ip, Token: String): TActiveQueueResponce;

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
    function IsSubscribable(const IP: String): Boolean;

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

    property Config: TAQConfig read GetConfig write SetConfig;

    property TargetConfigPath: String read FTargetConfigPath write FTargetConfigPath;

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
      end;
      Result := True;
    except
      on E: Exception do
        Result := False;
    end;
  finally
    TMonitor.Exit(FQueueLock);
  end;
  NotifyListeners();

end;

function TActiveQueueModel.AddSubscription(const data: TSubscriptionData): TActiveQueueResponce;
var
  Token: String;
  Ip: String;
  Guid: TGUID;
begin
  TMonitor.Enter(FListenersLock);
  try
    if Data = nil then
    begin
      Result := TActiveQueueResponce.Create(False, 'invalid input', '');
    end
    else
    begin
      Ip := data.Ip;
      if Not(IsSubscribable(Ip)) then
        Result := TActiveQueueResponce.Create(False, 'not authorized', '')
      else
      begin
        if IsSubscribed(data) then
        begin
          Result := TActiveQueueResponce.Create(False, 'already subscribed', '');
        end
        else
        begin

          Repeat
            CreateGUID(Guid);
            Token := TRegEx.Replace(Guid.ToString, '[^a-zA-Z0-9_]', '');

          until Not(FSubscriptionRegister.ContainsKey(Token));
          // create a copy of the object
          FSubscriptionRegister.Add(Token, TSubscriptionData.Create(data.Ip, data.Url, data.Port, data.Path));
          FProxyRegister.Add(Token, TRestAdapter<IListenerProxy>.Create().Build(Data.Ip, Data.Port));
          Result := TActiveQueueResponce.Create(True, Ip + ':' + inttostr(data.Port), Token);
        end;
      end;
    end;
    CheckRep();
  finally
    TMonitor.Exit(FListenersLock);
  end;

end;

procedure TActiveQueueModel.BroadcastCancel(const Condition: ICondition);
var
  Listener: TPair<String, IListenerProxy>;
begin
  TMonitor.Enter(FListenersLock);
  try
    for Listener in FProxyRegister do
    begin
      try
        Listener.Value.Cancel(Condition);
      except
        on E: Exception do
          Writeln(E.Message);
      end;
    end;
  finally
    TMonitor.Exit(FListenersLock);
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
var
  item: TActiveQueueEntry;
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

function TActiveQueueModel.CancelSubscription(const Ip, Token: String): TActiveQueueResponce;
var
  subscription: TSubscriptionData;
begin
  TMonitor.Enter(FListenersLock);
  try
    if (FSubscriptionRegister.ContainsKey(Token)) then
    begin
      subscription := FSubscriptionRegister[Token];
      if (subscription.Ip = Ip) then
      begin
        subscription.DisposeOf;
        FSubscriptionRegister.Remove(Token);
        FProxyRegister[Token] := nil;
        FProxyRegister.Remove(Token);
        Result := TActiveQueueResponce.Create(True, 'unsubscribed', '');
      end
      else
        Result := TActiveQueueResponce.Create(False, 'wrong ip or token', '');
    end
    else
    begin
      Result := TActiveQueueResponce.Create(False, 'not subscribed', '');
    end;
    CheckRep();
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

procedure TActiveQueueModel.checkRep;
var
  IsOk: Boolean;
  Token: String; { TODO -oAndrew : skip it in the production }
begin
  TMonitor.Enter(FQueueLock);
  try
    IsOk := (FListenersLock <> nil) AND (FProvidersLock <> nil)
      AND (Length(FListenersIPs) >= 0)
      AND (FSubscriptionRegister <> nil)
      AND (FProxyRegister <> nil)
      AND (FProxyRegister.Count = FSubscriptionRegister.Count);

    if IsOk then
    begin
      for Token in FProxyRegister.Keys do
        if Not(FSubscriptionRegister.ContainsKey(Token)) then
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
  FListenersLock := TObject.Create;
  FQueueLock := TObject.Create;
  FProvidersLock := TObject.Create;
  FSubscriptionRegister := TDictionary<String, TSubscriptionData>.Create;
  FProxyRegister := TDictionary<String, IListenerProxy>.Create();
  FItems := TQueue<TActiveQueueEntry>.Create();
  SetLength(FListenersIPs, 0);
  SetLength(FProvidersIPs, 0);
  FStateSaver := TJsonSaver.Create();
  FQueueSaver := TJsonSaver.Create();
  CheckRep();
end;

destructor TActiveQueueModel.Destroy;
var
  ItemKey: String;
  I, S: Integer;
begin
  Writeln('Destroying the model...');
  FListenersLock.DisposeOf;
  FQueueLock.DisposeOf;
  FProvidersLock.DisposeOf;
  // remove objects from the register and clean the register afterwards
  for ItemKey in FSubscriptionRegister.Keys do
  begin
    FSubscriptionRegister[ItemKey].DisposeOf;
  end;
  FSubscriptionRegister.Clear;
  FSubscriptionRegister.DisposeOf;
  FProxyRegister.Clear;
  FProxyRegister.DisposeOf;
  // remove objects from the queue and clean the queue afterwards
  // S := FItems.Count;      /
  // for I := 0 to S - 1 do
  // FItems[I] := nil;
  FItems.Clear;
  FItems.DisposeOf;
  SetLength(FListenersIPs, 0);
  FStateSaver.DisposeOf;
  FQueueSaver.Disposeof;
  inherited;

end;

function TActiveQueueModel.GetClients: TObjectList<TClient>;
var
  Client: TClient;
begin
  Result := TObjectList<TClient>.Create();
  for Client in FConfig.Clients do
    Result.add(TClient.Create(Client.IP, Client.Token));
end;

function TActiveQueueModel.GetConfig: TAQConfig;
begin

end;

function TActiveQueueModel.GetItems(const Ip: String;
  const
  Token:
  String;
  const
  N:
  Integer): TObjectList<TActiveQueueEntry>;
var
  Size, ReturnSize, I: Integer;
begin
  Result := TObjectList<TActiveQueueEntry>.Create(True);
  TMonitor.Enter(FListenersLock);
  try
    if (N >= 0) AND FSubscriptionRegister.ContainsKey(Token) then
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
    TMonitor.Exit(FListenersLock);
  end;
  Writeln('Returning ' + Result.Count.ToString + ' item in request for ' + N.ToString + ' ones.');
end;

function TActiveQueueModel.GetListenersIPs: TArray<String>;
var
  I, S: Integer;
begin
  TMonitor.Enter(FListenersLock);
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
    TMonitor.Exit(FListenersLock);
  end;
end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FListenersLock);
  Result := FSubscriptionRegister.Count;
  TMonitor.Exit(FListenersLock);
end;

function TActiveQueueModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port
  else
    Result := -1;

end;

function TActiveQueueModel.GetProvidersIPs: TArray<String>;
var
  I, S: Integer;
begin
  TMonitor.Enter(FProvidersLock);
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
    TMonitor.Exit(FProvidersLock);
  end;
end;

function TActiveQueueModel.GetListeners: TObjectList<TListenerInfo>;
var
  Subscription: TSubscriptionData;
  Token: String;
  builder: TListenerInfoBuilder;
begin
  TMonitor.Enter(FListenersLock);
  try
    Result := TObjectList<TListenerInfo>.Create();
    for Token in FSubscriptionRegister.Keys do
    begin
      Subscription := FSubscriptionRegister[Token];
      builder := TListenerInfoBuilder.Create();
      Result.Add(builder
        .SetToken(Token)
        .SetIp(Subscription.Ip)
        .SetPort(Subscription.Port)
        .SetPath(Subscription.Path)
        .Build()
        );
      builder.DisposeOf;
    end;
  finally
    TMonitor.Exit(FListenersLock);
  end;

end;

function TActiveQueueModel.IsAllowedProvider(
  const
  IP:
  String): Boolean;
begin
  TMonitor.Enter(FProvidersLock);
  try
    Result := Contains(FProvidersIPs, IP);
  finally
    TMonitor.Exit(FProvidersLock);
  end;
end;

function TActiveQueueModel.IsSubscribable(
  const
  IP:
  String): Boolean;
begin
  TMonitor.Enter(FListenersLock);
  try
    Result := Contains(FListenersIPs, IP);
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

function TActiveQueueModel.IsSubscribed(
  const
  Data:
  TSubscriptionData): Boolean;
begin
  Result := FSubscriptionRegister.ContainsValue(Data);
end;

function TActiveQueueModel.Join(
  const
  Items:
  TArray<String>;
  const
  delimiter:
  String): String;
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
begin
  Writeln('Notifying the listeners');
  TMonitor.Enter(FListenersLock);
  try
    for Token in FProxyRegister.Keys do
      TThread.CreateAnonymousThread(
        procedure
        var
          Listener: IListenerProxy;
        begin
          Listener := FProxyRegister[Token];
          if Listener <> nil then
            try
              Listener.Notify();
            except
              on E: Exception do
                Writeln(E.Message);
            end;
        end).Start;
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

procedure TActiveQueueModel.SetListenersIPs(
  const
  IPs:
  TArray<String>);
var
  I, S: Integer;
begin
  TMonitor.Enter(FListenersLock);
  try
    S := Length(IPs);
    SetLength(FListenersIPs, S);
    for I := 0 to S - 1 do
      FListenersIPs[I] := IPs[I];
    CheckRep();
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

procedure TActiveQueueModel.SetProvidersIPs(
  const
  IPs:
  TArray<String>);
var
  I, S: Integer;
begin
  TMonitor.Enter(FProvidersLock);
  try
    S := Length(IPs);
    SetLength(FProvidersIPs, S);
    for I := 0 to S - 1 do
      FProvidersIPs[I] := IPs[I];
    CheckRep();
  finally
    TMonitor.Exit(FProvidersLock);
  end;
end;

procedure TActiveQueueModel.SetQueue(
  const
  FilePath:
  String;
const
  Items:
  TObjectList<TActiveQueueEntry>);
begin
  // raise Exception.Create('TActiveQueueModel.SetQueue is not implemented');
  Writeln('Here, the queue must be saved, but it is yet to be done');
end;

procedure TActiveQueueModel.SetQueuePath(
  const
  Path:
  String);
begin
  FQueueFilePath := Path;

end;

procedure TActiveQueueModel.SetConfig(
  const
  Config:
  TAQConfig);
begin
  FConfig := TAQConfig.Create(Config.Port, Config.Clients, Config.Token, Config.ConsumerWhitelist);
end;

procedure TActiveQueueModel.PersistQueue;
var
  arr: TJsonArray;
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
    FQueueSaver.SaveMulti(FQueueFilePath, Items);
    Items.Clear;
    Items.DisposeOf;
  finally
    TMonitor.Exit(FQueueLock);
  end;
end;

procedure TActiveQueueModel.PersistState;
var
  State: TAQConfig;
begin
  // State := TAQConfig.Create(FPort, Join(FListenersIPs, ','), Join(FProvidersIPs, ','), GetListeners());
  // FStateSaver.save(FStateFilePath, State);
  // State.DisposeOf;
end;

procedure TActiveQueueModel.SetListeners(
  const
  Listeners:
  TObjectList<TListenerInfo>);
var
  Listener: TListenerInfo;
begin
  TMonitor.Enter(FListenersLock);
  try
    FSubscriptionRegister.Clear;
    FProxyRegister.Clear;
    for Listener in Listeners do
    begin
      FSubscriptionRegister.Add(Listener.token, TSubscriptionData.Create(Listener.IP, '', Listener.Port, Listener.Path));
      FProxyRegister.Add(Listener.token, TRestAdapter<IListenerProxy>.Create().Build(Listener.IP, Listener.Port));
    end;
    CheckRep();
  finally
    TMonitor.Exit(FListenersLock);
  end;
end;

end.
