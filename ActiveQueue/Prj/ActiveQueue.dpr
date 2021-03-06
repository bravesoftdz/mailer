program ActiveQueue;

{$APPTYPE CONSOLE}


uses
  System.SysUtils,
  MVCFramework.Logger,
  Winapi.Windows,
  Winapi.ShellAPI,
  ReqMulti,
  Web.WebReq,
  Web.WebBroker,
  IdHTTPWebBrokerBridge,
  AQController in '..\Src\AQController.pas',
  ActiveQueueModule in '..\Src\ActiveQueueModule.pas' {ActiveQueueModule: TWebModule},
  AQSubscriptionResponce in '..\Src\AQSubscriptionResponce.pas',
  ActiveQueueSettings in '..\Src\ActiveQueueSettings.pas',
  AQModel in '..\Src\AQModel.pas',
  System.IOUtils,
  System.JSON,
  ObjectsMappers,
  System.Generics.Collections,
  AQConfig in '..\Src\AQConfig.pas',
  SubscriptionOutcomeData in '..\Src\SubscriptionOutcomeData.pas',
  Consumer in '..\Src\Consumer.pas',
  ListenerProxyInterface in '..\Src\ListenerProxyInterface.pas',
  ConditionInterface in '..\Src\ConditionInterface.pas',
  TokenBasedCondition in '..\Src\TokenBasedCondition.pas',
  JsonSaver in '..\Src\JsonSaver.pas',
  JsonableInterface in '..\Src\JsonableInterface.pas',
  CliParam in '..\..\Cli\CliParam.pas',
  CliUsage in '..\..\Cli\CliUsage.pas',
  Attachment in '..\..\EmailTemplate\Attachment.pas',
  ActiveQueueEntry in '..\Src\ActiveQueueEntry.pas',
  ServerConfig in '..\..\Config\ServerConfig.pas',
  AQConfigBuilder in '..\Src\AQConfigBuilder.pas',
  Client,
  AQSubscriptionEntry in '..\Src\AQSubscriptionEntry.pas',
  AQResponce in '..\Src\AQResponce.pas',
  RequestSaverFactory in '..\..\Storage\RequestSaverFactory.pas',
  RepositoryConfig,
  RequestToFileSystemStorage in '..\..\Storage\RequestToFileSystemStorage.pas';

{$R *.res}


const
  SWITCH_ORIGIN_CONFIG = 'c';
  SWITCH_TARGET_CONFIG = 't';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Active Queue Server';
  DEFAULT_COLOR = 7;
  HIGHLIGHT_COLOR = 10;
  APP_COLOR = 14;
  WARNING_COLOR = 12;

var
  OriginConfig, TargetConfig, QueueFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TAQConfig;
  ConfigImm: TAQConfigImmutable;
  CliParams: TArray<TCliParam>;
  ParamUsage: TCliUsage;
  ParamValues: TDictionary<String, String>;

procedure RunServer(const Config: TAQConfigImmutable; const TargetConfig: String);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  Clients: TObjectList<TClient>;
  Client: TClient;
  APort: Integer;
  Counter: Integer;
  Consumer: TConsumer;
  Consumers: TObjectList<TConsumer>;
  ConsumerWhiteList: String;
  I, L, S: Integer;
  InfoString: String;
  RepositoryParams: TArray<TPair<String, String>>;
  PendingRequests: TDictionary<String, TActiveQueueEntry>;
  RequestID: String;

begin
  TController.SetConfig(Config, TargetConfig);
  APort := TController.GetPort();
  InfoString := Format('%s:%d', [PROGRAM_NAME, APort]);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), APP_COLOR);
  Writeln('');
  Writeln('  ' + InfoString);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  SetConsoleTitle(pwidechar(InfoString));

  Clients := TController.GetClients;
  L := Clients.Count;
  if (L = 0) then
  begin
    Writeln('No clients are specified in the configuration file. No one will succeed to enqueue the data.');
  end
  else
  begin
    Writeln(L.toString + ' clients are found:');
    for Client in Clients do
    begin
      Write('ip: ');
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
      Write(Format('%15s', [Client.IP]));
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
      Writeln(', token: (not shown)');
    end;
  end;
  Clients.Clear;
  Clients.DisposeOf;

  ConsumerWhiteList := TController.GetConsumerIPWhitelist;
  if ConsumerWhiteList = '' then
  begin
    Writeln('The white list of consumer ips is empty. No one will be able to subscribe to the service. ')
  end
  else
    Writeln('White list of consumer ips: ' + ConsumerWhiteList);

  Consumers := TController.GetConsumers();
  L := Consumers.Count;
  Counter := 1;
  if L = 0 then
    Writeln('No consumers are found in the config file.')
  else
  begin
    Writeln(L.ToString + ' consumer(s) found:');
    for Consumer in Consumers do
    begin
      Writeln(Format('%3d) ip: %15s, port: %d, category: %10s, token: (not shown)', [Counter, Consumer.IP, Consumer.Port, Consumer.Category]));
      Counter := Counter + 1;
    end;
  end;
  Consumers.Clear;
  Consumers.DisposeOf;

  RepositoryParams := TController.GetRepositoryParams;
  if RepositoryParams <> nil then
  begin
    S := Length(RepositoryParams);
    Writeln(sLineBreak + 'Repository summary');
    for I := 0 to S - 1 do
    begin
      Write(Format('%d) %s: ', [I + 1, RepositoryParams[I].Key]));
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
      Writeln(RepositoryParams[I].Value);
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
    end;
    SetLength(RepositoryParams, 0);
    Writeln('');
  end
  else
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
    Writeln('No repository configuration is found.');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  end;

  PendingRequests := TController.GetPendingRequests();
  if PendingRequests.Count = 0 then
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
    Writeln('No pending requests are found.');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  end
  else
  begin
    Writeln(Format('%d pending request(s) found.', [PendingRequests.Count]));
    for RequestID in PendingRequests.Keys do
    begin
      Writeln(Format('origin: %s, category: %s, id: %s', [PendingRequests[RequestID].Origin, PendingRequests[RequestID].Category, RequestID]));
      PendingRequests[RequestID] := nil;
    end;
    PendingRequests.Clear;
    PendingRequests.DisposeOf;
  end;

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    LServer.Active := True;
    LogI(Format('Server started on port %d', [APort]));
    LServer.MaxConnections := 0;
    LServer.ListenQueue := 200;
    Writeln('Press ESC to stop the server');
    LHandle := GetStdHandle(STD_INPUT_HANDLE);
    while True do
    begin
      Win32Check(ReadConsoleInput(LHandle, LInputRecord, 1, LEvent));
      if (LInputRecord.EventType = KEY_EVENT) and
        LInputRecord.Event.KeyEvent.bKeyDown and
        (LInputRecord.Event.KeyEvent.wVirtualKeyCode = VK_ESCAPE) then
        break;

    end;
  finally
    LServer.Free;
  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  CliParams := [TCliParam.Create(SWITCH_ORIGIN_CONFIG, 'path', 'path to a file to load the configuration', True),
    TCliParam.Create(SWITCH_TARGET_CONFIG, 'path', 'path to a file to save the configuration', True)];
  ParamUsage := TCliUsage.Create(ExtractFileName(paramstr(0)), CliParams);
  try
    try
      ParamValues := ParamUsage.Parse();
      OriginConfig := ParamValues[SWITCH_ORIGIN_CONFIG];
      TargetConfig := ParamValues[SWITCH_TARGET_CONFIG];
      if Not(TFile.Exists(OriginConfig)) then
      begin
        Writeln('Error: config file ' + OriginConfig + 'not found.');
        Exit();
      end;
      try
        FileContent := TFile.ReadAllText(OriginConfig);
        JsonConfig := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FileContent), 0) as TJSONObject;
      except
        on E: Exception do
        begin
          Writeln(E.Message);
          Exit();
        end;
      end;
      if JsonConfig <> nil then
      begin
        try
          Config := Mapper.JSONObjectToObject<TAQConfig>(JsonConfig);
          ConfigImm := TAQConfigImmutable.Create(Config);
          if ConfigImm <> nil then
          begin
            if WebRequestHandler <> nil then
              WebRequestHandler.WebModuleClass := WebModuleClass;
            WebRequestHandlerProc.MaxConnections := 1024;
            RunServer(ConfigImm, TargetConfig);
          end
          else
            Writeln('No config is created. Failed to start the service.');
        finally
          JsonConfig.DisposeOf;
          Config.DisposeOf;
        end;
      end;

    except
      on E: Exception do
      begin
        Writeln(E.Message);
        Writeln(ParamUsage.Text);
      end;
    end;
  finally
    if ParamValues <> nil then
    begin
      ParamValues.Clear;
      ParamValues.DisposeOf;
    end;
    if ConfigImm <> nil then
      ConfigImm.DisposeOf;
    ParamUsage.DisposeOf;
    CliParams[0].DisposeOf();
    CliParams[1].DisposeOf();
    CliParams[2].DisposeOf();
    SetLength(CliParams, 0);
  end;

end.
