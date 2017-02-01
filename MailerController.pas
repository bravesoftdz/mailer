unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  private
    const
    ACTION_TOKEN = 'action';
    DESTINATION_TOKEN = 'destination';
  public
    [MVCPath('/($' + DESTINATION_TOKEN + ')/($' + ACTION_TOKEN + ')')]
    [MVCHTTPMethod([httpPOST])]
    [MVCProduces('application/json')]
    [MVCConsumes('application/json')]
    [MVCDoc('Elaborate the request. The action that should be performed is to be decided based on provided destination and action token.')]
    procedure Elaborate(Ctx: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce,
  SimpleMailerResponce, System.JSON, System.SysUtils, MailerAction,
  SimpleInputData;

procedure TMailerController.Elaborate(Ctx: TWebContext);
var
  Responce: TSimpleMailerResponce;
  AJson: TJsonObject;
  Destination, ActionName: String;
  Worker: TMailerAction;
  InputObj: TSimpleInputData;
begin
  Destination := Ctx.request.params[DESTINATION_TOKEN];
  ActionName := Ctx.request.params[ACTION_TOKEN];
  Worker := TMailerAction.Create(destination, ActionName);
  try
    AJSon := Ctx.Request.BodyAsJSONObject;
    InputObj := TSimpleInputData.Create(Destination, AJson);
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

end.
