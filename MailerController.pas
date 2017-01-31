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
    procedure Subscribe(const origin: String);

    [MVCPath('/contact/($path)')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    [MVCConsumes('application/json')]
    [MVCDoc('Request a contact. A user wants to be called.')]
    procedure RequestContact(Ctx: TWebContext);

    [MVCPath('/order/($path)')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    [MVCConsumes('application/json')]
    [MVCDoc('Send an order')]
    procedure SendOrder(const origin: String);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce,
  SimpleMailerResponce, System.JSON, System.SysUtils;

procedure TMailerController.RequestContact(Ctx: TWebContext);
const
  TOKEN = 'path';
var
  R: TSimpleMailerResponce;
  AJson: TJsonObject;
  path: String;
begin
  path := Ctx.request.params[TOKEN];
  R := TSimpleMailerResponce.Create();
  try
    AJSon := Ctx.Request.BodyAsJSONObject;
    R.message := 'contacting ' + path + ' with json input';
  except
    on e: Exception do
    begin
      AJSon := nil;
      R.message := 'contacting ' + path + ' with NO json input';
    end;
  end;

  Render(R);
end;

procedure TMailerController.Subscribe(const origin: String);
begin

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

procedure TMailerController.Order(const origin: String);
begin

end;

end.
