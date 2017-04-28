unit Model;

interface

uses
  ActiveQueueResponce, SubscriptionData, ReceptionRequest,
  System.Classes, ListenerInfo, System.Generics.Collections, ListenerProxyInterface,
  ConditionInterface;

type
  /// <summary> A model corresponding to the ActiveQueue controller. </summary>
  TActiveQueueModel = class
    /// Representation invariant:
    /// All conditions must hold:
    /// 1. lock objects are non null: FSubscriptionsLock, FProvidersLock, FQueueLock, FProvidersLock
    /// 2. FSubscriptionRegister and  FProxyRegister must have the same set of keys
    /// 3. FIPs length is defined and is not less than zero
    ///
  strict private
  var
    /// a dumb lock object for managing the access to the  subscription register
    FSubscriptionsLock: TObject;

    /// a dumb lock object for managing the access to the  providers' ips
    FProvidersLock: TObject;

    /// a dumb lock object for managing the access to the queue items
    FQueueLock: TObject;

    /// <summary>A dictionary for subscriptions: the keys are unique ids assigned
    /// to the subscriptions, the values are objects containing subscription information</summary>
    FSubscriptionRegister: TDictionary<String, TSubscriptionData>;

    /// <summary>A map of proxies corresponding to currently subscribed listeners.
    /// Each pair is composed of a key that is a token issued during the subscription
    /// and a value that is a proxy server of the listener associated with the token.</summary>
    FProxyRegister: TDictionary<String, IListenerProxy>;

    /// items of the queue
    FQueue: TQueue<TReceptionRequest>;

    /// <summary>Set the IPs from which the subscriptions can be accepted.</summary>
    FListenersIPs: TArray<String>;

    /// <summary>Set the IPs from which the data to enqueue can be accepted.</summary>
    FProvidersIPs: TArray<String>;

    function GetNumOfSubscriptions: Integer;

    /// <summary>Return true if given subscription data is already present in the register.</summary>
    function IsSubscribed(const Data: TSubscriptionData): Boolean;

    /// <summary>Check the consistency of the reresenation</summary>
    procedure checkRep();

    /// <summary>Notify all subscribed listeners that the queue state has changed</summary>
    procedure NotifyListeners();

  public
    /// <summary>Create a subscription </summary>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Data: TSubscriptionData): TActiveQueueResponce;

    /// <summary>Get all subscribed listeners</summary>
    function GetListeners(): TObjectList<TListenerInfo>;

    /// <summary>Set the listeners</summary>
    procedure SetListeners(const Listeners: TObjectList<TListenerInfo>);

    /// <summary>Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    /// <param name="Token">token associated with the subscription</param>
    function CancelSubscription(const Ip, Token: String): TActiveQueueResponce;

    /// get not more that N items from the queue.
    function getData(const Ip: String; const N: Integer): TObjectList<TReceptionRequest>;

    /// <summary>Add many items to the pull</summary>
    /// <param name="Items">list of elements to be added to the queue</param>
    /// <returns>True in case of success, False otherwise</returns>
    function addAll(const Items: TObjectList<TReceptionRequest>): Boolean;

    /// <summary> Get the IPs from which the subscriptions can be accepted.</summary>
    function GetListenersIPs: TArray<String>;

    /// <summary> Set the IPs from which the subscriptions can be accepted.</summary>
    procedure SetListenersIPs(const IPs: TArray<String>);

    /// <summary> Get the IPs from which the requests to enqueue the data can be accepted.</summary>
    function GetProvidersIPs: TArray<String>;

    /// <summary> Set the IPs from which the requests to enqueue the data can be accepted.</summary>
    procedure SetProvidersIPs(const IPs: TArray<String>);

    /// <summary>Return true iff given IP is among those from which a subscription can be accepted.</summary>
    function IsSubscribable(const IP: String): Boolean;

    /// <summary>Cancel the items of the queue for which the condition is true.</summary>
    function CancelBy(const Condition: ICondition): Integer;

    /// <summary> the number of subscriptions </summary>
    property numOfSubscriptions: Integer read GetNumOfSubscriptions;

    constructor Create();
    destructor Destroy();
  end;

implementation

uses
  System.SysUtils, MVCFramework.RESTAdapter;
{ TActiveQueueModel }

function TActiveQueueModel.addAll(const Items: TObjectList<TReceptionRequest>): Boolean;
var
  item: TReceptionRequest;
begin
  TMonitor.Enter(FQueueLock);
  try
    try
      for item in Items do
      begin
        FQueue.Enqueue(item);
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
  TMonitor.Enter(FSubscriptionsLock);
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
            Token := Guid.ToString;
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
    TMonitor.Exit(FSubscriptionsLock);
  end;

end;

function TActiveQueueModel.CancelBy(const Condition: ICondition): Integer;
begin
raise Exception.Create('Not implemented yet');
end;

function TActiveQueueModel.CancelSubscription(const Ip, Token: String): TActiveQueueResponce;
var
  subscription: TSubscriptionData;
begin
  TMonitor.Enter(FSubscriptionsLock);
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
    TMonitor.Exit(FSubscriptionsLock);
  end;
end;

procedure TActiveQueueModel.checkRep;
var
  IsOk: Boolean;
  Token: String; { TODO -oAndrew : skip it in the production }
begin
  TMonitor.Enter(FQueueLock);
  try
    IsOk := (FSubscriptionsLock <> nil) AND (FProvidersLock <> nil)
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

constructor TActiveQueueModel.Create;
begin
  FSubscriptionsLock := TObject.Create;
  FQueueLock := TObject.Create;
  FProvidersLock := TObject.Create;
  FSubscriptionRegister := TDictionary<String, TSubscriptionData>.Create;
  FProxyRegister := TDictionary<String, IListenerProxy>.Create();
  FQueue := TQueue<TReceptionRequest>.Create;
  SetLength(FListenersIPs, 0);
  SetLength(FProvidersIPs, 0);
  CheckRep();
end;

destructor TActiveQueueModel.Destroy;
var
  ItemKey: String;
  I, S: Integer;
begin
  FSubscriptionsLock.DisposeOf;
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
  S := FQueue.Count;
  for I := 0 to S - 1 do
    FQueue.Dequeue.Disposeof;
  FQueue.Clear;
  FQueue.DisposeOf;
  SetLength(FListenersIPs, 0);

end;

function TActiveQueueModel.getData(const Ip: String; const N: Integer): TObjectList<TReceptionRequest>;
var
  Size, ReturnSize, I: Integer;
  IsSubScribed: Boolean;
begin
  Result := TObjectList<TReceptionRequest>.Create(True);
  TMonitor.Enter(FSubscriptionsLock);
  try
    if (N >= 0) AND FSubscriptionRegister.ContainsKey(Ip) then
    begin
      TMonitor.Enter(FQueueLock);
      Size := FQueue.Count;
      if Size < N then
        ReturnSize := Size
      else
        ReturnSize := N;
      for I := 0 to ReturnSize - 1 do
      begin
        Result.Add(FQueue.Dequeue);
      end;
      TMonitor.Exit(FQueueLock);
    end;
  finally
    TMonitor.Exit(FSubscriptionsLock);
  end;

end;

function TActiveQueueModel.GetListenersIPs: TArray<String>;
var
  I, S: Integer;
begin
  TMonitor.Enter(FSubscriptionsLock);
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
    TMonitor.Exit(FSubscriptionsLock);
  end;
end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FSubscriptionsLock);
  Result := FSubscriptionRegister.Count;
  TMonitor.Exit(FSubscriptionsLock);
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
begin
  TMonitor.Enter(FSubscriptionsLock);
  try
    Result := TObjectList<TListenerInfo>.Create();
    for Token in FSubscriptionRegister.Keys do
    begin
      Subscription := FSubscriptionRegister[Token];
      Result.Add(TListenerInfoBuilder.Create()
        .SetToken(Token)
        .SetIp(Subscription.Ip)
        .SetPort(Subscription.Port)
        .SetPath(Subscription.Path)
        .Build()
        );
    end;
  finally
    TMonitor.Exit(FSubscriptionsLock);
  end;

end;

function TActiveQueueModel.IsSubscribable(const IP: String): Boolean;
var
  I, S: Integer;
begin
  TMonitor.Enter(FSubscriptionsLock);
  Result := False;
  S := Length(FListenersIPs);
  for I := 0 to S - 1 do
  begin
    if (FListenersIPs[I].Equals(IP)) then
    begin
      Result := True;
      break;
    end;
  end;
  TMonitor.Exit(FSubscriptionsLock);
end;

function TActiveQueueModel.IsSubscribed(const Data: TSubscriptionData): Boolean;
var
  key: String;
  value: TSubscriptionData;
begin
  Result := FSubscriptionRegister.ContainsValue(Data);
end;

procedure TActiveQueueModel.NotifyListeners;
var
  Token: String;
begin
  TMonitor.Enter(FSubscriptionsLock);
  try
    for Token in FProxyRegister.Keys do
      FProxyRegister[Token].Notify();
  finally
    TMonitor.Exit(FSubscriptionsLock);
  end;
end;

procedure TActiveQueueModel.SetListenersIPs(const IPs: TArray<String>);
var
  I, S: Integer;
begin
  TMonitor.Enter(FSubscriptionsLock);
  try
    S := Length(IPs);
    SetLength(FListenersIPs, S);
    for I := 0 to S - 1 do
      FListenersIPs[I] := IPs[I];
    CheckRep();
  finally
    TMonitor.Exit(FSubscriptionsLock);
  end;
end;

procedure TActiveQueueModel.SetProvidersIPs(const IPs: TArray<String>);
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

procedure TActiveQueueModel.SetListeners(
  const
  Listeners:
  TObjectList<TListenerInfo>);
var
  Listener: TListenerInfo;
begin
  TMonitor.Enter(FSubscriptionsLock);
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
    TMonitor.Exit(FSubscriptionsLock);
  end;
end;

end.
