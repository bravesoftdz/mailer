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

    /// named part of the url that stores the value of the requested action
    ACTION_KEY = 'action';

    /// named part of the url that stores the value of the requested action requestor
    REQUESTOR_KEY = 'destination';

    /// name of the key in the request that by means of which the requestor-specific token is passed
    TOKEN_KEY = 'token';

    /// name of the key in the request that by means of which the requestor passes the data
    DATA_KEY = 'data';

  public
    // [MVCPath('/($' + REQUESTOR + ')/($' + ACTION + ')')]
    [MVCPath('/($' + REQUESTOR_KEY + ')/($' + ACTION_KEY + ')')]
    [MVCHTTPMethod([httpPOST])]
    // [MVCProduces('application/json')]
    // [MVCConsumes('application/json')]
    [MVCDoc('Elaborate the request. The action that should be performed is to be decided based on provided destination and action token.')]
    /// <summary>  An entry point to the server.
    /// This method handles requests of the form  "/requestor/action", i.e.
    /// "/venditori/send", "/soluzioniagenti/contact".
    /// The method handles the requests that being expressend in terms of CURL have the following
    /// form (split on multiple line for clarity)
    ///
    /// curl -X POST -H "Content-Type: application/json"
    /// -d token="abcdefgh"
    /// -d data="{\"html\":\"html version of the mail\", \"text\":\"text version of the mail\"}"
    /// http://localhost/venditori/send
    ///
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
  RequestorName, ActionName, Data, IP, Token: String;
  Request: TFrontEndRequest;
  AJson: TJsonObject;
begin
  RequestorName := Ctx.request.params[REQUESTOR_KEY];
  IP := Context.Request.ClientIP;
  ActionName := Ctx.request.params[ACTION_KEY];
  Token := Ctx.request.params[TOKEN_KEY];
  Data := Ctx.request.params[DATA_KEY];
  Responce := Model.Elaborate(RequestorName, ActionName, Data, Token, IP, Ctx.Request.Files);
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
