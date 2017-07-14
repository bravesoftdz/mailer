program Consumer;

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
  ConsumerController in 'ConsumerController.pas',
  ConsumerWebModule in 'ConsumerWebModule.pas' {ConsumerMockWebModule: TWebModule},
  AQAPIConsumer in 'AQAPIConsumer.pas',
  SendmailConfig in 'SendmailConfig.pas',
  ConsumerModel in 'ConsumerModel.pas',
  ConsumerConfig in 'ConsumerConfig.pas',
  System.Generics.Collections,
  CliParam in '..\Cli\CliParam.pas',
  CliUsage in '..\Cli\CliUsage.pas',
  Configuration in '..\Config\Configuration.pas',
  SendDataTemplate in '..\EmailTemplate\SendDataTemplate.pas',
  System.IOUtils,
  System.JSON,
  AQSubscriptionEntry in '..\ActiveQueue\AQSubscriptionEntry.pas',
  KeyStroke in 'KeyStroke.pas',
  AQResponce in '..\ActiveQueue\AQResponce.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Consumer Server';
  DEFAULT_COLOR = 7;
  APP_COLOR = 752;
  HIGHLIGHT_COLOR = 10;
  WARNING_COLOR = 12;

var
  ConfigFileName: String;
  Usage: String;
  CliParams: TArray<TCliParam>;
  ParamUsage: TCliUsage;
  ParamValues: TDictionary<String, String>;
  JsonConfig: TJsonObject;
  FileContent: String;
  Config: TConsumerConfig;

procedure RunServer(const Config: TConsumerConfig; const ConfigFileName: String);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  Port, BlockSize: Integer;
  InfoString, Token: String;
  SubscriptionStatus: Boolean;
  KeyStrokeContainer: TKeyStroke;
  Action1, Action2, Action3: IKeyStrokeAction;

begin
  TConsumerController.SetConfig(Config, ConfigFileName);
  with TConsumerController do
  begin
    Port := GetPort();
    SubscriptionStatus := getSubscriptionStatus();
    Token := GetSubscriptionToken();
    BlockSize := GetBlockSize();
  end;

  InfoString := Format('%s:%d', [PROGRAM_NAME, Port]);

  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), APP_COLOR);
  Writeln('');
  Writeln('  ' + InfoString + '   ');
  Writeln('');
  SetConsoleTitle(pwidechar(InfoString));

  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  Write('Data provider: ');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
  Writeln(Format('%s:%d', [Config.ProviderIp, Config.ProviderPort]));
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  Write('The subscription to the data provider: ');
  if SubscriptionStatus then
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
    Writeln('present');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  end
  else
  begin
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
    Writeln('absent');
    SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR)
  end;
  if Token <> '' then
  begin
    Write('Token: ');
    if not(SubscriptionStatus) then
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR)
    else
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
    Writeln(Copy(Token, 1, 4) + '***');
  end
  else
  begin
    if SubscriptionStatus then
      SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
    Writeln('No token found.');
  end;
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  Write('Number of items to request at once: ');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), HIGHLIGHT_COLOR);
  Writeln(BlockSize.toString());
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
  Action1 := TExitAction.Create();
  Action2 := TConsumerSubscribeAction.Create();
  Action3 := TConsumerUnSubscribeAction.Create();
  KeyStrokeContainer := TKeyStroke.Create([Action1, Action2, Action3]);

  LServer := TIdHTTPWebBrokerBridge.Create(nil);
  try
    LServer.DefaultPort := Port;
    LServer.Active := True;
    LServer.MaxConnections := 0;
    LServer.ListenQueue := 200;

    Writeln(KeyStrokeContainer.Description);
    LHandle := GetStdHandle(STD_INPUT_HANDLE);
    while True do
    begin
      Win32Check(ReadConsoleInput(LHandle, LInputRecord, 1, LEvent));
      if (LInputRecord.EventType = KEY_EVENT) and
        LInputRecord.Event.KeyEvent.bKeyDown then
      begin
        if KeyStrokeContainer.ElaborateKeyStroke(LInputRecord.Event.KeyEvent.wVirtualKeyCode) = 0 then
          break;
      end;
    end;
  finally
    LServer.Free;
    Action1 := nil;
    Action2 := nil;
    Action3 := nil;
    KeyStrokeContainer.DisposeOf;

  end;
end;

begin
  ReportMemoryLeaksOnShutdown := True;
  CliParams := [TCliParam.Create(SWITCH_CONFIG, 'path', 'path to the config file', True)];
  ParamUsage := TCliUsage.Create(ExtractFileName(paramstr(0)), CliParams);
  FindCmdLineSwitch(SWITCH_CONFIG, ConfigFileName, False);
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
        Config := TConsumerConfig.CreateFromJson(JsonConfig);
        JsonConfig.DisposeOf;
      end;
      if Config <> nil then
      begin
        if WebRequestHandler <> nil then
          WebRequestHandler.WebModuleClass := WebModuleClass;
        WebRequestHandlerProc.MaxConnections := 1024;
        RunServer(Config, ConfigFileName);
      end
      else
      begin
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
        Writeln('No config is created. The service is not started.');
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
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
    ParamUsage.DisposeOf;
    CliParams[0].DisposeOf();
    SetLength(CliParams, 0);
    if Config <> nil then
      Config.DisposeOf;
  end;

end.
