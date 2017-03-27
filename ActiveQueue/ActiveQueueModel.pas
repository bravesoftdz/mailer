unit ActiveQueueModel;

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
    FQueue: TObjectList<TReceptionRequest>;
    function GetNumOfSubscriptions: Integer;
  public
    /// <summary>Create a subscription </summary>
    /// <param name="Ip">ip of the computer from which the subscription request comes from</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Ip: String; const Data: TSubscriptionData): TActiveQueueResponce;
    /// <summary> Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    function CancelSubscription(const Ip: String): TActiveQueueResponce;
    /// get N items from the queue
    function getData(const Ip: String; const N: Integer): TObjectList<TReceptionRequest>;

    /// <summary> the number of subscriptions </summary>
    property numOfSubscriptions: Integer read GetNumOfSubscriptions;

    constructor Create();
    destructor Destroy();
  end;

implementation

uses
  System.SysUtils;
{ TActiveQueueModel }

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
  FSubscriptionRegister := TDictionary<String, TSubscriptionData>.Create;
end;

destructor TActiveQueueModel.Destroy;
var
  ItemKey: String;
begin
  FSubscriptionLock.DisposeOf;
  for ItemKey in FSubscriptionRegister.Keys do
  begin
    FSubscriptionRegister[ItemKey].DisposeOf;
  end;
  FSubscriptionRegister.Clear;
  FSubscriptionRegister.DisposeOf;
end;

function TActiveQueueModel.getData(const Ip: String;
  const N: Integer): TObjectList<TReceptionRequest>;
begin

end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FSubscriptionLock);
  Result := FSubscriptionRegister.Count;
  TMonitor.Exit(FSubscriptionLock);
end;

end.
