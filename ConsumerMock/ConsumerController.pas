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

    class function GetPort(): Integer;

    class function GetConfig(): TConsumerConfig;

    /// <summary> Load the configuration from a file. The config. file must contain a string version
    /// of a json object.
    class procedure LoadConfigFromFile(const FilePath: String);

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

class procedure TConsumerController.Setup;
begin
  Model := TConsumerModel.Create();
end;

class procedure TConsumerController.Teardown;
begin
  Model.DisposeOf;
end;

class function TConsumerController.GetConfig: TConsumerConfig;
begin
  if Model <> nil then
    Result := Model.GetConfig();

end;

class function TConsumerController.GetPort: Integer;
begin
  if Model = nil then
    raise Exception.Create('Consumer model is not set.');
  Result := Model.GetPort();
end;

class procedure TConsumerController.LoadConfigFromFile(const FilePath: String);
begin
  if Model = nil then
    raise Exception.Create('Consumer model is not set.');
  Model.LoadConfigFromFile(FilePath);
  Model.Start();
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
