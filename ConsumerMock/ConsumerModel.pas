unit ConsumerModel;

interface

uses
  ConsumerConfig, AQSubscriptionResponce, ActiveQueueEntry, JsonSaver,
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

    /// a dumb object to manage thread-safe access to FStatus variable
    FStatusLock: TObject;

    FAdapter: TRestAdapter<IAQAPIConsumer>;
    FServer: IAQAPIConsumer;
    function GetBlockSize: Integer;
    function GetSubscriptionStatus: Boolean;
    function GetSubscriptionToken: String;
    function GetPort(): Integer;

  var
    procedure RequestAndExecute();
    procedure Consume(const Items: TObjectList<TActiveQueueEntry>);
    procedure SendMail(const Item: TActiveQueueEntry);
  private
    function GetCategory: String;

  public

    procedure SetConfig(const Config: TConsumerConfig; const TargetConfigFileName: String);
    /// <summary>Get the configuation of the server.</summary>
    function GetConfig(): TConsumerConfig;
    /// <summary>Send a subscription request to the data provider server notifications</summary>
    function Subscribe(): TAQSubscriptionResponce;
    /// <summary>Send a request to cancel the subscription from the data provider notifications</summary>
    function Unsubscribe(): TAQSubscriptionResponce;
    /// <summary>Return true if given IP coincides with the provider IP specified in the consumer config file</summary>
    function IsProviderAuthorized(const IP: String): Boolean;
    /// <summary>Retrieve data from the provider and elaborate it. The method turns FStatus into occupied
    /// one, launch a new thread that takes care of retrieving and elaborating data.
    /// FStatus gets updated in this thread. </sumamry>
    procedure RequestAndElaborate();

    property Port: Integer read GetPort;
    property BlockSize: Integer read GetBlockSize;
    property SubscriptionStatus: Boolean read GetSubscriptionStatus;
    property SubscriptionToken: String read GetSubscriptionToken;
    property Category: String read GetCategory;

    procedure Start();

    constructor Create();
    destructor Destroy(); override;

  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.JSON, AQSubscriptionEntry, IdSMTP, IdMessage, SendmailConfig, ObjectsMappers,
  SendDataTemplate, IdAttachment, IdAttachmentFile, Attachment, System.Classes;

{ TConsumerModel }

constructor TConsumerModel.Create;
begin
  FFileSaver := TJsonSaver.Create;
  FStatus := TStatus.Ready;
  FStatusLock := TObject.Create;
end;

destructor TConsumerModel.Destroy;
begin
  FStatusLock.DisposeOf;
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

function TConsumerModel.GetBlockSize: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.BlockSize
  else
    Result := -1;
end;

function TConsumerModel.GetCategory: String;
begin
  if FConfig <> nil then
    Result := FConfig.Category
  else
    Result := '';
end;

function TConsumerModel.GetConfig: TConsumerConfig;
begin
  if FConfig <> nil then
    Result := FConfig.Clone();
end;

function TConsumerModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port
  else
    Result := -1;
end;

function TConsumerModel.GetSubscriptionStatus: Boolean;
begin
  if FConfig <> nil then
    Result := FConfig.IsSubscribed
  else
    Result := False;
end;

function TConsumerModel.GetSubscriptionToken: String;
begin
  if FConfig <> nil then
    Result := FConfig.SubscriptionToken
  else
    Result := '';
end;

function TConsumerModel.IsProviderAuthorized(const IP: String): Boolean;
begin
  Result := (FConfig <> nil) AND (FConfig.ProviderIP = IP);
end;

procedure TConsumerModel.RequestAndElaborate;
begin
  TMonitor.Enter(FStatusLock);
  try
    if FStatus = TStatus.Ready then
    begin
      TThread.CreateAnonymousThread(
        procedure
        begin
          FStatus := Occupied;
          Writeln('I am busy now.');
          try
            RequestAndExecute();
          finally
            FStatus := TStatus.Ready;
            Writeln('I am ready now.');
          end;
        end).start;
    end
    else
      Writeln('I am busy hence I ignore this notification...');

  finally

    TMonitor.Exit(FStatusLock);
  end;
end;

procedure TConsumerModel.RequestAndExecute;
var
  SubscriptionData: TAQSubscriptionEntry;
  ConfigNew: TConsumerConfig;
  Items: TActiveQueueEntries;
  S: Integer;
begin
  Writeln('Request data from the data provider');
  try
    Items := FServer.GetItems(FConfig.SubscriptionToken, FConfig.BlockSize);
    if Items = nil then
    begin
      Writeln('Received null from the server...');
      S := 0;
    end
    else
    begin
      S := Items.Items.Count;
      Writeln('Received ' + S.ToString + ' item(s) from the server');
    end;

  except
    on E: Exception do
    begin
      Writeln('Error while getting items from the data provider: ' + E.Message);
      Writeln(E.Message);
      S := 0;
    end;
  end;
  Writeln('Received ' + S.toString() + ' tasks.');
  if S > 0 then
  begin
    Writeln('Start consuming received items...');
    Consume(Items.Items);
    Writeln('I finished consuming the items, ask some other tasks...');
    RequestAndExecute(); // start recursively
  end
  else
    Writeln('Ask no items since last time ' + S.ToString + ' items were received.');
end;

procedure TConsumerModel.SendMail(const Item: TActiveQueueEntry);
var
  Smtp: TIdSMTP;
  Msg: TIdMessage;
  Data: TSendDataTemplate;
  jo: TJsonObject;
  Attachment: TAttachment;
  AttachFile: TIdAttachmentFile;
  AStream: TStream;
begin
  Writeln('Sending a message');
  if (Item = nil) then
  begin
    Writeln('Null item to send... Exiting.');
    Exit();
  end;

  try
    jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Item.Body), 0) as TJSONObject;
    Data := Mapper.JSONObjectToObject<TSendDataTemplate>(jo);
  finally

  end;

  Msg := TIdMessage.Create(NIL);
  try
    // MSG.Recipients.Add.Name := Data.From;
    // MSG.Recipients.Add.Address := Data.RecipTo;
    with MSG.Recipients.Add do
    begin
      Name := Data.From;
      Address := Data.RecipTo;
    end;

    Writeln('Adding address');

    // MSG.BccList.Add.Address := Item.recipbcc;
    // Msg.From.Name := TSendMailConfig.SENDER_NAME;
    Msg.From.Address := TSendMailConfig.MAIL_FROM;
    Msg.Body.Text := Data.Text;
    Msg.Subject := Data.Subject;

    for Attachment in Data.attachment do
    begin
      AttachFile := TIdAttachmentFile.Create(msg.MessageParts, Attachment.Name);
      AttachFile.LoadFromStream(Attachment.Content);
    end;

    Smtp := TIdSMTP.Create(NIL);
    try
      Writeln('Trying to connect');
      Smtp.Host := Data.SmtpHost;
      Smtp.Port := Data.Port;
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

procedure TConsumerModel.SetConfig(const Config: TConsumerConfig; const TargetConfigFileName: String);
begin
  if FConfig <> nil then
  begin
    raise Exception.Create('It is not allowed to reset the configuration at runtime. Turn the server off and change the configuration file.');
  end;
  FConfig := Config.Clone();
  FConfigFilePath := TargetConfigFileName;
  Start();
end;

procedure TConsumerModel.Start;
begin
  FAdapter := TRestAdapter<IAQAPIConsumer>.Create();
  FServer := FAdapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  if not(FConfig.IsSubscribed) then
    Subscribe();

end;

function TConsumerModel.Subscribe: TAQSubscriptionResponce;
var
  SubscriptionData: TAQSubscriptionEntry;
  ConfigNew: TConsumerConfig;
begin
  /// the first argument (correponding to an ip at which the consumer operates) gets
  /// ignored by the data provider server since the ip gets extracted from the http request
  /// that the consumer sends to the data provider.
  SubscriptionData := TAQSubscriptionEntry.Create(FConfig.Port, FConfig.Category);
  Result := FServer.Subscribe(SubscriptionData);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP,
      FConfig.ProviderPort, Result.Status, Result.Token, FConfig.BlockSize, FConfig.Category);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;
end;

function TConsumerModel.Unsubscribe(): TAQSubscriptionResponce;
var
  ConfigNew: TConsumerConfig;
begin
  Result := FServer.UnSubscribe(FConfig.SubscriptionToken);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP, FConfig.ProviderPort, False, '', FConfig.BlockSize, FConfig.Category);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;
end;

end.
