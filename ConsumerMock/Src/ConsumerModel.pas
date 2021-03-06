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
    FConfig: TConsumerConfig;
    FFileSaver: TJsonSaver;
    /// the current model status
    FStatus: TStatus;

    /// a dumb object to manage thread-safe access to FStatus variable
    FStatusLock: TObject;
    /// a dumb object to make subscribe/unsubscribe requests single-threaded
    FSubscriptionLock: TObject;

    /// a flag whether a request to subscribe/unsubscribe has been already been sent and its responce
    /// is being awaited
    FSubscriptionRequestIsOn: Boolean;

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
    procedure UpdateConfigToken(const Token: String);

  public

    procedure SetConfig(const Config: TConsumerConfig; const TargetConfigFileName: String);
    /// <summary>Get the configuation of the server.</summary>
    function GetConfig(): TConsumerConfig;
    /// <summary>Send a subscribe request to the data provider.
    /// The method first checks whether there is an active subscribe/unsubscribe request. If there
    /// is such a request, this one is ignored. If there is no such a request, there starts a new thread
    /// to request a subscription.</summary>
    procedure Subscribe();
    /// <summary>Send an unsubscribe request to the data provider.
    /// The method first checks whether there is an active subscribe/unsubscribe request. If there
    /// is such a request, this one is ignored. If there is no such a request, there starts a new thread
    /// to request a cancellation of subscription.</summary>
    procedure Unsubscribe();
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
  FStatus := TStatus.Ready;
  FStatusLock := TObject.Create;
  FSubscriptionLock := TObject.Create;
  FSubscriptionRequestIsOn := False;
end;

destructor TConsumerModel.Destroy;
begin
  FStatusLock.DisposeOf;
  FSubscriptionLock.DisposeOf;
  if FConfig <> nil then
    FConfig.DisposeOf;
  if FFileSaver <> nil then
    FFileSaver.DisposeOf;
  Fserver := nil;
  FAdapter := nil;
  inherited;
end;

procedure TConsumerModel.Consume(const Items: TObjectList<TActiveQueueEntry>);
var
  item: TActiveQueueEntry;
  Counter: Integer;
begin
  Counter := 1;
  for Item in Items do
  begin
    Writeln(Format('Sending item %d', [Counter]));
    Sendmail(item);
    Counter := Counter + 1;
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
const
  TAG = 'TConsumerModel.RequestAndExecute';
var
  SubscriptionData: TAQSubscriptionEntry;
  ConfigNew: TConsumerConfig;
  Items: TActiveQueueEntries;
  S: Integer;
begin
  Writeln('Request data from the data provider', TAG);
  try
    Items := FServer.GetItems(FConfig.SubscriptionToken, FConfig.BlockSize);
    if Items = nil then
    begin
      Writeln('Received null from the server.', TAG);
      S := 0;
    end
    else
    begin
      S := Items.Items.Count;
      Writeln('Received ' + S.ToString + ' item(s) from the server', TAG);
    end;

  except
    on E: Exception do
    begin
      Writeln('Error while getting items from the data provider: ' + E.Message, TAG);
      S := 0;
    end;
  end;
  Writeln('Received ' + S.toString() + ' task(s).', TAG);
  if S > 0 then
  begin
    Consume(Items.Items);
  end;
  if Items <> nil then
    Items.DisposeOf;
  if S > 0 then
  begin
    Writeln('Start over...');
    RequestAndExecute(); // start recursively
  end
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
    if jo <> nil then
      jo.DisposeOf;
  end;
  if Data <> nil then
  begin
    Msg := TIdMessage.Create(NIL);
    try
      // MSG.Recipients.Add.Name := Data.From;
      // MSG.Recipients.Add.Address := Data.RecipTo;
      with MSG.Recipients.Add do
      begin
        Name := Data.From;
        Address := Data.RecipTo;
      end;
      // MSG.BccList.Add.Address := Item.recipbcc;
      // Msg.From.Name := TSendMailConfig.SENDER_NAME;
      Msg.From.Address := Data.from;
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
        Smtp.Host := TSendMailConfig.HOST;
        Smtp.Port := TSendMailConfig.Port;
        Smtp.Connect;
        try
          try
            Smtp.Send(MSG);
            Writeln('Message has been sent.');
          except
            on E: Exception do
            begin
              Writeln('Failed to send: ' + E.Message);
            end;

          end;

        finally
          Writeln('Trying to disconnect');
          Smtp.Disconnect
        end
      finally
        Smtp.DisposeOf();
      end
    finally
      Msg.DisposeOf;
      Data.DisposeOf;
    end;
  end;
  Writeln('Message sent');
end;

procedure TConsumerModel.SetConfig(const Config: TConsumerConfig; const TargetConfigFileName: String);
begin
  if FConfig <> nil then
  begin
    raise Exception.Create('It is not allowed to re-set the configuration at runtime. Turn the server off and change the configuration file.');
  end;
  FConfig := Config.Clone();
  FFileSaver := TJsonSaver.Create(TargetConfigFileName);
  Start();
end;

procedure TConsumerModel.Start;
begin
  FAdapter := TRestAdapter<IAQAPIConsumer>.Create();
  FServer := FAdapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  if not(FConfig.IsSubscribed) then
    Subscribe();

end;

procedure TConsumerModel.Subscribe;
begin
  TMonitor.Enter(FSubscriptionLock);
  try
    if FSubscriptionRequestIsOn then
    begin
      Writeln('Try to subscribe later... A previous request to subscribe/unsubscribe has to finish yet');
    end
    else
    begin
      FSubscriptionRequestIsOn := True;
      TThread.CreateAnonymousThread(
        procedure
        var
          Responce: TAQSubscriptionResponce;
          SubscriptionData: TAQSubscriptionEntry;
        begin
          Writeln('I am busy now.');
          try
            SubscriptionData := TAQSubscriptionEntry.Create(FConfig.Port, FConfig.Category);
            Responce := FServer.Subscribe(SubscriptionData);
            if Responce <> nil then
            begin
              if Responce.status then
              begin
                Writeln('Responce received: subscribed now');
                UpdateConfigToken(Responce.Token);
                RequestAndElaborate();
              end
              else
              begin
                Writeln('Responce received: failed to subscribe (' + Responce.Msg + ').');
              end;
              Responce.DisposeOf;
            end
            else
              Writeln('No responce received...');
          finally
            FSubscriptionRequestIsOn := False;
            Writeln('I am ready now.');
          end;
        end).start;
    end;

  finally
    TMonitor.Exit(FSubscriptionLock);
  end;
end;

procedure TConsumerModel.Unsubscribe();
var
  Status: Boolean;
begin
  TMonitor.Enter(FSubscriptionLock);
  try
    if FSubscriptionRequestIsOn then
    begin
      Writeln('Try to unsubscribe later... A previous request to subscribe/unsubscribe has to finish yet');
    end
    else
    begin
      FSubscriptionRequestIsOn := True;
      Status := SubscriptionStatus;
      TThread.CreateAnonymousThread(
        procedure
        var
          Responce: TAQSubscriptionResponce;
        begin
          Writeln('I am busy now.');
          try
            Responce := FServer.UnSubscribe(FConfig.SubscriptionToken);
            if Responce <> nil then
            begin
              Writeln('Responce received');
              if Responce.status then
              begin
                Writeln('Responce status: unsubscribed now');
                UpdateConfigToken('');
              end
              else if (Responce.Msg = TAQSubscriptionResponceMessages.NOT_SUBSCRIBED) then
              begin
                if Status then
                begin
                  Writeln('A mismatch in subscription is found.');
                  UpdateConfigToken('');
                end
                else
                  Writeln('It is confirmed that you are not subscribed');
              end
              else
                Writeln('A mismatch in subscription is found, but not this message is expected: ' + Responce.Msg);
              Responce.DisposeOf;
            end;
          finally
            FSubscriptionRequestIsOn := False;
            Writeln('I am ready now.');
          end;
        end).start;
    end;

  finally
    TMonitor.Exit(FSubscriptionLock);
  end;
end;

procedure TConsumerModel.UpdateConfigToken(const Token: String);
var
  ConfigNew: TConsumerConfig;
begin
  Writeln('Update config...');
  if FConfig <> nil then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP,
      FConfig.ProviderPort, Token <> '', Token, FConfig.BlockSize, FConfig.Category);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
  end;
  try
    FFileSaver.Save(FConfig);
  except
    on E: Exception do
      Writeln('An error occurred while saving updated config: ' + E.Message);
  end;

end;

end.
