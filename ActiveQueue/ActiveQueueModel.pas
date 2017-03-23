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
  public
    /// <summary>Create a subscription </summary>
    /// <param name="Ip">ip of the computer from which the subscription request comes from</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Ip: String; const Data: TSubscriptionData): TActiveQueueResponce;
    /// <summary> Cancel the subscription corrsponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    function CancelSubscription(const Ip: String): TActiveQueueResponce;

    constructor Create();
    destructor Destroy();
  end;

implementation

uses
  System.SysUtils;
{ TActiveQueueModel }

function TActiveQueueModel.AddSubscription(const Ip: String;
  const data: TSubscriptionData): TActiveQueueResponce;
var
  dataCopy: TSubscriptionData;
begin
  TMonitor.Enter(FLock);
  try
    if SubscriptionMap.ContainsKey(Ip) then
    begin
      Result := TActiveQueueResponce.Create(False, 'your ip ' + Ip + ' is already subscribed, port ' + inttostr(SubscriptionMap[Ip].Port));
    end
    else
    begin
      dataCopy := TSubscriptionData.Create(data.Url, data.Port, data.Path);
      SubscriptionMap.Add(Ip, dataCopy);
      Result := TActiveQueueResponce.Create(True, 'your ip is ' + Ip + ', your port is ' + inttostr(data.Port));
    end;
  finally
    TMonitor.Exit(FLock);
  end;

end;

function TActiveQueueModel.CancelSubscription(
  const Ip: String): TActiveQueueResponce;
begin
  Result := TActiveQueueResponce.Create(true, 'request to cancel your subscription (' + Ip + ') is accepted.');

end;

constructor TActiveQueueModel.Create;
begin
  FLock := TObject.Create;
  SubscriptionMap := TDictionary<String, TSubscriptionData>.Create;
end;

destructor TActiveQueueModel.Destroy;
begin
  FLock.DisposeOf;
  SubscriptionMap.Clear;
  SubscriptionMap.DisposeOf;
end;

end.
