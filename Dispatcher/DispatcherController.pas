unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons, DispatcherModel, MVCFramework.RESTAdapter, AQAPIClient,
  ServerConfig, RepositoryConfig, RequestSaverFactory,
  System.Generics.Collections, DispatcherEntry;

type

  [MVCPath('/')]
  TDispatcherController = class(TMVCController)
  strict private
  class var
    Model: TModel;
    FBackEndProxy: IAQAPIClient;
    FBackEndAdapter: TRestAdapter<IAQAPIClient>;
    RequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>;
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
    class function GetPendingRequests(): TObjectList<TDispatcherEntry>;
    class function GetRepositoryParams(): TArray<TPair<String, String>>;

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, System.JSON, System.IOUtils, System.SysUtils,
  DispatcherConfig, DispatcherResponce, ActiveQueueEntry, AQResponce, Attachment, RequestStorageInterface,
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

class function TDispatcherController.GetPendingRequests: TObjectList<TDispatcherEntry>;
begin
  Result := Model.GetPendingRequests();
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

class function TDispatcherController.GetRepositoryParams: TArray<TPair<String, String>>;
begin
  Result := Model.GetRepositoryParams();
end;

procedure TDispatcherController.PutRequest(Context: TWebContext);
var
  IP, ID: String;
  Request: TDispatcherEntry;
  IdToEntries: TPair<String, TActiveQueueEntries>;
  Entries: TActiveQueueEntries;
  Responce: TDispatcherResponce;
  BackEndResponce: TAQResponce;
begin
  IP := Context.Request.ClientIP;
  Responce := nil;
  if Context.Request.ThereIsRequestBody then
  begin
    try
      Request := Context.Request.BodyAs<TDispatcherEntry>;
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.INVALID_BODY_REPORT, [E.Message]));
      end;
    end;
  end
  else
  begin
    Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.MISSING_BODY);
  end;

  if (Responce = nil) AND not(Model.isAuthorised(IP, Request.Token)) then
  begin
    Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.NOT_AUTHORISED);
  end;

  if Responce = nil then
  begin
    try
      IdToEntries := Model.PersistDispatchConvert(Request);

      /// decompose the pair immediately since afterwords you have no way to know whether it
      /// has been instantiated or not
      ID := IdToEntries.Key;
      Entries := IdToEntries.Value;

    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, E.Message);
      end;
    end;
  end;

  if Responce = nil then
  begin
    try
      BackEndResponce := FBackEndProxy.PostItems(Entries);
    except
      on E: Exception do
      begin
        Responce := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.EXCEPTION_REPORT, [E.Message]));
      end;
    end;
  end;

  if Responce = nil then
  begin
    if BackEndResponce = nil then
    begin
      Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.FAILURE_NO_BACKEND_RESPONSE)
    end
    else if BackEndResponce.status then
    begin
      Responce := TDispatcherResponce.Create(True, TDispatcherResponceMessages.SUCCESS);
      Model.Delete(Id);
    end
    else
      Responce := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.FAILURE_REPORT, [BackEndResponce.Msg]))
  end;

  /// clean up the objects that might have been created
  if Request <> nil then
    Request.DisposeOf;
  if Entries <> nil then
    Entries.DisposeOf;
  if BackEndResponce <> nil then
    BackEndResponce.DisposeOf;

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
  RequestSaverFactory := TRequestSaverFactory<TDispatcherEntry>.Create();
  Model := TModel.Create(RequestSaverfactory);
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
  RequestSaverFactory.DisposeOf();
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
