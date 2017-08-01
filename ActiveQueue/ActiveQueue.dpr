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
  AQController in 'AQController.pas',
  ActiveQueueModule in 'ActiveQueueModule.pas' {ActiveQueueModule: TWebModule},
  AQSubscriptionResponce in 'AQSubscriptionResponce.pas',
  ActiveQueueSettings in 'ActiveQueueSettings.pas',
  AQModel in 'AQModel.pas',
  System.IOUtils,
  System.JSON,
  ObjectsMappers,
  System.Generics.Collections,
  AQConfig in 'AQConfig.pas',
  SubscriptionOutcomeData in 'SubscriptionOutcomeData.pas',
  Consumer in 'Consumer.pas',
  ListenerProxyInterface in 'ListenerProxyInterface.pas',
  ConditionInterface in 'ConditionInterface.pas',
  TokenBasedCondition in 'TokenBasedCondition.pas',
  JsonSaver in 'JsonSaver.pas',
  JsonableInterface in 'JsonableInterface.pas',
  CliParam in '..\Cli\CliParam.pas',
  CliUsage in '..\Cli\CliUsage.pas',
  Attachment in '..\EmailTemplate\Attachment.pas',
  ActiveQueueEntry in 'ActiveQueueEntry.pas',
  ServerConfig in '..\Config\ServerConfig.pas',
  AQConfigBuilder in 'AQConfigBuilder.pas',
  Client,
  AQSubscriptionEntry in 'AQSubscriptionEntry.pas',
  AQResponce in 'AQResponce.pas',
  RequestSaverFactory in '..\Storage\RequestSaverFactory.pas';

{$R *.res}


const
  SWITCH_ORIGIN_CONFIG = 'c';
  SWITCH_TARGET_CONFIG = 't';
  SWITCH_QUEUE = 'q';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Active Queue Server';

var
  OriginConfig, TargetConfig, QueueFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TAQConfig;
  ConfigImm: TAQConfigImmutable;
  CliParams: TArray<TCliParam>;
  ParamUsage: TCliUsage;
  ParamValues: TDictionary<String, String>;

procedure RunServer(const Config: TAQConfigImmutable; const TargetConfig, QueueFileName: String);
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
  L: Integer;
  InfoString: String;
begin
  TController.SetConfig(Config, TargetConfig);
  APort := TController.GetPort();
  InfoString := Format('%s:%d', [PROGRAM_NAME, APort]);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14);
  Writeln('');
  Writeln('  ' + InfoString);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
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
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 10);
      Write(Format('%15s', [Client.IP]));
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
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
    TCliParam.Create(SWITCH_TARGET_CONFIG, 'path', 'path to a file to save the configuration', True),
    TCliParam.Create(SWITCH_QUEUE, 'queue', 'path to a file in which the queues received from the reception have been saved', True)];
  ParamUsage := TCliUsage.Create(ExtractFileName(paramstr(0)), CliParams);
  try
    try
      ParamValues := ParamUsage.Parse();
      OriginConfig := ParamValues[SWITCH_ORIGIN_CONFIG];
      TargetConfig := ParamValues[SWITCH_TARGET_CONFIG];
      QueueFileName := ParamValues[SWITCH_QUEUE];
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
            RunServer(ConfigImm, TargetConfig, QueueFileName);
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
