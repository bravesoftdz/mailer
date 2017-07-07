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
  ActiveQueueModule in 'ActiveQueueModule.pas' {ActiveQueueModule: TWebModule} ,
  ActiveQueueResponce in 'ActiveQueueResponce.pas',
  ActiveQueueSettings in 'ActiveQueueSettings.pas',
  Model in 'Model.pas',
  System.IOUtils,
  System.JSON,
  ObjectsMappers,
  System.Generics.Collections,
  AQConfig in 'AQConfig.pas',
  SubscriptionOutcomeData in 'SubscriptionOutcomeData.pas',
  ListenerInfo in 'ListenerInfo.pas',
  ListenerProxyInterface in 'ListenerProxyInterface.pas',
  ActiveQueueAPI in 'ActiveQueueAPI.pas',
  ConditionInterface in 'ConditionInterface.pas',
  TokenBasedCondition in 'TokenBasedCondition.pas',
  JsonSaver in 'JsonSaver.pas',
  JsonableInterface in 'JsonableInterface.pas',
  CliParam in '..\Cli\CliParam.pas',
  CliUsage in '..\Cli\CliUsage.pas',
  SubscriptionData in '..\Reception\SubscriptionData.pas',
  Attachment in '..\Reception\Attachment.pas',
  ServerConfig in '..\Config\ServerConfig.pas',
  ActiveQueueEntry in 'ActiveQueueEntry.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_QUEUE = 'q';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Active Queue Server';

var
  ConfigFileName, QueueFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TServerConfig;
  ConfigImm: TServerConfigImmutable;
  Usage: String;
  CliParams: TArray<TCliParam>;
  ParamUsage: TCliUsage;
  ParamValues: TDictionary<String, String>;

procedure RunServer(const ConfigFileName, QueueFileName: String);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  WhiteListitem: String;
  ListenersWhiteList, ProvidersWhiteList: TArray<String>;
  APort: Integer;
  numberOfListeners, Counter: Integer;
  Listener: TListenerInfo;
  Listeners: TObjectList<TListenerInfo>;
begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14);
  Writeln('');
  Writeln('  ' + PROGRAM_NAME);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  TController.LoadStateFromFile(ConfigFileName);
  TController.LoadQueuesFromFile(QueueFileName);

  APort := TController.GetPort();
  SetConsoleTitle(pwidechar(Format('%s:%d', [PROGRAM_NAME, APort])));

  Writeln(Format('Starting HTTP Server on port %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);

  ListenersWhiteList := TController.GetListenersIPs;
  ProvidersWhiteList := TController.GetProvidersIPs;

  if (Length(ListenersWhiteList) = 0) then
  begin
    Writeln('The listener IP whitelist is empty. No subscriptions will succeed.');
  end
  else
  begin
    Writeln('Allowed IPs for listeners:');
    for WhiteListitem in ListenersWhiteList do
      Writeln(WhiteListitem);
  end;
  if (Length(ProvidersWhiteList) = 0) then
  begin
    Writeln('The provider IP whitelist is empty. No one will succeed to enqueue the data.');
  end
  else
  begin
    Writeln('Allowed IPs for data providers:');
    for WhiteListitem in ProvidersWhiteList do
      Writeln(WhiteListitem);
  end;
  Listeners := TController.GetListeners();
  numberOfListeners := Listeners.Count;
  Counter := 1;
  if numberOfListeners = 0 then
    Writeln('No subscriptions found in the config file.')
  else
  begin
    Writeln(inttostr(numberOfListeners) + ' subscription(s) found.');
    for Listener in Listeners do
    begin
      Writeln(Format('%d) ip: %s, port: %d, token: (hidden)', [Counter, Listener.IP, Listener.Port]));
      Counter := Counter + 1;
    end;
    Listeners.Clear;
  end;
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
  CliParams := [TCliParam.Create(SWITCH_CONFIG, 'path', 'path to the config file', True),
    TCliParam.Create(SWITCH_QUEUE, 'queue', 'path to a file in which the queues received from the reception have been saved', True)];
  ParamUsage := TCliUsage.Create(ExtractFileName(paramstr(0)), CliParams);
  try
    try
      ParamValues := ParamUsage.Parse();
      ConfigFileName := ParamValues[SWITCH_CONFIG];
      if Not(TFile.Exists(ConfigFileName)) then
      begin
        Writeln('Error: config file ' + ConfigFileName + 'not found.');
        Exit();
      end;
      try
        FileContent := TFile.ReadAllText(ConfigFileName);
        JsonConfig := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FileContent), 0) as TJSONObject;
      except
        on E: Exception do
        begin
          Writeln(E.Message);
          Exit();
        end;
      end;
      if Assigned(JsonConfig) then
      begin
        try
          Config := Mapper.JSONObjectToObject<TServerConfig>(JsonConfig);
          ConfigImm := TServerConfigImmutable.Create(Config);
          Config.DisposeOf;
        finally
          JsonConfig.DisposeOf;
        end;
      end;
      if ConfigImm <> nil then
      begin
        if WebRequestHandler <> nil then
          WebRequestHandler.WebModuleClass := WebModuleClass;
        WebRequestHandlerProc.MaxConnections := 1024;
        RunServer(ConfigFileName, QueueFileName);
      end
      else
        Writeln('No config is created. Failed to start the service.');
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
    ParamUsage.DisposeOf;
    CliParams[0].DisposeOf();
    SetLength(CliParams, 0);
  end;

end.
