unit Controller;

interface

uses
  MVCFramework, MVCFramework.Commons, Model, ReceptionRequest, ObjectsMappers,
  System.Generics.Collections, ListenerInfo, AQConfig;

type

  [MVCPath('/')]
  TController = class(TMVCController)

  strict private
    class var Model: TActiveQueueModel;

    /// enqueue the requests and persist the queue in case of success
    class function EnqueueAndPersist(const IP: String; const Items: TObjectList<TReceptionRequest>): Boolean;
  public
    class function GetListeners(): TObjectList<TListenerInfo>;

    /// Set the state of the Active Queue server.
    class procedure SetState(const FilePath: String; const Config: TAQConfig);

    /// Read the given file and try to construct a TAQConfig instance. Then, this insytance is
    /// passed to the SetState method.
    class procedure LoadStateFromFile(const FilePath: String);

    /// <summary> Get the white list of listeners' ips: requests coming from only these ips
    /// are to be taken in consideration </summary>
    class function GetListenersIPs(): TArray<String>;

    /// <summary> Get the white list of providers' ips: requests to enqueue the data coming from only these ips
    /// are to be taken in consideration </summary>
    class function GetProvidersIPs(): TArray<String>;

    /// <summary> Get port number to which this service is bound. It is defined in the configuration file. </summary>
    class function GetPort(): Integer;

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
    procedure unsubscribe(const Context: TWebContext);

    /// request given number of items from the ActiveQueue.
    [MVCPath('/items/get/($n)')]
    [MVCHTTPMethod([httpGET])]
    [MVCProduces('application/json')]
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
  MVCFramework.Logger, ActiveQueueResponce, System.JSON, SubscriptionData,
  System.SysUtils, ConditionInterface, TokenBasedCondition, System.IOUtils;

class function TController.GetListenersIPs: TArray<String>;
begin
  if Assigned(Model) then
  begin
    Result := Model.GetListenersIPs()
  end
  else
  begin
    Result := TArray<String>.Create();
    SetLength(Result, 0);
  end;
end;

class function TController.GetPort: Integer;
begin
  if Model = nil then
    raise Exception.Create('The model has not been initialized yet.');
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

class procedure TController.LoadStateFromFile(const FilePath: String);
var
  Content: String;
  Json: TJsonObject;
  Config: TAQConfig;
begin
  if Not(TFile.Exists(FilePath)) then
    raise Exception.Create('Error: config file ' + FilePath + 'not found.');
  try
    Content := TFile.ReadAllText(FilePath);
    Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONObject;
  except
    on E: Exception do
    begin
      raise Exception.Create('Error: failed to parse the content of file "' + FilePath + '" into a json:' + sLineBreak + E.Message);
    end;
  end;
  if Assigned(Json) then
  begin
    Config := Mapper.JSONObjectToObject<TAQConfig>(Json);
  end;
  SetState(FilePath, Config);
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
  const Items: TObjectList<TReceptionRequest>): Boolean;
begin
  Result := Model.Enqueue(IP, Items);
  if Result then
    Model.PersistQueue();
end;

procedure TController.GetItems(const Context: TWebContext);
var
  Ip: String;
  Items: TObjectList<TReceptionRequest>;
  N: Integer;
begin
  N := Context.Request.Params['n'].ToInteger;
  ip := Context.Request.ClientIP;
  Items := Model.GetItems(Ip, N);
  Render<TReceptionRequest>(Items);
end;

class function TController.GetListeners: TObjectList<TListenerInfo>;
begin
  if Assigned(Model) then
    Result := Model.GetListeners()
  else
    Result := TObjectList<TListenerInfo>.Create();

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
  item: TReceptionRequest;
  Outcome: Boolean;
  Wrapper: TObjectList<TReceptionRequest>;
  IP: String;
begin
  if Context.Request.ThereIsRequestBody then
  begin
    try
      item := Context.Request.BodyAs<TReceptionRequest>;
      IP := Context.Request.ClientIP;
      wrapper := TObjectList<TReceptionRequest>.Create();
      wrapper.add(item);
      Outcome := EnqueueAndPersist(IP, wrapper);
    except
      on E: Exception do
        Outcome := False;
    end;
  end
  else
    Outcome := False;
  Render(Outcome.ToString(False));
end;

procedure TController.PostItems(const Context: TWebContext);
var
  items: TObjectList<TReceptionRequest>;
  Outcome: Boolean;
  IP: String;
begin
  if Context.Request.ThereIsRequestBody then
  begin
    try
      items := Context.Request.BodyAsListOf<TReceptionRequest>;
      IP := Context.Request.ClientIP;
      Outcome := EnqueueAndPersist(IP, Items);
    except
      on E: Exception do
        Outcome := False;
    end;
  end
  else
  begin
    Outcome := False;
  end;
  Render(Outcome.ToString(False));
end;

class procedure TController.SetState(const FilePath: String; const Config: TAQConfig);
begin
  if Model <> nil then
    Model.SetState(FilePath, Config);
end;

class procedure TController.Setup;
begin
  Writeln('Set up the controller');
  Model := TActiveQueueModel.Create();
end;

procedure TController.Subscribe(const Context: TWebContext);
var
  responce: TActiveQueueResponce;
  SubscriptionData: TSubscriptionData;
  Ip: String;
  jo: TJsonObject;
begin
  ip := Context.Request.ClientIP;
  jo := Context.Request.BodyAsJSONObject;
  if (Assigned(jo)) then
  begin
    try
      SubscriptionData := Mapper.JSONObjectToObject<TSubscriptionData>(jo);
      SubscriptionData.Ip := Ip;
    except
      on e: Exception do
        SubscriptionData := nil;
    end;
  end;
  Responce := Model.AddSubscription(SubscriptionData);
  if Responce.status then
    Model.UpdatePersistedState();

  Render(responce);
end;

class procedure TController.Teardown;
begin
  Writeln('Tear down the controller');
  Model.DisposeOf;
end;

procedure TController.unsubscribe(const Context: TWebContext);
var
  responce: TActiveQueueResponce;
  Ip, Token: String;
begin
  Token := Context.Request.Params['token'];
  Ip := Context.Request.ClientIP;
  responce := Model.CancelSubscription(ip, token);
  if Responce.status then
    Model.UpdatePersistedState();
  Render(responce);
end;

initialization

TController.Setup;

finalization

TController.Teardown;

end.
