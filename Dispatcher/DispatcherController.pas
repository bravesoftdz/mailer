unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons, DispatcherModel, MVCFramework.RESTAdapter, AQAPIClient,
  ServerConfig;

type

  [MVCPath('/')]
  TDispatcherController = class(TMVCController)
  strict private
  class var
    Model: TModel;
    FBackEndProxy: IAQAPIClient;
    FBackEndAdapter: TRestAdapter<IAQAPIClient>;
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
    class procedure SetConfig(const Config: TServerConfigImmutable);
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
  System.Generics.Collections, ActiveQueueResponce;

procedure TDispatcherController.Index;
var
  Str: String;
begin
  Str := 'Cogito ergo sum (R. Descartes) ' + formatdatetime('h:n:ss', Now);
  Render(Str);
end;

class procedure TDispatcherController.SetConfig(const Config: TServerConfigImmutable);
begin
  Model.Config := Config;
  SetUpBackEndProxy();
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
  BackEndResponce: TActiveQueueResponce;
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
      BackEndResponce := FBackEndProxy.PostItems(Wrapper);
      if BackEndResponce.status then
        Responce := TDispatcherResponce.Create(BackEndResponce.status, Entries.Count.toString + ' items are put to the backend server queue.')
      else
        Responce := TDispatcherResponce.Create(BackEndResponce.status, 'Dispatcher received failure. Reason: ' + BackEndResponce.Msg)
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, 'Failed to put items to the back end server: ' + E.Message);
      end;
    end;
  finally
    Wrapper.DisposeOf;
    BackEndResponce.DisposeOf;
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

end;

class procedure TDispatcherController.SetUpBackEndProxy;
begin
  Writeln(Format('Set up the proxy:  url = %s, port = %d', [Model.GetBackEndIp, Model.GetBackEndPort]));
  FBackEndAdapter := TRestAdapter<IAQAPIClient>.Create();
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
