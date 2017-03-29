unit Model;

interface

uses
  ActiveQueueResponce, SubscriptionData, System.Generics.Collections, ReceptionRequest;

type
  /// <summary>
  /// A model corresponding to the ActiveQueue controller.
  /// </summary>
  TActiveQueueModel = class
  strict private
  var
    /// a dumb lock object for managing the access to the  subscription register
    FSubscriptionLock: TObject;
    /// a dumb lock object for managing the access to the queue items
    FQueueLock: TObject;
    FSubscriptionRegister: TDictionary<String, TSubscriptionData>;
    /// items of the queue
    FQueue: TQueue<TReceptionRequest>;
    function GetNumOfSubscriptions: Integer;
  public
    /// <summary>Create a subscription </summary>
    /// <param name="Ip">ip of the computer from which the subscription request comes from</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Ip: String; const Data: TSubscriptionData): TActiveQueueResponce;
    /// <summary> Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    function CancelSubscription(const Ip: String): TActiveQueueResponce;
    /// get not more that N items from the queue.
    function getData(const Ip: String; const N: Integer): TObjectList<TReceptionRequest>;

    /// <summary>Add many items to the pull</summary>
    /// <param name="Items">list of elements to be added to the queue</param>
    /// <returns>True in case of success, False otherwise</returns>
    function addAll(const Items: TObjectList<TReceptionRequest>): Boolean;

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

function TActiveQueueModel.AddSubscription(const Ip: String;
  const data: TSubscriptionData): TActiveQueueResponce;
begin
  TMonitor.Enter(FSubscriptionLock);
  try
    if FSubscriptionRegister.ContainsKey(Ip) then
    begin
      Result := TActiveQueueResponce.Create(False, 'your ip ' + Ip + ' is already subscribed, port ' + inttostr(FSubscriptionRegister[Ip].Port));
    end
    else
    begin
      // create a copy of the object
      FSubscriptionRegister.Add(Ip, TSubscriptionData.Create(data.Url, data.Port, data.Path));
      Result := TActiveQueueResponce.Create(True, 'your ip is ' + Ip + ', your port is ' + inttostr(data.Port));
    end;
  finally
    TMonitor.Exit(FSubscriptionLock);
  end;

end;

function TActiveQueueModel.CancelSubscription(
  const Ip: String): TActiveQueueResponce;
begin
  TMonitor.Enter(FSubscriptionLock);
  try
    if (FSubscriptionRegister.ContainsKey(Ip)) then
    begin
      FSubscriptionRegister[Ip].DisposeOf;
      FSubscriptionRegister.Remove(Ip);
      Result := TActiveQueueResponce.Create(True, 'request to cancel your subscription (' + Ip + ') is executed.');
    end
    else
    begin
      Result := TActiveQueueResponce.Create(False, 'no subscription for ip ' + Ip + ' is found.');
    end;
  finally
    TMonitor.Exit(FSubscriptionLock);
  end;
end;

constructor TActiveQueueModel.Create;
begin
  FSubscriptionLock := TObject.Create;
  FQueueLock := TObject.Create;
  FSubscriptionRegister := TDictionary<String, TSubscriptionData>.Create;
  FQueue := TQueue<TReceptionRequest>.Create;
end;

destructor TActiveQueueModel.Destroy;
var
  ItemKey: String;
  I: Integer;
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
  // remove objects from the queue and clean the queue afterwards
  for I := 0 to FQueue.Count - 1 do
    FQueue.Dequeue.Disposeof;
  FQueue.Clear;
  FQueue.DisposeOf;

end;

function TActiveQueueModel.getData(const Ip: String;
  const N: Integer): TObjectList<TReceptionRequest>;
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

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FSubscriptionLock);
  Result := FSubscriptionRegister.Count;
  TMonitor.Exit(FSubscriptionLock);
end;

end.
