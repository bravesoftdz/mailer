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

procedure RunServer(APort: Integer);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;

begin
  Writeln('** DMVCFramework Server **');
  Writeln(Format('Starting HTTP Server on port %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    LServer.Active := True;
    LogI(Format('Server started on port 8070', [APort]));
    { more info about MaxConnections
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_MaxConnections.html }
    LServer.MaxConnections := 0;
    { more info about ListenQueue
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_ListenQueue.html }
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
    Port := JsonConfig.getValue('port').Value.ToInteger;

  end;
  Config := TAQConfig.LoadFromJson(JsonConfig);
  if Config.Port > 0 then
  begin
    try
      if WebRequestHandler <> nil then
        WebRequestHandler.WebModuleClass := WebModuleClass;
      WebRequestHandlerProc.MaxConnections := 1024;
      RunServer(Config.Port);
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;

  end;

end.
