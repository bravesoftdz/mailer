unit Model;

interface

uses
  ConsumerConfig, ActiveQueueResponce, JsonSaver, System.Generics.Collections, ReceptionRequest;

type
  /// The model may be in one of the following statuses:
  /// 1. Ready - it is not executing any job
  /// 2. Occupied - it is executing a job
  TStatus = (Occupied, Ready);

type
  TConsumerModel = class(TObject)
  strict private
    /// <summary>A path to the config. file</summary>
    FConfigFilePath: String;
    FConfig: TConsumerConfig;
    FFileSaver: TJsonSaver;
    /// the current model status
    FStatus: TStatus;

  var
    procedure RequestAndExecute();
    procedure Consume(const Items: TObjectList<TReceptionRequest>);
    procedure SendMail(const Item: TReceptionRequest);

  public
    function GetPort(): Integer;
    procedure LoadConfigFromFile(const FilePath: String);
    /// <summary>Get the configuation of the server.</summary>
    function GetConfig(): TConsumerConfig;
    /// <summary>Send a subscription request to the data provider server notifications</summary>
    function Subscribe(): TActiveQueueResponce;
    /// <summary>Send a request to cancel the subscription from the data provider notifications</summary>
    function Unsubscribe(const Token: String): TActiveQueueResponce;
    /// <summary>Return true if given IP coincides with the provider IP specified in the consumer config file</summary>
    function IsProviderAuthorized(const IP: String): Boolean;
    /// <summary>Retrieve data from the provider</sumamry>
    procedure OnProviderStateUpdate();

    constructor Create();
    destructor Destroy(); override;

  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.JSON, MVCFramework.RESTAdapter,
  ActiveQueueAPI, SubscriptionData, IdSMTP, IdMessage, SendmailConfig;

{ TConsumerModel }

constructor TConsumerModel.Create;
begin
  FFileSaver := TJsonSaver.Create;
  FStatus := TStatus.Ready;
end;

destructor TConsumerModel.Destroy;
begin
  if FConfig <> nil then
    FConfig.DisposeOf;
  FFileSaver.DisposeOf;
  inherited;
end;

procedure TConsumerModel.Consume(const Items: TObjectList<TReceptionRequest>);
var
  item: TReceptionRequest;
begin
  for Item in Items do
  begin
    Sendmail(item);
  end;

end;

function TConsumerModel.GetConfig: TConsumerConfig;
begin
  if FConfig <> nil then
    Result := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIp, FConfig.ProviderPort, FConfig.SubscriptionStatus, FConfig.SubscriptionToken);
end;

function TConsumerModel.GetPort: Integer;
begin
  Result := FConfig.Port;
end;

function TConsumerModel.IsProviderAuthorized(const IP: String): Boolean;
begin
  Result := (FConfig <> nil) AND (FConfig.ProviderIP = IP);
end;

procedure TConsumerModel.LoadConfigFromFile(const FilePath: String);
var
  Content: String;
  Json: TJsonObject;
begin
  if not TFile.Exists(FilePath) then
    raise Exception.Create('Config file ' + FilePath + ' is not found.');
  FConfigFilePath := FilePath;
  Content := TFile.ReadAllText(FilePath);
  Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONObject;
  if FConfig <> nil then
    FConfig.DisposeOf;
  FConfig := TConsumerConfig.Create(Json);
  Json.DisposeOf;
end;

procedure TConsumerModel.OnProviderStateUpdate;
begin
  if FStatus = TStatus.Ready then
  begin
    FStatus := Occupied;
    RequestAndExecute();
  end;

end;

procedure TConsumerModel.RequestAndExecute;
var
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
  SubscriptionData: TSubscriptionData;
  ConfigNew: TConsumerConfig;
  Items: TObjectList<TReceptionRequest>;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  Items := Server.GetItems(5);
  Consume(Items);
  FStatus := TStatus.Ready;
end;

procedure TConsumerModel.SendMail(const Item: TReceptionRequest);
var
  Smtp: TIdSMTP;
  Msg: TIdMessage;
begin
  Msg := TIdMessage.Create(NIL);
  try
    with MSG.Recipients.Add do
    begin
      Name := Item.sender;
      Address := Item.recipto;
    end;
    MSG.BccList.Add.Address := Item.recipbcc;
    Msg.From.Name := TSendMailConfig.SENDER_NAME;
    Msg.From.Address := TSendMailConfig.MAIL_FROM;
    Msg.Body.Text := Item.text;
    Msg.Subject := Item.subject;
    Smtp := TIdSMTP.Create(NIL);
    try
      Smtp.Host := TSendMailConfig.HOST;
      Smtp.Port := TSendMailConfig.PORT;
      Smtp.Connect;
      try
        Smtp.Send(MSG);
      finally
        Smtp.Disconnect
      end
    finally
      Smtp.DisposeOf();
    end
  finally
    Msg.DisposeOf;
  end;
end;

function TConsumerModel.Subscribe: TActiveQueueResponce;
var
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
  SubscriptionData: TSubscriptionData;
  ConfigNew: TConsumerConfig;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  /// the first argument (correponding to an ip at which the consumer operates) gets
  /// ignored by the data provider server since the ip gets extracted from the http request
  /// that the consumer sends to the data provider.
  SubscriptionData := TSubscriptionData.Create('', '', FConfig.Port, '');
  Result := Server.Subscribe(SubscriptionData);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP, FConfig.ProviderPort, Result.Status, Result.Token);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;
  Server := nil;
  Adapter := nil;
end;

function TConsumerModel.Unsubscribe(const Token: String): TActiveQueueResponce;
var
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
  ConfigNew: TConsumerConfig;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  Result := Server.UnSubscribe(Token);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP, FConfig.ProviderPort, False, '');
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;
end;

end.
