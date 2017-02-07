unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons, System.Generics.Collections, Action,
  ProviderFactory;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  private
    const
    ACTION_TOKEN = 'action';
    PROVIDER_TOKEN = 'destination';
    class var FFactory: TProviderFactory;
    class procedure SetupFactory();

  public
    [MVCPath('/($' + PROVIDER_TOKEN + ')/($' + ACTION_TOKEN + ')')]
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
  SimpleMailerResponce, System.JSON, System.SysUtils,
  SimpleInputData, VenditoriSimple, Provider;

procedure TMailerController.Elaborate(Ctx: TWebContext);
var
  Responce: TSimpleMailerResponce;
  AJson: TJsonObject;
  ProviderName, ActionName: String;
  Provider: TProvider;
  Action: TAction;
  InputObj: TSimpleInputData;
begin
  ProviderName := Ctx.request.params[PROVIDER_TOKEN];
  ActionName := Ctx.request.params[ACTION_TOKEN];
  try
    AJSon := Ctx.Request.BodyAsJSONObject;
    InputObj := TSimpleInputData.Create(ProviderName, AJson);
    Provider := FFactory.FindByName(ProviderName);
    if Not(Provider = nil) then
      Action := Provider.FindByName(ActionName);
    if Not(Action = nil) then
    begin
      Responce := Action.Elaborate(InputObj)
    end
    else
    begin
      Responce := TSimpleMailerResponce.Create;
      Responce.message := 'authorization missing...';
    end;
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

class procedure TMailerController.SetupFactory();
var
  Providers: TObjectList<TProvider>;
begin
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create]);
  // Provider :=
  FFactory := TProviderFactory.Create(Providers);
end;

initialization

TMailerController.SetupFactory();

end.
