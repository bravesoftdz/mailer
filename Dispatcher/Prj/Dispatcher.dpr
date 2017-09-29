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
  DispatcherController in '..\Src\DispatcherController.pas',
  DispatcherProject in '..\Src\DispatcherProject.pas' {DispatcherModule: TWebModule} ,
  DispatcherModel in '..\Src\DispatcherModel.pas',
  CliParam,
  CliUsage,
  ObjectsMappers,
  DispatcherConfig in '..\Src\DispatcherConfig.pas',
  Configuration in '..\..\Config\Configuration.pas',
  DispatcherResponce in '..\Src\DispatcherResponce.pas',
  DispatcherEntry in '..\Src\DispatcherEntry.pas',
  Actions in '..\Src\Actions.pas',
  Provider in '..\Src\Provider.pas',
  ProviderFactory in '..\Src\ProviderFactory.pas',
  ServerConfig in '..\..\Config\ServerConfig.pas',
  SoluzioneAgenti in '..\Src\SoluzioneAgenti.pas',
  VenditoriSimple in '..\Src\VenditoriSimple.pas',
  OfferteNuoviMandati in '..\Src\OfferteNuoviMandati.pas',
  SendDataTemplate in '..\..\EmailTemplate\SendDataTemplate.pas',
  System.JSON,
  System.IOUtils,
  IpTokenAuthentication in '..\..\Authentication\IpTokenAuthentication.pas',
  AQAPIClient in '..\Src\AQAPIClient.pas',
  ONMCredentials in '..\Src\ONMCredentials.pas',
  RequestStorageInterface in '..\..\Storage\RequestStorageInterface.pas',
  RequestToFileSystemStorage in '..\..\Storage\RequestToFileSystemStorage.pas',
  RepositoryConfig in '..\..\Config\RepositoryConfig.pas',
  RequestSaverFactory in '..\..\Storage\RequestSaverFactory.pas',
  System.Generics.Collections;

{$R *.res}


const
  PROGRAM_NAME = 'Dispatcher server';
  SWITCH_CONFIG = 'c';
  DEFAULT_COLOR = 7;
  APP_COLOR = 14;
  HIGHLIGHT_COLOR = 10;
  WARNING_COLOR = 12;

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
  RepositoryParams: TArray<TPair<String, String>>;
  PendingRequests: TDictionary<String, TDispatcherEntry>;
  RequestID: String;
  PendingRequestsNum: Integer;
begin
  TDispatcherController.SetConfig(Config);
  APort := TDispatcherController.GetPort();
  BackEndPort := TDispatcherController.GetBackEndPort();
  BackEndIp := TDispatcherController.GetBackEndIp();
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), APP_COLOR);
  Info := Format('%s:%d', [PROGRAM_NAME, APort]);
  Writeln('');
  Writeln('  ' + Info);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  SetConsoleTitle(pwidechar(Info));
  Write('Backend: ');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
  Writeln(BackEndIp + ':' + BackEndPort.ToString);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);

  RepositoryParams := TDispatcherController.GetRepositoryParams();

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

  PendingRequests := TDispatcherController.GetPendingRequests();
  PendingRequestsNum := PendingRequests.Count;
  if PendingRequestsNum = 0 then
  begin
    Writeln('No pending requests found.');
  end
  else
  begin
    Writeln(Format('%d pending request(s) found.', [PendingRequestsNum]));
    for RequestID in PendingRequests.Keys do
    begin
      Writeln(Format('origin: %s, action: %s, number of attachments: %d, id: %s',
        [PendingRequests[RequestID].Origin, PendingRequests[RequestID].Action, PendingRequests[RequestID].Attachments.Count, RequestID]));
    end;
  end;
  TDispatcherController.ElaboratePendingRequests();
  PendingRequests.Clear;
  PendingRequests.DisposeOf;

  ClientIps := TDispatcherController.GetClientIps();
  S := Length(ClientIPs);
  if S = 0 then
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
    Writeln('No client ip is provided. All requests will be rejected.');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  end
  else
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
    Writeln(S.toString + ' client ip(s) found:');
    for I := 0 to S - 1 do
    begin
      Writeln(Format('%d: %s', [I + 1, ClientIps[I]]));
    end;
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
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
    if ConfigImm <> nil then
      ConfigImm.DisposeOf;

    ParamUsage.DisposeOf;
    CliParams[0].DisposeOf();
    SetLength(CliParams, 0);
  end;

end.
