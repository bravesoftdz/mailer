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
  System.Generics.Collections, AQResponce, Attachment, RequestStorageInterface,
  RequestToFileSystemStorage;

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
  IP, ID: String;
  Request: TDispatcherEntry;
  Entries: TObjectList<TActiveQueueEntry>;
  Responce: TDispatcherResponce;
  Wrapper: TActiveQueueEntries;
  BackEndResponce: TAQResponce;
  Attach: TAttachment;
  jo: TJsonObject;
begin
  IP := Context.Request.ClientIP;
  if Context.Request.ThereIsRequestBody then
  begin
    try
      Request := Context.Request.BodyAs<TDispatcherEntry>;
      Writeln('Received a request with ' + Request.Attachments.Count.ToString + ' attachment(s).');
      for Attach in Request.Attachments do
      begin
        Writeln('name: ' + Attach.Name);
        Writeln('content: ' + Attach.ContentAsString);
      end;
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.INVALID_BODY);
        Render(Responce);
        Exit();
      end;
    end;
  end
  else
  begin
    Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.MISSING_BODY);
    Render(Responce);
    Exit();
  end;

  if not(Model.isAuthorised(IP, Request.Token)) then
  begin
    Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.NOT_AUTHORISED);
    Render(Responce);
    Exit();
  end;
  try
    jo := Request.toJson();
    try
      ID := Model.Persist(jo);
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.PERSIST_EXCEPTION_REPORT, [E.Message]));
        Render(Responce);
        Exit();
      end;
    end;
  finally
    jo.DisposeOf;
  end;
  /// at this point, ID must be initialized
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
      begin
        Responce := TDispatcherResponce.Create(True, Format(TDispatcherResponceMessages.SUCCESS_REPORT, [Entries.Count]));
        Model.Delete(Id);
      end
      else
        Responce := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.FAILURE_REPORT, [BackEndResponce.Msg]))
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.EXCEPTION_REPORT, [E.Message]));
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

class procedure TDispatcherController.Setup;
begin
  Model := TModel.Create(TRequestToFileSystemStorage.Create('Dispatcher-storage/'));
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
