unit ActiveQueueModel;

interface

uses
  ActiveQueueResponce, SubscriptionData;

type
  /// <summary>
  /// A model corresponding to the ActiveQueue controller.
  /// </summary>
  TActiveQueueModel = class
  public
    /// <summary>Create a subscription </summary>
    /// <param name="Ip">ip of the computer from which the subscription request comes from</param>
    /// <param name="Data">subscription infomation (port, path etc)</param>
    function AddSubscription(const Ip: String; const Data: TSubscriptionData): TActiveQueueResponce;
    /// <summary> Cancel the subscription corrsponding to given ip</summary>
    /// <param name="Ip">Ip of the computer which subscription is to be cancelled</param>
    function CancelSubscription(const Ip: String): TActiveQueueResponce;
  end;

implementation

uses
  System.SysUtils;
{ TActiveQueueModel }

function TActiveQueueModel.AddSubscription(const Ip: String;
  const data: TSubscriptionData): TActiveQueueResponce;
begin
  /// stub
  Result := TActiveQueueResponce.Create(True, 'your ip is ' + Ip + ', your port is ' + inttostr(data.Port));
end;

function TActiveQueueModel.CancelSubscription(
  const Ip: String): TActiveQueueResponce;
begin
  Result := TActiveQueueResponce.Create(true, 'request to cancel your subscription (' + Ip + ') is accepted.');

end;

end.
