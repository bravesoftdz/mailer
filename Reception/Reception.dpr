program Reception;

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
  ActiveQueueSettings,
  System.JSON,
  ObjectsMappers,
  System.IOUtils,
  System.Generics.Collections,
  CliParam in '..\Cli\CliParam.pas',
  CliUsage in '..\Cli\CliUsage.pas',
  Controller in 'Controller.pas',
  ReceptionModel in 'ReceptionModel.pas',
  ReceptionConfig in 'ReceptionConfig.pas',
  Responce in 'Responce.pas',
  Client in 'Client.pas',
  Authentication in 'Authentication.pas',
  ReceptionModule in 'ReceptionModule.pas' {ReceptionModule: TWebModule} ,
  Attachment in 'Attachment.pas',
  DispatcherProxyInterface in 'DispatcherProxyInterface.pas';

const
  SWITCH_CONFIG = 'c';
  PROGRAM_NAME = 'Reception Server';

var
  ConfigFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TReceptionConfig;
  CliParams: TArray<TCliParam>;
  ParamUsage: TCliUsage;
  ParamValues: TDictionary<String, String>;

procedure RunServer(const Config: TReceptionConfig);
var
  Port: Integer;
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  Clients: TObjectList<TClient>;
  Client: TClient;
  Info: String;
begin
  TController.SetConfig(Config);
  Port := TController.GetPort();
  Info := Format('%s:%d', [PROGRAM_NAME, Port]);
  SetConsoleTitle(pwidechar(Info));
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 10);
  Writeln('');
  Writeln(Info);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  Write('Back end server: ');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 15);
  Writeln(Format('%s:%d', [TController.GetBackEndUrl, TController.GetBackEndPort]));
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  Clients := TController.GetClients;

  if (Clients.Count > 0) then
  begin
    Writeln('Clients:');
    for Client in Clients do
    begin
      Write('ip: ');
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 10);
      Write(Format('%15s', [Client.IP]));
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
      Writeln(', token: (not shown)');
    end;
  end
  else
  begin
    Writeln('No clients are provided. Every request is to be ignored.');
  end;
  Clients.Clear;
  Clients.DisposeOf;

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := Port;
    LServer.Active := True;
    LogI(Format('Server started on port %d', [Port]));
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
  CliParams := [TCliParam.Create(SWITCH_CONFIG, 'path', 'path to the config file', True)];
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
        Config := Mapper.JSONObjectToObject<TReceptionConfig>(JsonConfig);
      end;
      if Config <> nil then
      begin
        if WebRequestHandler <> nil then
          WebRequestHandler.WebModuleClass := WebModuleClass;
        WebRequestHandlerProc.MaxConnections := 1024;
        RunServer(Config);
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
    if Config <> nil then
      Config.DisposeOf;
    ParamUsage.DisposeOf;
    CliParams[0].DisposeOf();
    SetLength(CliParams, 0);
  end;

end.
