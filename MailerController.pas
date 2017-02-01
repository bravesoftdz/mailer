unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  public
    [MVCPath('/subscribe/($path)')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    [MVCConsumes('application/json')]
    [MVCDoc('Subscribe a user to a requested service')]
    procedure Subscribe(Ctx: TWebContext);

    [MVCPath('/contact/($path)')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    [MVCConsumes('application/json')]
    [MVCDoc('Contact a user')]
    procedure RequestContact(Ctx: TWebContext);

    [MVCPath('/order/($path)')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    [MVCConsumes('application/json')]
    [MVCDoc('Send an order')]
    procedure SendOrder(Ctx: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce,
  SimpleMailerResponce, System.JSON, System.SysUtils, MailerAction,
  SimpleInputData;

procedure TMailerController.RequestContact(Ctx: TWebContext);
const
  TOKEN = 'path';
var
  Responce: TSimpleMailerResponce;
  AJson: TJsonObject;
  path: String;
  Worker: TMailerAction;
  InputObj: TSimpleInputData;
begin
  path := Ctx.request.params[TOKEN];
  Worker := TMailerAction.Create;
  try
    AJSon := Ctx.Request.BodyAsJSONObject;
    InputObj := TSimpleInputData.Create('', path, AJson);
    Responce := Worker.Elaborate(InputObj);
    Render(Responce);
  except
    on e: Exception do
    begin
      AJSon := nil;
    end;
  end;
end;

procedure TMailerController.Subscribe(Ctx: TWebContext);
const
  TOKEN = 'path';
var
  Responce: TSimpleMailerResponce;
  AJson: TJsonObject;
  path: String;
  Worker: TMailerAction;
  InputObj: TSimpleInputData;
begin
  path := Ctx.request.params[TOKEN];
  Worker := TMailerAction.Create;
  try
    AJSon := Ctx.Request.BodyAsJSONObject;
    InputObj := TSimpleInputData.Create('', path, AJson);
    Responce := Worker.Elaborate(InputObj);
    Render(Responce);
  except
    on e: Exception do
    begin
      AJSon := nil;
    end;
  end;
end;

procedure TMailerController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TMailerController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

procedure TMailerController.SendOrder(const origin: String);
begin

end;

end.
