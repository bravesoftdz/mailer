unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Model, ConsumerConfig;

type

  [MVCPath('/')]
  TController = class(TMVCController)
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
  MVCFramework.Logger, MVCFramework.RESTAdapter, ActiveQueueAPI,
  SubscriptionData, IdSMTP, IdMessage, SendmailConfig, ActiveQueueResponce,
  System.SysUtils;

class procedure TController.Setup;
begin
  Model := TConsumerModel.Create();
end;

class procedure TController.Teardown;
begin
  Model.DisposeOf;
end;

class function TController.GetConfig: TConsumerConfig;
begin
  if Model <> nil then
    Result := Model.GetConfig();

end;

class function TController.GetPort: Integer;
begin
  if Model = nil then
    raise Exception.Create('Consumer model is not set.');
  Result := Model.GetPort();
end;

class procedure TController.LoadConfigFromFile(const FilePath: String);
begin
  if Model = nil then
    raise Exception.Create('Consumer model is not set.');
  Model.LoadConfigFromFile(FilePath);
end;

procedure TController.Notify(const Ctx: TWebContext);
var
  SMTP: TIdSMTP;
  Msg: TIdMessage;
begin
  Render('notified');
  MSG := TIdMessage.Create(NIL);
  TRY
    WITH MSG.Recipients.Add DO
    BEGIN
      Name := 'Recep. name';
      Address := TConfig.MAIL_TO;
    END;
    // MSG.BccList.Add.Address := '<Email address of Blind Copy recipient>';
    MSG.From.Name := '<Name of sender>';
    MSG.From.Address := TConfig.MAIL_FROM;
    MSG.Body.Text := 'Ciao!';
    MSG.Subject := 'test message';
    SMTP := TIdSMTP.Create(NIL);
    TRY
      SMTP.Host := TConfig.HOST;
      SMTP.Port := TConfig.PORT;
      SMTP.Connect;
      TRY
        SMTP.Send(MSG);
        Writeln('Mail sent');
      FINALLY
        SMTP.Disconnect
      END
    FINALLY
      SMTP.Free
    END
  FINALLY
    MSG.Free
  END;
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

procedure TController.Subscribe(const Ctx: TWebContext);
var
  Responce: TActiveQueueResponce;
begin
  Responce := Model.Subscribe();
  Render(Responce)
end;

procedure TController.Unsubscribe(const Ctx: TWebContext);
var
  Responce: TActiveQueueResponce;
  Token: String;
begin
  Token := Context.Request.Params['token'];
  Responce := Model.Unsubscribe(Token);
  Render(Responce);
end;

initialization

TController.Setup;

finalization

TController.Teardown;

end.
