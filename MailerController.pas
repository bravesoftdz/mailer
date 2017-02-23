unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons, System.Generics.Collections, Action,
  ProviderFactory, FrontEndResponce;

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
    /// <summary>  An entry point to the server.
    /// This method handles requests of the form  "/provider/action", i.e.
    /// "/venditori/send", "/soluzioniagenti/contact".
    /// The requests must be done by means of a POST method.
    /// It accepts a json object with the following structure:
    /// {'msg': 'some string'}
    /// </summary>
    /// <param name="Ctx">a context of the request</param>
    procedure Elaborate(Ctx: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce, System.JSON, System.SysUtils,
  FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti, REST.Json;

procedure TMailerController.Elaborate(Ctx: TWebContext);
var
  Responce: TFrontEndResponce;
  AJson: TJsonObject;
  ProviderName, ActionName: String;
  Provider: TProvider;
  Action: TAction;
  Request: TFrontEndRequest;
begin
  ProviderName := Ctx.request.params[PROVIDER_TOKEN];
  ActionName := Ctx.request.params[ACTION_TOKEN];
  try
    Provider := nil;
    Action := nil;
    AJSon := Ctx.Request.BodyAsJSONObject;
    Request := TJson.JsonToObject<TFrontEndRequest>(AJSon);
    Provider := FFactory.FindByName(ProviderName);
    if (Provider <> nil) then
      Action := Provider.FindByName(ActionName);
    if (Action <> nil) then
    begin
      Responce := Action.Elaborate(Request)
    end
    else
    begin
      Responce := TFrontEndResponce.Create;
      Responce.msg := 'authorization missing...';
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
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  // Provider :=
  FFactory := TProviderFactory.Create(Providers);
end;

initialization

TMailerController.SetupFactory();

end.
