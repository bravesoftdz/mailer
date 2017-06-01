unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Action,
  ProviderFactory, Responce, ActiveQueueSettings, ReceptionModel, Client,
  System.Generics.Collections, System.Classes;

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
    function ExtractBody(const Boundary, RawBody, ContentType, KeyName: String): String;
    /// <summary>Extract a value corresponding to a key in a set of key-value pairs. The pairs
    /// are separated by semicolon, while the key and value are separated by equality sign. A key is
    /// optional in the key-value pairs. Example:
    /// 'multipart/form-data;charset=UTF-8;boundary=--dsds'
    function GetParamValue(const Query: String; const Param: String): String;

    /// <summary>Return a first element from the array that has given content type and key name.
    /// If nothing is found, an empty string is returned.
    /// Example of the array elements (this is just a one element, it spans many lines):
    /// Content-Disposition: form-data; name="data"
    /// Content-Type: application/json
    /// { "html":"html version of the mail", "text":"text version of the mail", "token":"abcdef" }
    /// </summary>
    function PickMultipartItem(const Items: TArray<String>; const ContentType: String; const KeyName: String): String;
    /// <summary> Returns a copy of original list in which the elements at specified postions are skipped</summary>
    function SkipElements(const Items: TStringList; const positions: TList<Integer>): TStringList;
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
  FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti, ObjectsMappers, ClientRequest, Attachment, Web.HTTPApp, ClientFullRequest;

procedure TController.Elaborate(Ctx: TWebContext);
var
  Responce: TResponce;
  RequestorName, ActionName, Body, IP, Boundary: String;
  Request: TClientFullRequest;
  Attachments: TObjectList<TAttachment>;
  Len, I: Integer;
  AttachedFiles: TAbstractWebRequestFiles;
  MemStream: TMemoryStream;
  AJSon: TJSONObject;
  Input: TClientRequest;
begin
  RequestorName := Ctx.request.params[REQUESTOR_KEY];
  ActionName := Ctx.request.params[ACTION_KEY];
  IP := Ctx.Request.ClientIP;
  try
    boundary := GetParamValue(Ctx.Request.Headers['Content-Type'], 'boundary');
    Body := ExtractBody(boundary, Ctx.Request.Body, 'application/json', 'data');
  except
    on e: Exception do
      Writeln(e.Message);
  end;

  try
    AJSon := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Body), 0) as TJSONObject;
  except
    on E: Exception do
    begin
      AJSon := nil;
    end;
  end;

  if (AJson <> nil) then
  begin
    try
      Input := Mapper.JSONObjectToObject<TClientRequest>(AJSon);
    except
      on E: Exception do
      begin
        Input := nil;
      end;
    end;
  end;

  Attachments := TObjectList<TAttachment>.Create;
  AttachedFiles := Ctx.Request.Files;
  Len := AttachedFiles.Count;
  for I := 0 to Len - 1 do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.CopyFrom(AttachedFiles[I].Stream, AttachedFiles[I].Stream.Size);
    Attachments.Add(TAttachment.Create(AttachedFiles[I].FieldName, MemStream));
  end;

  Request := TClientFullRequest.Create(Input, Attachments);
  Responce := Model.Elaborate2(RequestorName, ActionName, IP, Request);

  Render(Responce);
end;

function TController.ExtractBody(const Boundary, RawBody, ContentType, KeyName: String): String;
var
  items, BodyParts: TArray<string>;
  separator: String;
begin
  if not ContentType.IsEmpty then
  begin
    items := ContentType.Split([';']);
    if not Boundary.IsEmpty then
    begin
      /// See section 5.1.1 "Common Syntax" (http://www.ietf.org/rfc/rfc2046.txt):
      /// The Content-Type field for multipart entities requires one parameter,
      // "boundary". The boundary delimiter line is then defined as a line
      // consisting entirely of two hyphen characters ("-", decimal value 45)
      // followed by the boundary parameter value from the Content-Type header
      // field, optional linear whitespace, and a terminating CRLF.
      Separator := '--' + boundary;
      BodyParts := RawBody.Split([Separator]);
      Result := PickMultipartItem(BodyParts, ContentType, KeyName);
    end;

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

function TController.PickMultipartItem(const Items: TArray<String>; const ContentType,
  KeyName: String): String;
var
  Elem, Needle1, Needle2: String;
  Parts: TStringList;
  positions: TList<Integer>;

begin
  Needle1 := 'Content-Disposition: form-data; name="' + KeyName + '"';
  Needle2 := 'Content-Type: ' + ContentType;
  Parts := TStringList.Create;
  for Elem in Items do
  begin
    Parts.Text := Elem.Trim();
    if Parts.Count > 2 then
    begin
      if (Parts[0] = Needle1) AND (Parts[1] = Needle2) then
      begin
        Positions := TList<Integer>.Create;
        Positions.Add(0);
        Positions.Add(1);
        Result := SkipElements(Parts, Positions).Text.trim();
        Exit();
      end;
    end;

  end;

end;

class
  procedure TController.SetBackEndSettings(
  const
  aSettings:
  TActiveQueueSettings);
begin
  Model.BackEndSettings := aSettings;
end;

class
  procedure TController.SetClients(
  const
  Clients:
  TObjectList<TClient>);
begin
  /// there is no need in performing defencieve copying since the controller does not store this info
  Model.clients := Clients;
end;

function TController.SkipElements(const Items: TStringList; const positions: TList<Integer>): TStringList;
var
  I, L: Integer;
begin
  Result := TStringList.Create;
  L := Items.Count;
  for I := 0 to L - 1 do
    if not(Positions.Contains(I)) then
    begin
      Result.Add(Items[I]);
    end;

end;

initialization

TController.Model := TReceptionModel.Create();

finalization

TController.Model.DisposeOf;

end.
