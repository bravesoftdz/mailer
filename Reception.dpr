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
  VenditoriSimple in 'Providers\VenditoriSimple.pas',
  Action in 'Actions\Action.pas' {ActionSend in 'ActionSend.pas';
    {$R *.res},
  SoluzioneAgenti in 'Providers\SoluzioneAgenti.pas',
  Credentials in 'Data\Credentials.pas',
  Attachment in 'Attachment.pas',
  ActiveQueueProxy in 'ActiveQueueProxy.pas',
  FrontEndData in 'FrontEndData.pas',
  FrontEndRequest in 'FrontEndRequest.pas',
  Provider in 'Provider.pas',
  ProviderFactory in 'ProviderFactory.pas',
  Controller in 'Controller.pas',
  ReceptionModule in 'ReceptionModule.pas' {ReceptionWebModule: TWebModule},
  ReceptionModel in 'ReceptionModel.pas',
  ReceptionRequest in 'ReceptionRequest.pas',
  ReceptionResponce in 'ReceptionResponce.pas',
  RegistrationResponce in 'RegistrationResponce.pas',
  SendServerProxy.interfaces in 'SendServerProxy.interfaces.pas',
  ActiveQueueSettings,
  SubscriptionData in 'SubscriptionData.pas',
  CliParam in 'CliParam.pas',
  System.JSON,
  System.IOUtils,
  ReceptionConfig in 'ReceptionConfig.pas',
  Client in 'Client.pas';

const
  BACKEND_URL_SWITCH = 'u';
  BACKEND_PORT_SWITCH = 'p';
  SWITCH_CHAR = '-';
  SWITCH_CONFIG = 'c';

var
  ConfigFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Usage: TArray<TCliParam>;
  Config: TReceptionConfig;

procedure RunServer(const OutputConfigName: String; const Config: TReceptionConfig);
var
  Port: Integer;
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  BackEndUrl, BackEndPortStr: String;
  BackEndPort: Integer;
  Settings: TActiveQueueSettings;
  BackEndServer: TBackEndProxy;
begin
  Port := Config.Port;
  Writeln('** DMVCFramework Server **');
  Writeln(Format('Starting HTTP Server on port %d', [Port]));

  FindCmdLineSwitch(BACKEND_URL_SWITCH, BackEndUrl, False);
  FindCmdLineSwitch(BACKEND_PORT_SWITCH, BackEndPortStr, False);
  try
    BackEndPort := StrToInt(BackEndPortStr);
  except
    on E: Exception do
    begin
      Writeln('Error: ' + E.Message);
      Exit();
    end
  end;
  Settings := TActiveQueueSettings.Create(BackEndUrl, BackEndPort);
  BackEndServer := TBackEndProxy.getInstance();
  BackEndServer.setSettings(Settings);
  Writeln('Back end server url: ' + Settings.Summary);

  TController.SetBackEnd(Settings);

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

{ TCliParam }

begin
  ReportMemoryLeaksOnShutdown := True;
  Usage := [TCliParam.Create('c', 'path', 'path to the config file', True)];
  FindCmdLineSwitch(SWITCH_CONFIG, ConfigFileName, False);

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

  if Assigned(Config) then
  begin

    try
      if WebRequestHandler <> nil then
        WebRequestHandler.WebModuleClass := WebModuleClass;
      WebRequestHandlerProc.MaxConnections := 1024;
      RunServer(ConfigFileName, Config);
    except
      on E: Exception do
        Writeln(E.ClassName, ': ', E.Message);
    end;
  end;

end.
