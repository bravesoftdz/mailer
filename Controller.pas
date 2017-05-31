unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Action,
  ProviderFactory, Responce, ActiveQueueSettings, ReceptionModel, Client,
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

    /// <summary>Extract body from a multipart request body</summary
    function ExtractBody(const ContentType, RawBody: String): String;
    /// <summary>Extract a value corresponding to a key in a set of key-value pairs. The pairs
    /// are separated by semicolon, while the key and value are separated by equality sign. A key is
    /// optional in the key-value pairs. Example:
    /// 'multipart/form-data;charset=UTF-8;boundary=--dsds'
    function GetParamValue(const Query: String; const Param: String): String;
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
    /// -d "{\"token\":\"abcdefgh\", \"html\":\"html version of the mail\", \"text\":\"text version of the mail\"}"
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
  MVCFramework.Logger, System.JSON, System.SysUtils,
  FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti, ObjectsMappers, ClientRequest,
  System.Classes, Attachment, Web.HTTPApp, ClientFullRequest;

procedure TController.Elaborate(Ctx: TWebContext);
var
  Responce, Responce2: TResponce;
  RequestorName, ActionName, Body, IP, Token: String;
  Body2: TClientRequest;
  Request: TClientFullRequest;
  Attachments: TObjectList<TAttachment>;
  Len, I: Integer;
  AttachedFiles: TAbstractWebRequestFiles;
  MemStream: TMemoryStream;
  ContentType: String;
  CT: TArray<string>;
begin
  RequestorName := Ctx.request.params[REQUESTOR_KEY];
  ActionName := Ctx.request.params[ACTION_KEY];
  IP := Ctx.Request.ClientIP;
  try
    Body := ExtractBody(Ctx.Request.Headers['Content-Type'], Ctx.Request.Body);
    Writeln(ContentType);
  except
    on e: Exception do
      Writeln(e.Message);

  end;
  //
  // Responce := Model.Elaborate(RequestorName, ActionName, Body, IP, Ctx.Request.Files);

  // Writeln(Ctx.Request.Body);

  Attachments := TObjectList<TAttachment>.Create;
  AttachedFiles := Ctx.Request.Files;
  Len := AttachedFiles.Count;
  for I := 0 to Len - 1 do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.CopyFrom(AttachedFiles[I].Stream, AttachedFiles[I].Stream.Size);
    Attachments.Add(TAttachment.Create(AttachedFiles[I].FieldName, MemStream));
  end;

  Request := TClientFullRequest.Create(Body2, Attachments);
  Responce2 := Model.Elaborate2(RequestorName, ActionName, IP, Request);

  // Render(Responce);
end;

function TController.ExtractBody(const ContentType, RawBody: String): String;
var
  items: TArray<string>;
  boundary: String;
begin
  if not ContentType.IsEmpty then
  begin
    items := ContentType.Split([';']);
    boundary := GetParamValue(ContentType, 'boundary');
    // ContentType := Trim(items[0]);
    // if Length(items) > 1 then
    // begin
    // if CT[1].Trim.StartsWith('charset', true) then
    // begin
    // FCharset := CT[1].Trim.Split(['='])[1].Trim;
    // end;
  end;

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

function TController.GetParamValue(const Query, Param: String): String;
var
  items, keyvalue: TArray<string>;
  pair: String;
begin
  if not Query.IsEmpty then
  begin
    items := Query.Split([';']);
    for pair in items do
    begin
      keyvalue := pair.trim().split(['=']);
      if Length(keyvalue) = 2 then
      begin
        if Param.Equals(keyvalue[0].trim()) then
        begin
          Result := keyvalue[1];
          Exit();
        end;
      end

    end

  end;

  // ContentType := Trim(items[0]);
  // if Length(items) > 1 then
  // begin
  // if CT[1].Trim.StartsWith('charset', true) then
  // begin
  // FCharset := CT[1].Trim.Split(['='])[1].Trim;
  // end;
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
