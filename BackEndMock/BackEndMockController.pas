unit BackEndMockController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TBackEndMockController = class(TMVCController)
  public
    [MVCPath('/send')]
    [MVCHTTPMethod([httpPOST])]
    procedure send(const Ctx: TWebContext);
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger;

procedure TBackEndMockController.send(const Ctx: TWebContext);
begin
  Render(Ctx.Request.ToString);
end;

procedure TBackEndMockController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TBackEndMockController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

end.
