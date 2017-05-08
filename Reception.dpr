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
  CliParam in 'CliParam.pas';

const
  BACKEND_URL_SWITCH = 'u';
  BACKEND_PORT_SWITCH = 'p';
  SWITCH_CHAR = '-';

procedure RunServer(APort: Integer);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  BackEndUrl, BackEndPortStr: String;
  BackEndPort: Integer;
  Settings: TActiveQueueSettings;
  BackEndServer: TBackEndProxy;
begin
  Writeln('** DMVCFramework Server **');
  Writeln(Format('Starting HTTP Server on port %d', [APort]));

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

{ TCliParam }

begin
  ReportMemoryLeaksOnShutdown := True;
  try
    if WebRequestHandler <> nil then
      WebRequestHandler.WebModuleClass := WebModuleClass;
    WebRequestHandlerProc.MaxConnections := 1024;
    RunServer(80);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.
