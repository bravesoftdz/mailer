unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons, Model;

type

  [MVCPath('/')]
  TDispatcherController = class(TMVCController)
  strict private
    class var Model: TModel;
  public
    class procedure Setup();
    class procedure TearDown();

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
  // use Context property to access to the HTTP request and response
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

class procedure TDispatcherController.Setup;
begin
  Model := TModel.Create();
end;

class procedure TDispatcherController.TearDown;
begin
  Model.DisposeOf;
end;

initialization

TDispatcherController.Setup();

finalization

TDispatcherController.TearDown();

end.
