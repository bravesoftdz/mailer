unit AQController;

interface

uses
  MVCFramework, MVCFramework.Commons, AQModel, ActiveQueueEntry, ObjectsMappers,
  System.Generics.Collections, Consumer, AQConfig, System.JSON, Client,
  RequestSaverFactory, RepositoryConfig;

type

  [MVCPath('/')]
  TController = class(TMVCController)

  strict private
  const
    TAG = 'Active Queue';

  class var
    Model: TActiveQueueModel;
    FRequestSaverFactory: TRequestSaverFactory<TActiveQueueEntry>;
    FConsumerSaverFactory: TRequestSaverFactory<TConsumer>;

    /// enqueue the requests and persist the queue in case of success
    class function EnqueueAndPersist(const IP: String; const Items: TObjectList<TActiveQueueEntry>): Boolean;

    /// convert json array into a list
    class function JSonArrayToObjectList(const items: TJsonArray): TObjectList<TActiveQueueEntry>;
  public
    class function GetConsumers(): TObjectList<TConsumer>;

    /// Set the state of the Active Queue server.
    // class procedure SetState(const FilePath: String; const Config: TAQConfig);

    /// Read the given file and try to construct a TAQConfig instance. Then, this instance is
    /// passed to the SetState method.
    class procedure SetConfig(const Config: TAQConfigImmutable; const TargetConfig: String);

    /// <summary>Load queues from given file. The file might not exist, the argument is used as a file name
    /// to save the queues. The file content is supposed to be a json string of array of TActiveQueueEntry instances.</summary>
    class procedure LoadQueuesFromFile(const FilePath: String);

    /// <summary> Get the list clients </summary>
    class function GetClients(): TObjectList<TClient>;

    /// <summary>Return the whitelist of the consumer ips</summary>
    class function GetConsumerIPWhitelist(): String;

    /// <summary> Get the white list of providers' ips: requests to enqueue the data coming from only these ips
    /// are to be taken in consideration </summary>
    class function GetProvidersIPs(): TArray<String>;

    /// <summary> Get port number to which this service is bound. It is defined in the configuration file.</summary>
    class function GetPort(): Integer;

    /// <summary>Get config of the repository that is responsable for saving incoming requests</summary>
    class function GetRepositoryParams: TArray<TPair<String, String>>;

    /// <summary> Initialize the model. Since this controller is added in a static manner,
    /// I have to create a static method that instantiate a static reference  corresponding to the model
    /// </summary>
    class procedure Setup();

    /// <summary> Release the reference to the model instantiated during the initialization
    /// </summary>
    class procedure Teardown();

    /// request a subscription to the ActiveQueue events
    /// The body of the request must contain a TSubscriptionData instance.
    /// As a reponce, a TActiveQueueResponce instance is returned.
    /// In case of success, the reponce contains a unique token that will
    /// be assigned to this subscription
    [MVCPath('/subscribe')]
    [MVCHTTPMethod([httpPUT])]
    procedure Subscribe(const Context: TWebContext);

    /// request a cancellation of the subscription to the ActiveQueue events
    [MVCPath('/unsubscribe/($token)')]
    [MVCHTTPMethod([httpPUT])]
    procedure Unsubscribe(const Context: TWebContext);

    /// request given number of items from the ActiveQueue.
    [MVCPath('/items/get/($token)/($n)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetItems(const Context: TWebContext);

    /// add items to the ActiveQueue.
    [MVCPath('/items/post')]
    [MVCHTTPMethod([httpPOST])]
    procedure PostItems(const Context: TWebContext);

    /// add items to the ActiveQueue.
    [MVCPath('/item/post')]
    [MVCHTTPMethod([httpPOST])]
    procedure PostItem(const Context: TWebContext);

    /// cancel items from the ActiveQueue.
    [MVCPath('/items/cancel')]
    [MVCHTTPMethod([httpPUT])]
    procedure CancelItems(const Context: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, AQSubscriptionResponce, AQSubscriptionEntry, RequestStorageInterface,
  RequestToFileSystemStorage, System.SysUtils, ConditionInterface, TokenBasedCondition, System.IOUtils,
  AQResponce, System.Classes;

class function TController.GetClients: TObjectList<TClient>;
begin
  Result := Model.Clients
end;

class function TController.GetConsumerIPWhitelist: String;
begin
  Result := Model.ConsumerIPWhitelist;
end;

class function TController.GetPort: Integer;
begin
  Result := Model.Port;
end;

class function TController.GetProvidersIPs: TArray<String>;
begin
  if Assigned(Model) then
  begin
    Result := Model.GetProvidersIPs()
  end
  else
  begin
    Result := TArray<String>.Create();
    SetLength(Result, 0);
  end;
end;

class function TController.GetRepositoryParams: TArray<TPair<String, String>>;
begin
  Result := Model.RequestRepositoryParams;
end;

class function TController.JSonArrayToObjectList(
  const items: TJsonArray): TObjectList<TActiveQueueEntry>;
begin

end;

class procedure TController.LoadQueuesFromFile(const FilePath: String);
var
  Content: String;
  Json: TJsonArray;
  Requests: TObjectList<TActiveQueueEntry>;
begin
  Model.SetQueuePath(Filepath);
  if TFile.Exists(FilePath) then
  begin
    Content := TFile.ReadAllText(FilePath);
    try
      Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONArray;
      if Json <> nil then
      begin
        Requests := JSonArrayToObjectList(Json);
        // Model.SetQueue(FilePath, Requests);
      end;

    finally

    end;

  end;

end;

class procedure TController.SetConfig(const Config: TAQConfigImmutable; const TargetConfig: String);
begin
  Model.Config := Config;
  Model.TargetConfigPath := TargetConfig;
end;

procedure TController.CancelItems(const Context: TWebContext);
var
  Ip: String;
  jo: TJsonObject;
  Condition: ICondition;
begin
  IP := Context.Request.ClientIP;
  jo := Context.Request.BodyAsJSONObject;
  if (Assigned(jo)) then
  begin
    try
      Condition := Mapper.JSONObjectToObject<TTokenBasedCondition>(jo);
      Model.Cancel(IP, Condition);
    except
      on e: Exception do
        Condition := nil;
    end;
  end;

end;

class function TController.EnqueueAndPersist(const IP: String;
  const Items: TObjectList<TActiveQueueEntry>): Boolean;
begin
  // Model.Persist(Items);
  // Result := Model.Enqueue(IP, Items);
end;

procedure TController.GetItems(const Context: TWebContext);
var
  Ip: String;
  EntriesAsSingleBlock: TActiveQueueEntries;
  Items: TObjectList<TActiveQueueEntry>;
  QtyString: String;
  Qty: Integer;
  Token: String;
begin
  QtyString := Context.Request.Params['n'].Trim();
  Token := Context.Request.Params['token'].Trim();
  if (QtyString <> '') then
  begin
    try
      Qty := QtyString.ToInteger;
    except
      on E: Exception do
        Qty := 0;
    end;
    if Qty > 0 then
    begin
      ip := Context.Request.ClientIP;
      Items := Model.GetItems(Ip, Token, Qty);
      EntriesAsSingleBlock := TActiveQueueEntries.Create(Items);
      Items.Clear;
      Items.DisposeOf;

      Writeln('AQ controller: rendering ' + EntriesAsSingleBlock.Items.Count.ToString + ' items');
      Render(EntriesAsSingleBlock);
    end;

  end;

end;

class function TController.GetConsumers: TObjectList<TConsumer>;
begin
  Result := Model.GetConsumers()
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

procedure TController.PostItem(const Context: TWebContext);
var
  item: TActiveQueueEntry;
  Outcome: Boolean;
  Wrapper: TObjectList<TActiveQueueEntry>;
  Responce: TAQResponce;
  IP: String;
begin
  Writeln('Posting an item.');
  if Context.Request.ThereIsRequestBody then
  begin
    try
      item := Context.Request.BodyAs<TActiveQueueEntry>;
      IP := Context.Request.ClientIP;
      wrapper := TObjectList<TActiveQueueEntry>.Create();
      wrapper.add(item);
      Outcome := EnqueueAndPersist(IP, wrapper);
    except
      on E: Exception do
        Outcome := False;
    end;
  end
  else
    Outcome := False;
  Responce := TAQResponce.Create(OutCome, '');
  Render(Responce);
end;

procedure TController.PostItems(const Context: TWebContext);
var
  Entries: TActiveQueueEntries;
  Outcome: TAQResponce;
  IP: String;
  Status: Boolean;
  Ids: TDictionary<String, TActiveQueueEntry>;
begin
  IP := Context.Request.ClientIP;
  Outcome := nil;
  if not(Context.Request.ThereIsRequestBody) then
  begin
    Outcome := TAQResponce.Create(False, TAQResponceMessages.BODY_MISSING);
  end
  else
  begin
    try
      Entries := Context.Request.BodyAs<TActiveQueueEntries>;
    except
      on E: Exception do
      begin
        Outcome := TAQResponce.Create(False, Format(TAQResponceMessages.ERROR_CAST_REPORT, [E.Message]));
      end;
    end;
  end;
  if Outcome = nil then
  begin
    try
      Ids := Model.PersistRequests(Entries.Items);
    except
      on E: Exception do
      begin
        Outcome := TAQResponce.Create(False, Format(TAQResponceMessages.ERROR_PERSIST_REPORT, [E.Message]));
      end;
    end;
  end;
  if Outcome = nil then
  begin
    try
      Status := Model.Enqueue(IP, Ids);
    except
      on E: Exception do
      begin
        Outcome := TAQResponce.Create(False, Format(TAQResponceMessages.ERROR_ENQUEUE_REPORT, [E.Message]));
      end;
    end;
  end;
  if Outcome = nil then
  begin
    if Status then
      Outcome := TAQResponce.Create(True, TAQResponceMessages.SUCCESS)
    else
      Outcome := TAQResponce.Create(False, TAQResponceMessages.FAILURE);
  end;
  /// clean up
  if Entries <> nil then
    Entries.DisposeOf;
  if Ids <> nil then
  begin
    Ids.Clear;
    Ids.DisposeOf;
  end;

  Render(Outcome);
end;

class procedure TController.Setup;
begin
  FRequestSaverFactory := TRequestSaverFactory<TActiveQueueEntry>.Create();
  Model := TActiveQueueModel.Create(FRequestSaverFactory);
end;

procedure TController.Subscribe(const Context: TWebContext);
var
  responce: TAQSubscriptionResponce;
  SubscriptionData: TAQSubscriptionEntry;
  Ip: String;
  jo: TJsonObject;
begin
  ip := Context.Request.ClientIP;
  if Context.Request.ThereIsRequestBody then
  begin
    jo := Context.Request.BodyAsJSONObject;
  end
  else
    jo := nil;
  if jo <> nil then
  begin
    try
      SubscriptionData := Mapper.JSONObjectToObject<TAQSubscriptionEntry>(jo);
    except
      on e: Exception do
        SubscriptionData := nil;
    end;
  end;
  Responce := Model.AddConsumer(IP, SubscriptionData);

  if Responce.status then
    Model.PersistState();
  if SubscriptionData <> nil then
    SubscriptionData.DisposeOf;

  Render(responce);
end;

class
  procedure TController.Teardown;
begin
  Writeln('Tear down the controller');
  Model.DisposeOf;
end;

procedure TController.Unsubscribe(const Context: TWebContext);
var
  responce: TAQSubscriptionResponce;
  Ip, Token: String;
begin
  Token := Context.Request.Params['token'];
  Ip := Context.Request.ClientIP;
  responce := Model.CancelConsumer(ip, token);
  if Responce.status then
    Model.PersistState();
  Render(responce);
end;

initialization

TController.Setup;

finalization

TController.Teardown;

end.
