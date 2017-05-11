unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Action,
  ProviderFactory, ReceptionResponce, ActiveQueueSettings, ReceptionModel, Client,
  System.Generics.Collections;

type

  [MVCPath('/')]
  TController = class(TMVCController)
  private
    class var Model: TReceptionModel;
  strict private
  const
    ACTION_TOKEN = 'action';
    REQUESTOR_TOKEN = 'destination';
    DATA_TOKEN = 'data';
    // class var FSettings: TActiveQueueSettings;

  public
    [MVCPath('/($' + REQUESTOR_TOKEN + ')/($' + ACTION_TOKEN + ')')]
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

    /// <summary>Set the back end settings (delegate it to the model)</summary>
    class procedure SetBackEndSettings(const aSettings: TActiveQueueSettings);

    /// <summary>Get the back end settings (delegate it to the model)</summary>
    class function GetBackEndSettings(): TActiveQueueSettings;

    /// <summary>Set a list of clients. A request is taken into consideration iff it comes from one of the clients.</summary>
    class procedure SetClients(const Clients: TObjectList<TClient>);

    /// <summary>Get a copy of clients.</summary>
    class function GetClients(): TObjectList<TClient>;

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce, System.JSON, System.SysUtils,
  FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti, ObjectsMappers, FrontEndData,
  System.Classes, Attachment, Web.HTTPApp;

procedure TController.Elaborate(Ctx: TWebContext);
var
  Responce: TReceptionResponce;
  RequestorName, ActionName, Data: String;
  Request: TFrontEndRequest;
begin
  RequestorName := Ctx.request.params[REQUESTOR_TOKEN];
  ActionName := Ctx.request.params[ACTION_TOKEN];
  Data := Ctx.Request.ContentParam(DATA_TOKEN);
  Responce := Model.Elaborate(RequestorName, ActionName, Data, Ctx.Request.Files);
  Render(Responce);
end;

class function TController.GetBackEndSettings: TActiveQueueSettings;
begin
  Result := Model.BackEndSettings;
end;

class function TController.GetClients: TObjectList<TClient>;
begin
  /// there is no need in performing defencieve copying since the controller does not store this info
  Result := Model.Clients
end;

procedure TController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

class procedure TController.SetBackEndSettings(const aSettings: TActiveQueueSettings);
begin
  Model.BackEndSettings := aSettings;
end;

class procedure TController.SetClients(const Clients: TObjectList<TClient>);
begin
  /// there is no need in performing defencieve copying since the controller does not store this info
  Model.clients := Clients;
end;

initialization

TController.Model := TReceptionModel.Create();

finalization

TController.Model.DisposeOf;

end.
