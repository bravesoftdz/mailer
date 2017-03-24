unit ActiveQueueModel;

interface

uses
  ActiveQueueResponce, SubscriptionData, System.Generics.Collections;

type
  /// <summary>
  /// A model corresponding to the ActiveQueue controller.
  /// </summary>
  TActiveQueueModel = class
  strict private
  var
    /// a dumb lock object
    FLock: TObject;
    SubscriptionMap: TDictionary<String, TSubscriptionData>;
    function GetNumOfSubscriptions: Integer;
  public
    /// <summary>Create a subscription </summary>
    /// <param name="Ip">ip of the computer from which the subscription request comes from</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Ip: String; const Data: TSubscriptionData): TActiveQueueResponce;
    /// <summary> Cancel the subscription corresponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    function CancelSubscription(const Ip: String): TActiveQueueResponce;
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
  TMonitor.Enter(FLock);
  try
    if SubscriptionMap.ContainsKey(Ip) then
    begin
      Result := TActiveQueueResponce.Create(False, 'your ip ' + Ip + ' is already subscribed, port ' + inttostr(SubscriptionMap[Ip].Port));
    end
    else
    begin
      // create a copy of the object
      SubscriptionMap.Add(Ip, TSubscriptionData.Create(data.Url, data.Port, data.Path));
      Result := TActiveQueueResponce.Create(True, 'your ip is ' + Ip + ', your port is ' + inttostr(data.Port));
    end;
  finally
    TMonitor.Exit(FLock);
  end;

end;

function TActiveQueueModel.CancelSubscription(
  const Ip: String): TActiveQueueResponce;
begin
  TMonitor.Enter(FLock);
  try
    if (SubscriptionMap.ContainsKey(Ip)) then
    begin
      SubscriptionMap[Ip].DisposeOf;
      SubscriptionMap.Remove(Ip);
      Result := TActiveQueueResponce.Create(True, 'request to cancel your subscription (' + Ip + ') is executed.');
    end
    else
    begin
      Result := TActiveQueueResponce.Create(False, 'no subscription for ip ' + Ip + ' is found.');
    end;
  finally
    TMonitor.Exit(FLock);
  end;
end;

constructor TActiveQueueModel.Create;
begin
  FLock := TObject.Create;
  SubscriptionMap := TDictionary<String, TSubscriptionData>.Create;
end;

destructor TActiveQueueModel.Destroy;
var
  ItemKey: String;
begin
  FLock.DisposeOf;
  for ItemKey in SubscriptionMap.Keys do
  begin
    SubscriptionMap[ItemKey].DisposeOf;
  end;
  SubscriptionMap.Clear;
  SubscriptionMap.DisposeOf;
end;

function TActiveQueueModel.GetNumOfSubscriptions: Integer;
begin
  TMonitor.Enter(FLock);
  Result := SubscriptionMap.Count;
  TMonitor.Exit(FLock);
end;

end.
