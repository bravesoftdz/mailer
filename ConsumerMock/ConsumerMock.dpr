program ConsumerMock;

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
  ConsumerWebModule in 'ConsumerWebModule.pas' {ConsumerMockWebModule: TWebModule} ,
  ActiveQueueAPI in '..\ActiveQueue\ActiveQueueAPI.pas',
  Config in 'Config.pas',
  Model in 'Model.pas',
  ConsumerConfig in 'ConsumerConfig.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Consumer Server';

var
  ConfigFileName: String;

procedure RunServer(const ConfigFileName: String);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  Port: Integer;

begin
  SetConsoleTitle(PROGRAM_NAME);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 13);
  Writeln('');
  Writeln('  ' + PROGRAM_NAME);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    TController.LoadConfigFromFile(ConfigFileName);
    Port := TController.GetPort();
    LServer.DefaultPort := Port;
    LServer.Active := True;
    Writeln(Format('Server started on port %d', [Port]));
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
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
