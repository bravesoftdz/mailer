unit ActiveQueueController;

interface

uses
  MVCFramework, MVCFramework.Commons, ActiveQueueModel;

type

  [MVCPath('/')]
  TActiveQueueController = class(TMVCController)

  strict private
    class var Model: TActiveQueueModel;

  public
    /// <summary> Initialize the model. Since this controller is added in a static manner,
    /// I have to create a static method that instantiate a static reference
    /// corresponding to the model
    /// </summary>
    class procedure Setup();
    /// <summary> Release the reference to the model instantiated during the initialization
    /// </summary>
    class procedure Teardown();

    /// request a subscription to the ActiveQueue events
    [MVCPath('/subscribe')]
    [MVCHTTPMethod([httpPUT])]
    procedure Subscribe(const Context: TWebContext);

    /// request a cancellation of the subscription to the ActiveQueue events
    [MVCPath('/unsubscribe')]
    [MVCHTTPMethod([httpPUT])]
    procedure unsubscribe(const Context: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, ActiveQueueResponce, System.JSON, ObjectsMappers, SubscriptionData,
  System.SysUtils;

procedure TActiveQueueController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TActiveQueueController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

class procedure TActiveQueueController.Setup;
begin
  Model := TActiveQueueModel.Create;
end;

procedure TActiveQueueController.Subscribe(const Context: TWebContext);
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
    except
      on e: Exception do
        SubscriptionData := nil;
    end;
  end;
  responce := Model.AddSubscription(ip, SubscriptionData);
  Render(responce);
end;

class procedure TActiveQueueController.Teardown;
begin
  Model.DisposeOf;
end;

procedure TActiveQueueController.unsubscribe(const Context: TWebContext);
var
  responce: TActiveQueueResponce;
  Ip: String;
begin
  ip := Context.Request.ClientIP;
  responce := Model.CancelSubscription(ip);
  Render(responce);
end;

initialization

TActiveQueueController.Setup;

finalization

TActiveQueueController.Teardown;

end.
