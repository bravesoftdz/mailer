unit MailerController;

interface

uses
  MVCFramework, MVCFramework.Commons, System.Generics.Collections, Action,
  ProviderFactory, FrontEndResponce, BackEndSettings;

type

  [MVCPath('/')]
  TMailerController = class(TMVCController)
  private
    const
    ACTION_TOKEN = 'action';
    PROVIDER_TOKEN = 'destination';
    DATA_TOKEN = 'data';
    class var FFactory: TProviderFactory;
    class procedure SetupFactory();
    class var FSettings: TBackEndSettings;

  public
    [MVCPath('/($' + PROVIDER_TOKEN + ')/($' + ACTION_TOKEN + ')')]
    [MVCHTTPMethod([httpPOST])]
    // [MVCProduces('application/json')]
    // [MVCConsumes('application/json')]
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

    /// <summary>Set up a global (i.e., static) object for the back end settings</summary>
    class procedure SetBackEnd(const aSettings: TBackEndSettings);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce, System.JSON, System.SysUtils,
  FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti, ObjectsMappers, FrontEndData,
  System.Classes, Attachment, Web.HTTPApp;

procedure TMailerController.Elaborate(Ctx: TWebContext);
var
  Responce: TFrontEndResponce;
  AJson: TJsonObject;
  ProviderName, ActionName: String;
  Provider: TProvider;
  Action: TAction;
  Request: TFrontEndRequest;
  fs: TFileStream;
  ms: TMemoryStream;
  Data: String;
  input: TFrontEndData;
begin
  ProviderName := Ctx.request.params[PROVIDER_TOKEN];
  ActionName := Ctx.request.params[ACTION_TOKEN];
  try
    Provider := nil;
    Action := nil;
    Data := Ctx.Request.ContentParam(DATA_TOKEN);
    AJSon := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Data), 0) as TJSONObject;
    if (AJson <> nil) then
    begin
      input := Mapper.JSONObjectToObject<TFrontEndData>(AJSon);
    end;
    Request := TFrontEndRequest.Create(input, Ctx.Request.Files);
    Provider := FFactory.FindByName(ProviderName);
    if (Provider <> nil) then
      Action := Provider.FindByName(ActionName);
    if (Action <> nil) then
    begin
      Responce := Action.Elaborate(Request, FSettings);
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

class procedure TMailerController.SetBackEnd(const aSettings: TBackEndSettings);
begin
  FSettings := aSettings;
end;

class procedure TMailerController.SetupFactory();
var
  Providers: TObjectList<TProvider>;
begin
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
end;

initialization

TMailerController.SetupFactory();

end.
