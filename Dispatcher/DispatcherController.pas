unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons, Model, MVCFramework.RESTAdapter, ActiveQueueAPI,
  ServerConfig;

type

  [MVCPath('/')]
  TDispatcherController = class(TMVCController)
  strict private
  class var
    Model: TModel;
    FBackEndProxy: IActiveQueueAPI;
    FBackEndAdapter: TRestAdapter<IActiveQueueAPI>;
    class procedure SetUpBackEndProxy();

  public
    [MVCPath('/status')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/request')]
    [MVCHTTPMethod([httpPUT])]
    procedure PutRequest(Context: TWebContext);

    class procedure Setup();
    class procedure TearDown();
    class procedure SetConfig(const Config: TServerConfig);
    class function GetPort(): Integer;
    class function GetClientIps(): TArray<String>;
    class function GetBackEndPort(): Integer;
    class function GetBackEndIp(): String;

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, System.JSON, System.IOUtils, System.SysUtils,
  DispatcherConfig, DispatcherResponce, DispatcherEntry, ActiveQueueEntry,
  System.Generics.Collections;

procedure TDispatcherController.Index;
var
  Str: String;
begin
  Str := 'Cogito ergo sum (R. Descartes) ' + formatdatetime('h:n:ss', Now);
  Render(Str);
end;

class procedure TDispatcherController.SetConfig(const Config: TServerConfig);
var
  Content, ErrorMessage: String;
  Json: TJsonObject;
begin
  // if Not(TFile.Exists(FilePath)) then
  // raise Exception.Create('Error: config file ' + FilePath + ' not found.');
  // ErrorMessage := '';
  // Content := TFile.ReadAllText(FilePath);
  // try
  // Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONObject;
  // except
  // on E: Exception do
  // begin
  // ErrorMessage := E.message;
  // Json := nil;
  // end;
  // end;
  // if Json <> nil then
  // begin
  // try
  // try
  // Config := TDispatcherConfig.CreateFromJson(Json);
  // except
  // on E: Exception do
  // begin
  // ErrorMessage := ErrorMessage + ', ' + E.Message;
  // Config := nil;
  // end;
  //
  // end;
  // finally
  // Json.DisposeOf;
  // end;
  //
  // end;
  // if Config <> nil then
  // begin
  Model.Config := Config;
  SetUpBackEndProxy();
  Config.DisposeOf;
  // end;
  // if not(ErrorMessage.IsEmpty) then
  // raise Exception.Create(ErrorMessage);
end;

class function TDispatcherController.GetBackEndIp: String;
begin
  Result := Model.GetBackEndIp();
end;

class function TDispatcherController.GetBackEndPort: Integer;
begin
  Result := Model.GetBackEndPort();
end;

class function TDispatcherController.GetClientIps: TArray<String>;
begin
  Result := Model.GetClientIps();
end;

class function TDispatcherController.GetPort: Integer;
begin
  Result := Model.GetPort();
end;

procedure TDispatcherController.PutRequest(Context: TWebContext);
var
  IP: String;
  Request: TDispatcherEntry;
  Entries: TObjectList<TActiveQueueEntry>;
  Responce: TDispatcherResponce;
  Wrapper: TActiveQueueEntries;
  Outcome: Boolean;
begin
  IP := Context.Request.ClientIP;

  if Context.Request.ThereIsRequestBody then
  begin
    try
      Request := Context.Request.BodyAs<TDispatcherEntry>;
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, 'Invalid request body.');
        Render(Responce);
        Exit();
      end;
    end;
  end
  else
  begin
    Responce := TDispatcherResponce.Create(False, 'No request body found.');
    Render(Responce);
    Exit();
  end;

  if not(Model.isAuthorised(IP, Request.Token)) then
  begin
    Responce := TDispatcherResponce.Create(False, 'Not authorized');
    Render(Responce);
    Exit();
  end;

  try
    Entries := Model.CreateBackEndEntries(Request);
  except
    on E: Exception do
    begin
      Responce := TDispatcherResponce.Create(False, E.Message);
      Render(Responce);
      Exit();
    end;
  end;

  Wrapper := TActiveQueueEntries.Create(Entries);
  try
    try
      Outcome := FBackEndProxy.PutItems(Wrapper);
      Responce := TDispatcherResponce.Create(Outcome, Entries.Count.toString + ' items are put to the backend server queue.');
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, 'Failed to put items to the back end server: ' + E.Message);
      end;
    end;
  finally
    Wrapper.DisposeOf;
  end;
  Render(Responce);
end;

procedure TDispatcherController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TDispatcherController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

class
  procedure TDispatcherController.Setup;
begin
  Model := TModel.Create();
  FBackEndAdapter := TRestAdapter<IActiveQueueAPI>.Create();
end;

class procedure TDispatcherController.SetUpBackEndProxy;
begin
  Writeln(Format('Set up the proxy:  url = %s, port = %d', [Model.GetBackEndIp, Model.GetBackEndPort]));
  FBackEndProxy := FBackEndAdapter.Build(Model.GetBackEndIp, Model.GetBackEndPort);
end;

class
  procedure TDispatcherController.TearDown;
begin
  Model.DisposeOf;
  if (FBackEndAdapter <> nil) then
    FBackEndAdapter := nil;
  if (FBackEndProxy <> nil) then
    FBackEndProxy := nil;
end;

initialization

TDispatcherController.Setup();

finalization

TDispatcherController.TearDown();

end.
