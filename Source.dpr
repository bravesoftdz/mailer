program Source;

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
  MailerController in 'MailerController.pas',
  MailerDispatcher in 'MailerDispatcher.pas' {MailerWebModule: TWebModule} ,
  RegistrationResponce in 'RegistrationResponce.pas',
  FrontEndResponce in 'FrontEndResponce.pas',
  Provider in 'Provider.pas',
  FrontEndRequest in 'FrontEndRequest.pas',
  ProviderFactory in 'ProviderFactory.pas',
  VenditoriSimple in 'Providers\VenditoriSimple.pas',
  Action in 'Actions\Action.pas' {ActionSend in 'ActionSend.pas';
    {$R *.res} ,
  SoluzioneAgenti in 'Providers\SoluzioneAgenti.pas',
  Credentials in 'Data\Credentials.pas',
  BackEndRequest in 'BackEndRequest.pas',
  SendServerProxy.interfaces in 'SendServerProxy.interfaces.pas',
  BackEndResponce in 'BackEndResponce.pas',
  Attachment in 'Attachment.pas',
  BackEndSettings in 'BackEndSettings.pas';

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
  IsPortValid: Boolean;
begin
  Writeln('** DMVCFramework Server **');
  Writeln(Format('Starting HTTP Server on port %d', [APort]));

  BackEndPort := -1;
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
  TMailerController.SetBackEnd(TBackEndSettings.Create(BackEndUrl, BackEndPort));

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
