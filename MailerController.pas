unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  public
    [MVCPath('/subscribe/($origin)')]
    [MVCHTTPMethod([httpPOST])]
    procedure Subscribe(const origin: String);

    [MVCPath('/contact/($origin)')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    procedure Contact(const origin: String);

    [MVCPath('/order/($origin)')]
    [MVCHTTPMethod([httpPOST])]
    procedure Order(const origin: String);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, MailerResponceInterface, RegistrationResponce,
  SimpleMailerResponce;


procedure TMailerController.Contact(const origin: String);
var
  R: TSimpleMailerResponce;
begin
  R := TSimpleMailerResponce.Create();
  R.setMessage(origin);
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
