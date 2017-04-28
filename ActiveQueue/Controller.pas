unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Model, ReceptionRequest, ObjectsMappers,
  System.Generics.Collections, ListenerInfo;

type

  [MVCPath('/')]
  TController = class(TMVCController)

  strict private
    class var Model: TActiveQueueModel;

  public

    class function GetListeners(): TObjectList<TListenerInfo>;

    class procedure SetSubscriptions(const Listeners: TObjectList<TListenerInfo>);

    /// <summary> Get the white list of listeners' ips: requests coming from only these ips
    /// are to be taken in consideration </summary>
    class function GetListenersIPs(): TArray<String>;

    /// <summary> Set the white list of listeners' ips: requests coming from only these ips
    /// are to be taken in consideration </summary>
    class procedure SetListenersIPs(const IPs: TArray<String>);

    /// <summary> Get the white list of providers' ips: requests to enqueue the data coming from only these ips
    /// are to be taken in consideration </summary>
    class function GetProvidersIPs(): TArray<String>;

    /// <summary> Set the white list of providers' ips: requests to enqueue the data coming from only these ips
    /// are to be taken in consideration </summary>
    class procedure SetProvidersIPs(const IPs: TArray<String>);

    /// <summary> Initialize the model. Since this controller is added in a static manner,
    /// I have to create a static method that instantiate a static reference
    /// corresponding to the model
    /// </summary>
    class procedure Setup();
    /// <summary> Release the reference to the model instantiated during the initialization
    /// </summary>
    class procedure Teardown();

    /// request a subscription to the ActiveQueue events
    /// The body of the request must contain a TSubscriptionData instance.
    /// As a reponce, a TActiveQueueResponce instance is returned.
    /// In case of success, the reponce contains a unique token that will
    /// be assigned to this subscription
    [MVCPath('/subscribe')]
    [MVCHTTPMethod([httpPUT])]
    procedure Subscribe(const Context: TWebContext);

    /// request a cancellation of the subscription to the ActiveQueue events
    [MVCPath('/unsubscribe/($token)')]
    [MVCHTTPMethod([httpPUT])]
    procedure unsubscribe(const Context: TWebContext);

    /// request given number of items from the ActiveQueue.
    [MVCPath('/items/get/($n)')]
    [MVCHTTPMethod([httpGET])]
    [MVCProduces('application/json')]
    procedure GetItems(const Context: TWebContext);

    /// add items to the ActiveQueue.
    [MVCPath('/items/post')]
    [MVCHTTPMethod([httpPOST])]
    procedure PutItems(const Context: TWebContext);

    /// cancel items from the ActiveQueue.
    [MVCPath('/cancel/post')]
    [MVCHTTPMethod([httpPUT])]
    procedure CancelItems(const Context: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, ActiveQueueResponce, System.JSON, SubscriptionData,
  System.SysUtils, ConditionInterface, TokenBasedCondition;

class function TController.GetListenersIPs: TArray<String>;
begin
  if Assigned(Model) then
  begin
    Result := Model.GetListenersIPs()
  end
  else
  begin
    Result := TArray<String>.Create();
    SetLength(Result, 0);
  end;
end;

class function TController.GetProvidersIPs: TArray<String>;
begin
  if Assigned(Model) then
  begin
    Result := Model.GetProvidersIPs()
  end
  else
  begin
    Result := TArray<String>.Create();
    SetLength(Result, 0);
  end;
end;

procedure TController.CancelItems(const Context: TWebContext);
var
  Ip: String;
  jo: TJsonObject;
  Condition: ICondition;
begin
  Ip := Context.Request.ClientIP;
  jo := Context.Request.BodyAsJSONObject;
  if (Assigned(jo)) then
  begin
    try
      Condition := Mapper.JSONObjectToObject<TTokenBasedCondition>(jo);
      Model.CancelBy(Condition);
    except
      on e: Exception do
        Condition := nil;
    end;
  end;

end;

procedure TController.GetItems(const Context: TWebContext);
var
  Ip: String;
  Items: TObjectList<TReceptionRequest>;
  N: Integer;
begin
  N := Context.Request.Params['n'].ToInteger;
  ip := Context.Request.ClientIP;
  Items := Model.getData(Ip, N);
  Render<TReceptionRequest>(Items);
end;

class function TController.GetListeners: TObjectList<TListenerInfo>;
begin
  if Assigned(Model) then
    Result := Model.GetListeners()
  else
    Result := TObjectList<TListenerInfo>.Create();

end;

procedure TController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

procedure TController.PutItems(const Context: TWebContext);
var
  items: TObjectList<TReceptionRequest>;
  Outcome: Boolean;
begin
  if Context.Request.ThereIsRequestBody then
  begin
    try
      items := Context.Request.BodyAsListOf<TReceptionRequest>;
      Outcome := Model.addAll(Items);
    except
      on E: Exception do
        Outcome := False;
    end;
  end
  else
    Outcome := False;
  Render(Outcome.ToString(False));
end;

class procedure TController.SetListenersIPs(const IPs: TArray<String>);
begin
  if Assigned(Model) then
  begin
    Model.SetListenersIPs(IPs);
  end
end;

class procedure TController.SetProvidersIPs(const IPs: TArray<String>);
begin
  if Assigned(Model) then
  begin
    Model.SetProvidersIPs(IPs);
  end
end;

class procedure TController.SetSubscriptions(
  const Listeners: TObjectList<TListenerInfo>);
begin
  if Assigned(Model) then
    Model.SetListeners(Listeners);
end;

class
  procedure TController.Setup;
begin
  Model := TActiveQueueModel.Create;
end;

procedure TController.Subscribe(const Context: TWebContext);
var
  responce: TActiveQueueResponce;
  SubscriptionData: TSubscriptionData;
  Ip: String;
  jo: TJsonObject;
begin
  ip := Context.Request.ClientIP;
  jo := Context.Request.BodyAsJSONObject;
  if (Assigned(jo)) then
  begin
    try
      SubscriptionData := Mapper.JSONObjectToObject<TSubscriptionData>(jo);
      SubscriptionData.Ip := Ip;
    except
      on e: Exception do
        SubscriptionData := nil;
    end;
  end;
  responce := Model.AddSubscription(SubscriptionData);
  Render(responce);
end;

class
  procedure TController.Teardown;
begin
  Model.DisposeOf;
end;

procedure TController.unsubscribe(const Context: TWebContext);
var
  responce: TActiveQueueResponce;
  Ip, Token: String;
begin
  Token := Context.Request.Params['token'];
  Ip := Context.Request.ClientIP;
  responce := Model.CancelSubscription(ip, token);
  Render(responce);
end;

initialization

TController.Setup;

finalization

TController.Teardown;

end.
