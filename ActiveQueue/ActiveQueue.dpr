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
  Controller in 'Controller.pas',
  ActiveQueueModule in 'ActiveQueueModule.pas' {ActiveQueueModule: TWebModule} ,
  ActiveQueueResponce in 'ActiveQueueResponce.pas',
  ActiveQueueSettings in 'ActiveQueueSettings.pas',
  CliParam in '..\CliParam.pas',
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
  StateSaver in 'StateSaver.pas',
  JsonableInterface in 'JsonableInterface.pas',
  CliUsage in 'CliUsage.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Active Queue Server';

var
  configFileName: String;
  Usage: String;
  CliParams: TArray<TCliParam>;

procedure RunServer(const ConfigFile: String);
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
begin
  SetConsoleTitle(PROGRAM_NAME);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14);
  Writeln('');
  Writeln('  ' + PROGRAM_NAME);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  TController.LoadStateFromFile(ConfigFile);

  APort := TController.GetPort();
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

  numberOfListeners := TController.GetListeners().Count;
  Counter := 1;
  if numberOfListeners = 0 then
    Writeln('No subscriptions found in the config file.')
  else
  begin
    Writeln(inttostr(numberOfListeners) + ' subscription(s) found.');
    for Listener in TController.GetListeners() do
    begin
      Writeln(Format('%d) ip: %s, port: %d, token: (hidden)', [Counter, Listener.IP, Listener.Port]));
      Counter := Counter + 1;
    end;
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
  FindCmdLineSwitch(SWITCH_CONFIG, ConfigFileName, False);

  try
    if WebRequestHandler <> nil then
      WebRequestHandler.WebModuleClass := WebModuleClass;
    WebRequestHandlerProc.MaxConnections := 1024;
    RunServer(ConfigFileName);
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      CliParams := [TCliParam.Create('c', 'path', 'path to the config file', True)];
      Usage := TCliUsage.CreateText(ExtractFileName(paramstr(0)), CliParams);
      Writeln(Usage);
      CliParams[0].DisposeOf;
      SetLength(CliParams, 0);
    end;
  end;

end.
