unit ReceptionController;

interface

uses
  MVCFramework, MVCFramework.Commons,
  ReceptionResponce, ActiveQueueSettings, ReceptionModel, Client,
  System.Generics.Collections, System.Classes, ServerConfig,
  MVCFramework.RESTAdapter, DispatcherProxyInterface;

type

  [MVCPath('/')]
  TController = class(TMVCController)
  private
  class var
    Model: TReceptionModel;
    FBackEndProxy: IDispatcherProxy;
    FBackEndAdapter: TRestAdapter<IDispatcherProxy>;
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

    class procedure SetUpBackEndProxy();

  public
    /// <summary>Transform the multipart form-data POST requests into a class instance and
    /// pass it to the backend server.
    /// The request is supposed to be of a multipart form-data type with attached files,
    /// i.e. like one generate by this CURL command:
    ///
    /// curl -X POST -H "Content-Type: multipart/form-data;charset=ASCII"
    /// -F data="{\"html\":\"html %%A\", \"text\":\"text %%A\", \"token\":\"super secret\"};type=application/json"
    /// -F fileName1=@path-to-file1  ... -F fileNameN=@path-to-fileN     http://localhost/requestor/action
    ///
    /// The clients that make this sort of requests must provide a valid token inside the json object
    /// corresponding to "data" key. The IP address and the token are controller against the allowed ones
    /// listed in the configuration file.
    [MVCPath('/($' + REQUESTOR_KEY + ')/($' + ACTION_KEY + ')')]
    [MVCHTTPMethod([httpPOST])]
    procedure ElaborateRequest(Ctx: TWebContext);

    /// <summary>Get a copy of clients.</summary>
    class function GetClients(): TObjectList<TClient>;

    class function GetBackEndUrl: String;

    class function GetBackEndPort: Integer;

    class procedure SetConfig(const Config: TServerConfig);

    class function GetPort(): Integer;

    class procedure Setup();
    class procedure TearDown();

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, System.JSON, System.SysUtils, DispatcherEntry,
  // FrontEndRequest, VenditoriSimple, Provider, SoluzioneAgenti,
  ObjectsMappers,
  // ClientRequest,
  Attachment, Web.HTTPApp, ClientFullRequest, DispatcherResponce;

procedure TController.ElaborateRequest(Ctx: TWebContext);
var
  Responce: TReceptionResponce;
  RequestorName, ActionName, Body, IP, Boundary: String;
  Request: TClientFullRequest;
  Attachments: TObjectList<TAttachment>;
  Len, I: Integer;
  AttachedFiles: TAbstractWebRequestFiles;
  MemStream: TMemoryStream;
  AJSon: TJSONObject;
  DispatcherEntry: TDispatcherEntry;
  DispatcherResponce: TDispatcherResponce;
  Token: String;
  TokenV: TJsonValue;
  Attach: TAttachment;

begin
  RequestorName := Ctx.request.params[REQUESTOR_KEY];
  ActionName := Ctx.request.params[ACTION_KEY];
  IP := Ctx.Request.ClientIP;
  try
    boundary := Model.GetParamValue(Ctx.Request.Headers['Content-Type'], 'boundary');
    Body := Model.ExtractBody(boundary, Ctx.Request.Body, 'application/json', 'data');
    AJSon := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Body), 0) as TJSONObject;
  except
    on e: Exception do
      AJson := nil;
  end;
  if AJson <> nil then
  begin
    TokenV := AJson.GetValue('token');
    if TokenV <> nil then
    begin
      Token := TokenV.Value;
    end;

  end;
  if (AJson = nil) OR (TokenV = nil) then
    Responce := TReceptionResponce.Create(False, 'Token not found.')
  else
  begin
    if not(Model.isAuthenticated(IP, Token)) then
    begin
      Responce := TReceptionResponce.Create(false, 'Not authorized.');
    end
    else
    begin
      Attachments := TObjectList<TAttachment>.Create;
      AttachedFiles := Ctx.Request.Files;
      Len := AttachedFiles.Count;
      for I := 0 to Len - 1 do
      begin
        MemStream := TMemoryStream.Create();
        MemStream.CopyFrom(AttachedFiles[I].Stream, AttachedFiles[I].Stream.Size);
        Attachments.Add(TAttachment.Create(AttachedFiles[I].FieldName, MemStream));
        MemStream.DisposeOf;
      end;
      try
        DispatcherEntry := Model.BuildBackEndEntry(RequestorName, ActionName, AJSon.ToString, Attachments);
        Writeln('Prepared a request with ' + DispatcherEntry.Attachments.Count.ToString + ' attachment(s).');
        for Attach in DispatcherEntry.Attachments do
        begin
          Writeln(Format('name: %s, size: %d', [Attach.Name, Attach.Content.Size]));
        end;

        try
          DispatcherResponce := FBackEndProxy.PutEntry(DispatcherEntry);
        except
          on E: Exception do
          begin
            Writeln('Error while making request: ' + E.Message);
            DispatcherResponce := nil;
          end;
        end;
        if DispatcherResponce <> nil then
        begin
          Responce := Model.ConvertToOwnResponce(DispatcherResponce);
          DispatcherResponce.DisposeOf;
        end
        else
        begin
          Responce := TReceptionResponce.Create(False, 'No responce from the backend server');
        end;
      finally
        DispatcherEntry.DisposeOf;
        Attachments.Clear;
        Attachments.DisposeOf;
      end;
    end;
  end;
  if AJson <> nil then
    AJSon.DisposeOf;
  Render(Responce);
end;

class function TController.GetBackEndPort: Integer;
begin
  Result := Model.BackEndPort;
end;

class function TController.GetBackEndUrl: String;
begin
  Result := Model.BackEndUrl;
end;

class function TController.GetPort: Integer;
begin
  Result := Model.Port;
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

class function TController.GetClients: TObjectList<TClient>;
begin
  Result := Model.Clients
end;

class procedure TController.SetConfig(const Config: TServerConfig);
begin
  Model.Config := Config;
  SetUpBackEndProxy();
end;

class procedure TController.Setup;
begin
  Writeln('Controller set up');
  Model := TReceptionModel.Create();
  FBackEndAdapter := TRestAdapter<IDispatcherProxy>.Create();
end;

class procedure TController.SetUpBackEndProxy;
begin
  Writeln(Format('Set up the proxy:  url = %s, port = %d', [Model.BackEndUrl, Model.BackEndPort]));
  FBackEndProxy := FBackEndAdapter.Build(Model.BackEndUrl, Model.BackEndPort);
end;

class procedure TController.TearDown;
begin
  Writeln('Controller tear down');
  Model.DisposeOf();
  if (FBackEndProxy <> nil) then
    FBackEndProxy := nil;
  if (FBackEndAdapter <> nil) then
    FBackEndAdapter := nil;
end;

initialization

TController.Setup();

finalization

TController.TearDown();

end.
