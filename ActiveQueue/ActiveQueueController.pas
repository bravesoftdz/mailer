unit ActiveQueueController;

interface

uses
  MVCFramework, MVCFramework.Commons, ActiveQueueModel;

type

  [MVCPath('/')]
  TActiveQueueController = class(TMVCController)

  strict private
    class var Model: TActiveQueueModel;

  public
    /// <summary> Initialize the model. Since this controller is added in a static manner,
    /// I have to create a static method that instantiate a static reference
    /// corresponding to the model
    /// </summary>
    class procedure Setup();
    /// <summary> Release the reference to the model instantiated during the initialization
    /// </summary>
    class procedure Teardown();

    [MVCPath('/subscribe')]
    [MVCHTTPMethod([httpPUT])]
    procedure Subscribe(const Context: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, ActiveQueueResponce, System.JSON;

procedure TActiveQueueController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TActiveQueueController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

class procedure TActiveQueueController.Setup;
begin
  Model := TActiveQueueModel.Create;
end;

procedure TActiveQueueController.Subscribe(const Context: TWebContext);
var
  responce: TActiveQueueResponce;
  json: TJsonObject;
begin
  json := Context.Request.BodyAsJSONObject;

  responce := TActiveQueueResponce.Create();
  responce.status := True;
  responce.Msg := 'Welcome';
  Render(responce);
end;

class procedure TActiveQueueController.Teardown;
begin
  Model.DisposeOf;
end;

initialization

TActiveQueueController.Setup;

finalization

TActiveQueueController.Teardown;

end.
