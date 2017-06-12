unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Model;

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
  SubscriptionData, ActiveQueueResponce, IdSMTP, IdMessage, Config,
  System.SysUtils;

class procedure TController.Setup;
begin
  Model := TConsumerModel.Create();
end;

class procedure TController.Teardown;
begin
  Model.DisposeOf;
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
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
  Responce: TActiveQueueResponce;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build('192.168.5.95', 8070);
  Responce := Server.Subscribe(TSubscriptionData.Create('1.1.1.1', '', 9001, ''));
  if Responce.Status then
    Writeln('subscription token: ' + Responce.Token)
  else
    Writeln('Failed to subscribe: ' + Responce.Msg);
end;

procedure TController.Unsubscribe(const Ctx: TWebContext);
var
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
  Responce: TActiveQueueResponce;
  Token: String;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build('192.168.5.95', 8070);
  Token := Context.Request.Params['token'];
  Responce := Server.UnSubscribe(Token);
  if (Responce.status) then
    Writeln('unsubscription success.')
  else
    Writeln('unsubscription failure')
end;

initialization

TController.Setup;

finalization

TController.Teardown;

end.
