unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TDispatcherController = class(TMVCController) 
  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/hellos/($FirstName)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetSpecializedHello(const FirstName: String);
  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger;

procedure TDispatcherController.Index;
begin
  //use Context property to access to the HTTP request and response 
  Render('Hello World');
end;

procedure TDispatcherController.GetSpecializedHello(const FirstName: String);
begin
  Render('Hello ' + FirstName);
end;

procedure TDispatcherController.OnAfterAction(Context: TWebContext; const AActionName: string); 
begin
  { Executed after each action }
  inherited;
end;

procedure TDispatcherController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;


end.
