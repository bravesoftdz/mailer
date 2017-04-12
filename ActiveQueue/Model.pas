unit Model;

interface

uses
  ActiveQueueResponce, SubscriptionData, ReceptionRequest,
  System.Classes, ListenerInfo, System.Generics.Collections, ListenerProxyInterface;

type
  /// <summary> A model corresponding to the ActiveQueue controller. </summary>
  TActiveQueueModel = class
    /// Representation invariant:
    /// All conditions must hold:
    /// 1. lock objects are non null: FSubscriptionLock, FQueueLock
    /// 2. FSubscriptionRegister and  FProxyRegister must have the same set of keys
    /// 3. FIPs is non null
  strict private
  var
    /// a dumb lock object for managing the access to the  subscription register
    FSubscriptionLock: TObject;
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
    FIPs: TArray<String>;
    function GetNumOfSubscriptions: Integer;
    /// <summary>Return true if given subscription data is already present in the register.</summary>
    function IsSubscribed(const Data: TSubscriptionData): Boolean;

    /// <summary>Check the consistency of the reresenation</summary>
    procedure checkRep();

  public
    /// <summary>Create a subscription </summary>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Data: TSubscriptionData): TActiveQueueResponce;

    /// <summary>Get all subscribed listeners</summary>
    function GetListeners(): TObjectList<TListenerInfo>;

    /// <summary>Set the listeners</summary>
    procedure SetListeners(const Listeners: TObjectList<TListenerInfo>);

    /// <summary> Cancel the subscription corresponding to given ip</summary>
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
    function GetIPs: TArray<String>;
    /// <summary> Set the IPs from which the subscriptions can be accepted.</summary>
    procedure SetIPs(const IPs: TArray<String>);

    /// <summary>Return true iff given IP is among those from which a subscription can be accepted.</summary>
    function IsSubscribable(const IP: String): Boolean;

    /// <summary> the number of subscriptions </summary>
    property numOfSubscriptions: Integer read GetNumOfSubscriptions;

    constructor Create();
    destructor Destroy();
  end;

implementation

uses
  System.SysUtils;
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
end;

function TActiveQueueModel.AddSubscription(const data: TSubscriptionData): TActiveQueueResponce;
var
  Id: String;
  Ip: String;
  Guid: TGUID;
begin
  TMonitor.Enter(FSubscriptionLock);
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
            id := Guid.ToString;
          until Not(FSubscriptionRegister.ContainsKey(id));
          // create a copy of the object
          FSubscriptionRegister.Add(id, TSubscriptionData.Create(data.Ip, data.Url, data.Port, data.Path));
          Result := TActiveQueueResponce.Create(True, Ip + ':' + inttostr(data.Port), id);
        end;
      end;
    end;
  finally
    TMonitor.Exit(FSubscriptionLock);
  end;

end;

function TActiveQueueModel.CancelSubscription(const Ip, Token: String): TActiveQueueResponce;
var
  subscription: TSubscriptionData;
begin
  TMonitor.Enter(FSubscriptionLock);
  try
    if (FSubscriptionRegister.ContainsKey(Token)) then
    begin
      subscription := FSubscriptionRegister[Token];
      if (subscription.Ip = Ip) then
      begin
        subscription.DisposeOf;
        FSubscriptionRegister.Remove(Token);
        Result := TActiveQueueResponce.Create(True, 'unsubscribed', '');
      end
      else
        Result := TActiveQueueResponce.Create(False, 'wrong ip or token', '');
    end
    else
    begin
      Result := TActiveQueueResponce.Create(False, 'not subscribed', '');
    end;
  finally
    TMonitor.Exit(FSubscriptionLock);
  end;
end;

procedure TActiveQueueModel.checkRep;
var
  IsOk: Boolean;
  Token: String;
begin
  TMonitor.Enter(FQueueLock);
  try
    IsOk := (FSubscriptionLock = nil)
      OR (FIPs = nil)
      OR (FSubscriptionRegister = nil)
      OR (FProxyRegister = nil)
      OR (FProxyRegister.Count <> FSubscriptionRegister.Count);

    if IsOk then
    begin
      for Token in FProxyRegister.Keys do
        if Not(FSubscriptionRegister.ContainsKey(Token)) then
        begin
          IsOk := False;
          Break;
        end;
    end;
    if Not(IsOk) then
      raise Exception.Create('Inconsistent rep of TActiveQueueModel');
  finally
    TMonitor.Exit(FQueueLock);
  end;

end;

constructor TActiveQueueModel.Create;
begin
  FSubscriptionLock := TObject.Create;
  FQueueLock := TObject.Create;
  FSubscriptionRegister := TDictionary<String, TSubscriptionData>.Create;
  FProxyRegister := TDictionary<String, IListenerProxy>.Create();
  FQueue := TQueue<TReceptionRequest>.Create;
  FIPs := TArray<String>.Create();
  SetLength(FIPs, 0);
end;

destructor TActiveQueueModel.Destroy;
var
  ItemKey: String;
  I, S: Integer;
begin
  FSubscriptionLock.DisposeOf;
  FQueueLock.DisposeOf;
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

end;

function TActiveQueueModel.getData(
  const
  Ip:
  String;
  const
  N:
  Integer): TObjectList<TReceptionRequest>;
var
  Size, ReturnSize, I: Integer;
  IsSubScribed: Boolean;
begin
  Result := TObjectList<TReceptionRequest>.Create(True);
  TMonitor.Enter(FSubscriptionLock);
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
    TMonitor.Exit(FSubscriptionLock);
  end;

end;

function TActiveQueueModel.GetIPs: TArray<String>;
var
  I, S: Integer;
begin
  If Assigned(FIPs) then
    S := Length(FIPs)
  else
    S := 0;
  Result := TArray<String>.Create();
  SetLength(Result, S);
  for I := 0 to S - 1 do
    Result[I] := FIPs[I];
end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FSubscriptionLock);
  Result := FSubscriptionRegister.Count;
  TMonitor.Exit(FSubscriptionLock);
end;

function TActiveQueueModel.GetListeners: TObjectList<TListenerInfo>;
var
  Subscription: TSubscriptionData;
  Token: String;
begin
  TMonitor.Enter(FSubscriptionLock);
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
    TMonitor.Exit(FSubscriptionLock);
  end;

end;

function TActiveQueueModel.IsSubscribable(
  const
  IP:
  String): Boolean;
var
  I, S: Integer;
begin
  TMonitor.Enter(FSubscriptionLock);
  Result := False;
  S := Length(FIPs);
  for I := 0 to S - 1 do
  begin
    if (FIPs[I].Equals(IP)) then
    begin
      Result := True;
      break;
    end;
  end;
  TMonitor.Exit(FSubscriptionLock);
end;

function TActiveQueueModel.IsSubscribed(const Data: TSubscriptionData): Boolean;
var
  key: String;
  value: TSubscriptionData;
begin
  Result := FSubscriptionRegister.ContainsValue(Data);
end;

procedure TActiveQueueModel.SetIPs(
  const
  IPs:
  TArray<String>);
var
  I, S: Integer;
begin
  FIPs := TArray<String>.Create();
  S := Length(IPs);
  SetLength(FIPs, S);
  for I := 0 to S - 1 do
    FIPs[I] := IPs[I];
end;

procedure TActiveQueueModel.SetListeners(
  const Listeners: TObjectList<TListenerInfo>);
var
  Listener: TListenerInfo;
begin
  TMonitor.Enter(FSubscriptionLock);
  try
    FSubscriptionRegister.Clear;
    for Listener in Listeners do
    begin
      FSubscriptionRegister.Add(Listener.token, TSubscriptionData.Create(Listener.IP, '', Listener.Port, Listener.Path));
    end;
  finally
    TMonitor.Exit(FSubscriptionLock);
  end;
end;

end.
