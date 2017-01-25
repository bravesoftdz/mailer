unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  public
    [MVCPath('/register/($origin)')]
    [MVCHTTPMethod([httpGET])]
    procedure SendRegistration(const origin: String);

    [MVCPath('/contact/($origin)')]
    [MVCHTTPMethod([httpGET])]
    procedure SendContact(const origin: String);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, MailerResponceInterface, RegistrationResponce;

procedure TMailerController.SendContact(const origin: String);
begin

  Render('Send contact from ' + origin);
end;

procedure TMailerController.SendRegistration(const origin: String);
var
  responce: IMailerResponce;
begin
  responce := TRegistrationResponce.Create;
  Render(responce);
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

end.
