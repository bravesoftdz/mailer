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
  Credentials in '..\Data\Credentials.pas',
  Attachment in '..\Attachment.pas',
  ReceptionModule in '..\ReceptionModule.pas',
  SendServerProxy.interfaces in '..\SendServerProxy.interfaces.pas',
  ActiveQueueSettings,
  SubscriptionData in '..\SubscriptionData.pas',
  System.JSON,
  ObjectsMappers,
  System.IOUtils,
  Client in '..\Client.pas',
  System.Generics.Collections,
  Authentication in '..\Authentication.pas',
  CliParam in '..\Cli\CliParam.pas',
  CliUsage in '..\Cli\CliUsage.pas',
  Controller in 'Controller.pas',
  ReceptionModel in 'ReceptionModel.pas',
  ReceptionConfig in 'ReceptionConfig.pas',
  ClientRequest in 'ClientRequest.pas',
  FrontEndRequest in 'FrontEndRequest.pas',
  Provider in 'Provider.pas',
  ProviderFactory in 'ProviderFactory.pas',
  ReceptionRequest in 'ReceptionRequest.pas',
  Responce in 'Responce.pas',
  Action in 'Actions\Action.pas',
  SoluzioneAgenti in 'Providers\SoluzioneAgenti.pas',
  VenditoriSimple in 'Providers\VenditoriSimple.pas',
  ClientFullRequest in 'ClientFullRequest.pas';

const
  BACKEND_URL_SWITCH = 'u';
  BACKEND_PORT_SWITCH = 'p';
  SWITCH_CHAR = '-';
  SWITCH_CONFIG = 'c';
  PROGRAM_NAME = 'Reception Server';

var
  ConfigFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TReceptionConfig;

procedure RunServer(const Config: TReceptionConfig);
var
  Port: Integer;
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  BackEndSettings, BackEndSettingsCopy: TActiveQueueSettings;
  Clients: TObjectList<TClient>;
  Client: TClient;
begin
  Port := Config.Port;
  SetConsoleTitle(pwidechar(Format('%s:%d', [PROGRAM_NAME, Port])));
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 10);
  Writeln('');
  Writeln('  ' + PROGRAM_NAME);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);
  Writeln(Format('Starting HTTP Server on port %d', [Port]));

  BackEndSettings := TActiveQueueSettings.Create(Config.BackEndUrl, Config.BackEndPort);

  TController.SetBackEndSettings(BackEndSettings);

  BackEndSettingsCopy := TController.GetBackEndSettings;
  Writeln('Back end server:');
  Writeln('url: ' + BackEndSettingsCopy.URL + ', port: ' + IntToStr(BackEndSettingsCopy.Port));

  TController.SetClients(Config.Clients);
  Clients := TController.GetClients;
  if (Clients.Count > 0) then
  begin
    Writeln('Clients:');
    for Client in Clients do
    begin
      Writeln('ip: ' + Format('%15s', [Client.IP]) + ', token: (not shown)');
    end;
  end
  else
  begin
    Writeln('No clients are provided. Every request is to be ignored.');
  end;
  Clients.Clear;

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
  FindCmdLineSwitch(SWITCH_CONFIG, ConfigFileName, False);
  if Not(TFile.Exists(ConfigFileName)) then
  begin
    Writeln('Error: config file ' + ConfigFileName + 'not found.');
    Writeln(TCliUsage.CreateText(ExtractFileName(paramstr(0)), [TCliParam.Create('c', 'path', 'path to the config file', True)]));
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

  if Assigned(Config) then
  begin
    try
      if WebRequestHandler <> nil then
        WebRequestHandler.WebModuleClass := WebModuleClass;
      WebRequestHandlerProc.MaxConnections := 1024;
      RunServer(Config);
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;

  end;
  if Config <> nil then
    Config.DisposeOf;

end.
