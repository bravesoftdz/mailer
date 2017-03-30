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
  System.Generics.Collections,
  AQConfig in 'AQConfig.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_CHAR = '-';

var
  configFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Port: Integer;
  IPs: TJsonArray;
  Usage: TArray<TCliParam>;
  Config: TAQConfig;

procedure RunServer(APort: Integer; const IPs: TArray<String>);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;

begin
  Writeln('** DMVCFramework Server **');
  Writeln(Format('Starting HTTP Server on port %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  TController.SetIps(IPs);
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
  Usage := [TCliParam.Create('c', 'path', 'path to the config file', True)];
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
    Config := TAQConfig.LoadFromJson(JsonConfig);
  end;
  if Config.Port > 0 then
  begin
    try
      if WebRequestHandler <> nil then
        WebRequestHandler.WebModuleClass := WebModuleClass;
      WebRequestHandlerProc.MaxConnections := 1024;
      RunServer(Config.Port, Config.IPS);
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;

  end;

end.
