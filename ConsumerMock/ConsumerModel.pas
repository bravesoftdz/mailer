unit ConsumerModel;

interface

uses
  ConsumerConfig, ActiveQueueResponce, ActiveQueueEntry, JsonSaver,
  MVCFramework.RESTAdapter, AQAPIConsumer,
  System.Generics.Collections;

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

    FAdapter: TRestAdapter<IAQAPIConsumer>;
    FServer: IAQAPIConsumer;

  var
    procedure RequestAndExecute();
    procedure Consume(const Items: TObjectList<TActiveQueueEntry>);
    procedure SendMail(const Item: TActiveQueueEntry);

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

    procedure Start();

    constructor Create();
    destructor Destroy(); override;

  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.JSON, SubscriptionData, IdSMTP, IdMessage, SendmailConfig, ObjectsMappers;

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
  Fserver := nil;
  FAdapter := nil;
  inherited;
end;

procedure TConsumerModel.Consume(const Items: TObjectList<TActiveQueueEntry>);
var
  item: TActiveQueueEntry;
begin
  for Item in Items do
  begin
    Sendmail(item);
  end;

end;

function TConsumerModel.GetConfig: TConsumerConfig;
begin
  if FConfig <> nil then
    Result := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIp, FConfig.ProviderPort, FConfig.SubscriptionStatus, FConfig.SubscriptionToken, FConfig.BlockSize);
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
  FConfig := TConsumerConfig.CreateFromJson(Json);
  Json.DisposeOf;
end;

procedure TConsumerModel.OnProviderStateUpdate;
begin
  Writeln('Data provider state has been changed');
  if FStatus = TStatus.Ready then
  begin
    Writeln('Take care of requesting data...');
    FStatus := Occupied;
    try
      RequestAndExecute();
    finally
      FStatus := TStatus.Ready;
    end;
  end;
end;

procedure TConsumerModel.RequestAndExecute;
var
  SubscriptionData: TSubscriptionData;
  ConfigNew: TConsumerConfig;
  Items: TActiveQueueEntries;
begin
  Writeln('Request data from the data provider');
  try
    Items := FServer.GetItems(FConfig.SubscriptionToken, FConfig.BlockSize);
    if Items = nil then
      Writeln('Received null from the server...')
    else
      Writeln('Received ' + Items.Items.Count.ToString + ' item(s) from the server');
  except
    on E: Exception do
    begin
      Writeln('Error while getting items from the data provider');
      Writeln(E.Message);
    end;
  end;
  Writeln('Data received...');
  Consume(Items.Items);
end;

procedure TConsumerModel.SendMail(const Item: TActiveQueueEntry);
var
  Smtp: TIdSMTP;
  Msg: TIdMessage;
begin
  Writeln('Sending a message');
  if (Item = nil) then
  begin
    Writeln('Null item to send... Exiting.');
    Exit();
  end;
  Msg := TIdMessage.Create(NIL);
  try
    // MSG.Recipients.Add.Name := Item.sender;
    // MSG.Recipients.Add.Address := TSendMailConfig.MAIL_TO;
    with MSG.Recipients.Add do
    begin
      Name := ''; // Item.sender;
      Address := TSendMailConfig.MAIL_TO;
    end;
    Writeln('Adding address');

    // MSG.BccList.Add.Address := Item.recipbcc;
    // Msg.From.Name := TSendMailConfig.SENDER_NAME;
    Msg.From.Address := TSendMailConfig.MAIL_FROM;
    Msg.Body.Text := ''; // Item.text;
    Msg.Subject := ''; // Item.subject;
    Smtp := TIdSMTP.Create(NIL);
    try
      Writeln('Trying to connect');
      Smtp.Host := TSendMailConfig.HOST;
      Smtp.Port := TSendMailConfig.PORT;
      Smtp.Connect;
      try
        Smtp.Send(MSG);
        Writeln('Trying to send');
      finally
        Writeln('Trying to disconnect');
        Smtp.Disconnect
      end
    finally
      Smtp.DisposeOf();
    end
  finally
    Msg.DisposeOf;
  end;
  Writeln('Message sent');
end;

procedure TConsumerModel.Start;
begin
  FAdapter := TRestAdapter<IAQAPIConsumer>.Create();
  FServer := FAdapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
end;

function TConsumerModel.Subscribe: TActiveQueueResponce;
var
  SubscriptionData: TSubscriptionData;
  ConfigNew: TConsumerConfig;
begin
  /// the first argument (correponding to an ip at which the consumer operates) gets
  /// ignored by the data provider server since the ip gets extracted from the http request
  /// that the consumer sends to the data provider.
  SubscriptionData := TSubscriptionData.Create('', '', FConfig.Port, '');
  Result := FServer.Subscribe(SubscriptionData);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP,
      FConfig.ProviderPort, Result.Status, Result.Token, FConfig.BlockSize);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;
end;

function TConsumerModel.Unsubscribe(const Token: String): TActiveQueueResponce;
var
  ConfigNew: TConsumerConfig;
begin
  Result := FServer.UnSubscribe(Token);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP, FConfig.ProviderPort, False, '', FConfig.BlockSize);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;
end;

end.
