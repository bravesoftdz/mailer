unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  public
    [MVCPath('/sendfrom/($origin)')]
    [MVCHTTPMethod([httpGET])]
    procedure SendFrom(const origin: String);
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger;

procedure TMailerController.SendFrom(const origin: String);
begin
  Render('Send from ' + origin);
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
