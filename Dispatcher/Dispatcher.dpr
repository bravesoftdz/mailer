program Dispatcher;

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
  DispatcherController in 'DispatcherController.pas',
  DispatcherProject in 'DispatcherProject.pas' {DispatcherModule: TWebModule},
  DispatcherModel in 'DispatcherModel.pas',
  CliParam,
  CliUsage,
  System.Generics.Collections,
  ObjectsMappers,
  DispatcherConfig in 'DispatcherConfig.pas',
  Configuration in '..\Config\Configuration.pas',
  DispatcherResponce in 'DispatcherResponce.pas',
  DispatcherEntry in 'DispatcherEntry.pas',
  Actions in 'Actions.pas',
  Provider in 'Provider.pas',
  ProviderFactory in 'ProviderFactory.pas',
  SenderCredentials in 'SenderCredentials.pas',
  ServerConfig in '..\Config\ServerConfig.pas',
  SoluzioneAgenti in 'SoluzioneAgenti.pas',
  VenditoriSimple in 'VenditoriSimple.pas',
  OfferteNuoviMandati in 'OfferteNuoviMandati.pas',
  SendDataTemplate in 'SendDataTemplate.pas',
  System.JSON,
  System.IOUtils,
  IpTokenAuthentication in '..\Authentication\IpTokenAuthentication.pas';

{$R *.res}


const
  PROGRAM_NAME = 'Dispatcher server';
  SWITCH_CONFIG = 'c';

var
  ConfigFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TServerConfig;
  ConfigImm: TServerConfigImmutable;
  CliParams: TArray<TCliParam>;
  ParamUsage: TCliUsage;
  ParamValues: TDictionary<String, String>;

procedure RunServer(const Config: TServerConfigImmutable);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  APort, BackEndPort, S, I: Integer;
  Info, BackEndIp: String;
  ClientIps: TArray<String>;
begin
  TDispatcherController.SetConfig(Config);
  APort := TDispatcherController.GetPort();
  BackEndPort := TDispatcherController.GetBackEndPort();
  BackEndIp := TDispatcherController.GetBackEndIp();
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14);
  Info := Format('%s:%d', [PROGRAM_NAME, APort]);
  Writeln('');
  Writeln('  ' + Info);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  SetConsoleTitle(pwidechar(Info));
  Write('Backend: ');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 15);
  Writeln(BackEndIp + ':' + BackEndPort.ToString);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  ClientIps := TDispatcherController.GetClientIps();
  S := Length(ClientIPs);
  if S = 0 then
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 12); // red
    Writeln('No client ip is provided. All requests will be rejected.');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  end
  else
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 10); // green
    Writeln(S.toString + ' client ip(s) found:');
    for I := 0 to S - 1 do
    begin
      Writeln(Format('%d: %s', [I + 1, ClientIps[I]]));
    end;
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  end;
  SetLength(ClientIps, 0);

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := APort;
    LServer.Active := True;
    LogI(Format('Server started on port %d', [APort]));
    { more info about MaxConnections
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_MaxConnections.html }
    LServer.MaxConnections := 0;
    { more info about ListenQueue
      http://www.indyproject.org/docsite/html/frames.html?frmname=topic&frmfile=TIdCustomTCPServer_ListenQueue.html }
    LServer.ListenQueue := 200;
    { Comment the next line to avoid the default browser startup }
    // ShellExecute(0, 'open', PChar('http://localhost:' + inttostr(APort)), nil, nil, SW_SHOWMAXIMIZED);
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
        RunServer(ConfigImm);
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
    SetLength(CliParams, 0);
  end;

end.
