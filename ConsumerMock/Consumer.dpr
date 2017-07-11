program Consumer;

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
  ConsumerController in 'ConsumerController.pas',
  ConsumerWebModule in 'ConsumerWebModule.pas' {ConsumerMockWebModule: TWebModule} ,
  AQAPIConsumer in 'AQAPIConsumer.pas',
  SendmailConfig in 'SendmailConfig.pas',
  ConsumerModel in 'ConsumerModel.pas',
  ConsumerConfig in 'ConsumerConfig.pas',
  System.Generics.Collections,
  CliParam in '..\Cli\CliParam.pas',
  CliUsage in '..\Cli\CliUsage.pas',
  Configuration in '..\Config\Configuration.pas',
  SubscriptionData in 'SubscriptionData.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Consumer Server';

var
  ConfigFileName: String;
  Usage: String;
  CliParams: TArray<TCliParam>;

procedure RunServer(const ConfigFileName: String);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  Port: Integer;
  Config: TConsumerConfig;

begin
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 13);
  Writeln('');
  Writeln('  ' + PROGRAM_NAME);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    TConsumerController.LoadConfigFromFile(ConfigFileName);
    Config := TConsumerController.GetConfig();
    Port := Config.Port;
    SetConsoleTitle(pwidechar(Format('%s:%d', [PROGRAM_NAME, Port])));
    Writeln(Format('Server started on port %d', [Port]));
    Writeln(Format('Data provider ip: %s', [Config.ProviderIp]));
    Writeln(Format('Data provider port: %d', [Config.ProviderPort]));
    if Config.SubscriptionStatus then
      Writeln(Format('It is subscribed to the data provider, token: %s', [Config.SubscriptionToken]))
    else
      Writeln('It is not subscribed to the data provider.');

    Config.DisposeOf;

    LServer.DefaultPort := Port;
    LServer.Active := True;
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
      Writeln(E.ClassName + ': ' + E.Message);
      CliParams := [TCliParam.Create(SWITCH_CONFIG, 'path', 'path to the config file', True)];
      Usage := TCliUsage.CreateText(ExtractFileName(paramstr(0)), CliParams);
      Writeln(Usage);
      CliParams[0].DisposeOf;
      SetLength(CliParams, 0);

    end;
  end;

end.
