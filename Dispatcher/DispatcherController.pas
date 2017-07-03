unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons, Model, MVCFramework.RESTAdapter, ActiveQueueAPI;

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
    class procedure LoadConfigFromFile(const FilePath: String);
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

class procedure TDispatcherController.LoadConfigFromFile(const FilePath: String);
var
  Content, ErrorMessage: String;
  Json: TJsonObject;
  Config: TDispatcherConfig;
begin
  if Not(TFile.Exists(FilePath)) then
    raise Exception.Create('Error: config file ' + FilePath + ' not found.');
  ErrorMessage := '';
  Content := TFile.ReadAllText(FilePath);
  try
    Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONObject;
  except
    on E: Exception do
    begin
      ErrorMessage := E.message;
      Json := nil;
    end;
  end;
  if Json <> nil then
  begin
    try
      try
        Config := TDispatcherConfig.CreateFromJson(Json);
      except
        on E: Exception do
        begin
          ErrorMessage := ErrorMessage + ', ' + E.Message;
          Config := nil;
        end;

      end;
    finally
      Json.DisposeOf;
    end;

  end;
  if Config <> nil then
  begin
    Model.Config := Config;
    SetUpBackEndProxy();
    Config.DisposeOf;
  end;
  if not(ErrorMessage.IsEmpty) then
    raise Exception.Create(ErrorMessage);
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
begin
  IP := Context.Request.ClientIP;
  if Model.isAuthorised(IP) then
  begin
    if Context.Request.ThereIsRequestBody then
    begin
      Request := Context.Request.BodyAs<TDispatcherEntry>;
    end
    else
      Request := nil;
    if Request <> nil then
      Entries := Model.CreateBackEndEntries(Request);
    if Entries <> nil then
    begin
      FBackEndProxy.PutItems(Entries);
      Responce := TDispatcherResponce.Create(True, Entries.Count.toString + ' items are put to the backend server queue.');
    end;

  end
  else
    Responce := TDispatcherResponce.Create(False, 'Not authorized');
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
