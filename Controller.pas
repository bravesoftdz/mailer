﻿unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Action,
  ProviderFactory, ReceptionResponce, ActiveQueueSettings, ReceptionModel, Client;

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
    class var FSettings: TActiveQueueSettings;
    class var FClients: TArray<TClient>;

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

    /// <summary>Set up a global (i.e., static) object for the back end settings</summary>
    class procedure SetBackEnd(const aSettings: TActiveQueueSettings);

    /// <summary>Set a list of clients. A request is taken into consideration iff it comes from one of the clients.</summary>
    class procedure SetClients(const Clients: TObjectList<TClient>);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, RegistrationResponce, System.JSON, System.SysUtils,
  FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti, ObjectsMappers, FrontEndData,
  System.Classes, Attachment, Web.HTTPApp, System.Generics.Collections;

procedure TController.Elaborate(Ctx: TWebContext);
var
  Responce: TReceptionResponce;
  RequestorName, ActionName, Data: String;
  Request: TFrontEndRequest;
begin
  RequestorName := Ctx.request.params[REQUESTOR_TOKEN];
  ActionName := Ctx.request.params[ACTION_TOKEN];
  Data := Ctx.Request.ContentParam(DATA_TOKEN);
  Responce := Model.Elaborate(RequestorName, ActionName, Data, Ctx.Request.Files, FSettings);
  Render(Responce);
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

class procedure TController.SetBackEnd(const aSettings: TActiveQueueSettings);
begin
  FSettings := aSettings;
end;

class procedure TController.SetClients(const Clients: TObjectList<TClient>);
begin
  raise Exception.Create('Not implemented yet');
end;

initialization

TController.Model := TReceptionModel.Create();

finalization

TController.Model.DisposeOf;

end.