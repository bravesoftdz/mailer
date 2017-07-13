unit ConsumerController;

interface

uses
  MVCFramework, MVCFramework.Commons, ConsumerModel, ConsumerConfig;

type

  [MVCPath('/')]
  TConsumerController = class(TMVCController)
  strict private
    class var
      Model: TConsumerModel;

  public
    /// <summary> Initialize the model. Since this controller is added in a static manner,
    /// I have to create a static method that instantiate a static reference  corresponding to the model
    /// </summary>
    class procedure Setup();

    /// <summary> Release the reference to the model instantiated during the initialization
    /// </summary>
    class procedure Teardown();

    /// <summary>Set up the configuration of the server</summary>
    /// <param name="Config">configuration class instance</param>
    /// <param name="TargetConfigFileName">defines a name of the file into which a configuration
    /// should be saved in case it gets updates (due to a possible subscription status change)</param>
    class procedure SetConfig(const Config: TConsumerConfig; const TargetConfigFileName: String);

    class function GetPort(): Integer;
    class function getSubscriptionStatus(): Boolean;
    class function GetSubscriptionToken(): String;
    class function GetBlockSize(): Integer;

    [MVCPath('/notify')]
    [MVCHTTPMethod([httpPOST])]
    procedure Notify(const Ctx: TWebContext);

    [MVCPath('/subscribe')]
    [MVCHTTPMethod([httpPOST])]
    procedure Subscribe(const Ctx: TWebContext);

    [MVCPath('/unsubscribe/($token)')]
    [MVCHTTPMethod([httpPOST])]
    procedure Unsubscribe(const Ctx: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, MVCFramework.RESTAdapter, AQAPIConsumer,
  SubscriptionData, IdSMTP, IdMessage, SendmailConfig, ActiveQueueResponce,
  System.SysUtils;

class procedure TConsumerController.SetConfig(const Config: TConsumerConfig;
  const TargetConfigFileName: String);
begin
  Model.SetConfig(Config, TargetConfigFileName);
end;

class procedure TConsumerController.Setup;
begin
  Model := TConsumerModel.Create();
end;

class procedure TConsumerController.Teardown;
begin
  Model.DisposeOf;
end;

class function TConsumerController.GetBlockSize: Integer;
begin
  Result := Model.BlockSize;
end;

class function TConsumerController.GetPort: Integer;
begin
  Result := Model.Port;
end;

class function TConsumerController.getSubscriptionStatus: Boolean;
begin
  Result := Model.SubscriptionStatus;
end;

class function TConsumerController.GetSubscriptionToken: String;
begin
  Result := Model.SubscriptionToken;
end;

procedure TConsumerController.Notify(const Ctx: TWebContext);
var
  IP: String;
begin
  IP := Context.Request.ClientIP;
  Writeln('Notified by ' + IP);
  if Model.isProviderAuthorized(IP) then
  begin
    Model.OnProviderStateUpdate();
  end;
end;

procedure TConsumerController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TConsumerController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

procedure TConsumerController.Subscribe(const Ctx: TWebContext);
var
  IP: String;
  Output: String;
  Responce: TActiveQueueResponce;
begin
  IP := Context.Request.ClientIP;
  Writeln(IP);
  if Model.isAuthorised(IP) then
  begin
    Responce := Model.Subscribe();
    if Responce.status then
      Output := 'Success'
    else
      Output := Responce.Msg;
    Responce.DisposeOf;
  end
  else
    Output := 'not authorized';

  Render(output);
end;

procedure TConsumerController.Unsubscribe(const Ctx: TWebContext);
var
  Responce: TActiveQueueResponce;
  Token: String;
begin
  Token := Context.Request.Params['token'];
  Responce := Model.Unsubscribe(Token);
  Render(Responce);
end;

initialization

TConsumerController.Setup;

finalization

TConsumerController.Teardown;

end.
