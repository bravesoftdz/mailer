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
    RequestSaverFactory: TRequestSaverFactory<TDispatcherEntry>;

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
    class function GetPendingRequests(): TDictionary<String, TDispatcherEntry>;
    class function GetRepositoryParams(): TArray<TPair<String, String>>;

    /// <summary>Delegate to the model to elaborate pending requests (if any)</summary>
    class procedure ElaboratePendingRequests();

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
end;

class function TDispatcherController.GetBackEndIp: String;
begin
  Result := Model.GetBackEndIp();
end;

class function TDispatcherController.GetPendingRequests: TDictionary<String, TDispatcherEntry>;
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

class procedure TDispatcherController.ElaboratePendingRequests;
begin
  Model.ElaboratePendingRequests();
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
  Request := nil;
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

    if Request <> nil then
    begin
      try
        try
          Responce := Model.ElaborateSingleRequest(IP, Request);
        except
          on E: Exception do
          begin
            Responce := TDispatcherResponce.Create(False, E.Message);
          end;
        end;
      finally
        Request.DisposeOf;
      end;
    end
    else
      Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.EMPTY_BODY);
  end
  else
  begin
    Responce := TDispatcherResponce.Create(False, TDispatcherResponceMessages.MISSING_BODY);
  end;

  Render(Responce);
end;

procedure TDispatcherController.OnAfterAction(Context: TWebContext;
  const
  AActionName:
  string);
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

class procedure TDispatcherController.TearDown;
begin
  Model.DisposeOf;
  RequestSaverFactory.DisposeOf();

end;

initialization

TDispatcherController.Setup();

finalization

TDispatcherController.TearDown();

end.
