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
  ObjectsMappers,
  System.Generics.Collections,
  AQConfig in 'AQConfig.pas',
  SubscriptionOutcomeData in 'SubscriptionOutcomeData.pas',
  ListenerInfo in 'ListenerInfo.pas',
  ListenerProxyInterface in 'ListenerProxyInterface.pas',
  ActiveQueueAPI in 'ActiveQueueAPI.pas',
  ConditionInterface in 'ConditionInterface.pas',
  TokenBasedCondition in 'TokenBasedCondition.pas',
  StateSaver in 'StateSaver.pas';

{$R *.res}


const
  SWITCH_CONFIG = 'c';
  SWITCH_CHAR = '-';
  PROGRAM_NAME = 'Active Queue Server';

var
  configFileName: String;
  JsonConfig: TJsonObject;
  FileContent: String;
  Usage: TArray<TCliParam>;
  Config: TAQConfig;

  /// <summary>Save a given text into a file with given name</summary>
procedure SaveConfigToFile(const seedName: String; const text: String);
begin
  TFile.AppendAllText(seedName, text);
  // TFile.WriteAllText();
end;

/// <summary>Find an available name for a file in the folder which the path referes to.
/// If no file under given path exists, that path is returned. If there exists a file,
/// then a new name is generated by prepending a timestamp to the given name.
/// </summary>
/// <param name="Path">Suggested path. If there exists a file, a new path is to generated. </param>
/// <param name="Format">format of the current timestamp to be prepended to the fila name </param>
function GetAvailablePath(const Path: String; const Format: String): String;
var
  TryName: String;
  folder, nameExt, name, ext: String;
begin
  TryName := path;
  while TFile.Exists(TryName) do
  begin
    Sleep(1000); // make it sleep for one sec since the output file name suffix is up to seconds
    Folder := ExtractFilePath(TryName);
    Ext := ExtractFileExt(TryName);
    NameExt := ExtractFileName(TryName);
    Name := Copy(NameExt, 1, Length(NameExt) - Length(Ext));
    TryName := Folder + Name + formatdatetime(Format, Now()) + Ext;
  end;
  Result := TryName;
end;

procedure RunServer(const ConfigFile: String; const Config: TAQConfig);
var
  LInputRecord: TInputRecord;
  LEvent: DWord;
  LHandle: THandle;
  LServer: TIdHTTPWebBrokerBridge;
  item: String;
  ListenersWhiteList, ProvidersWhiteList: TArray<String>;
  APort: Integer;
  numberOfListeners: Integer;
  I: Integer;

begin
  SetConsoleTitle(PROGRAM_NAME);
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 14);
  Writeln('');
  Writeln('  ' + PROGRAM_NAME);
  Writeln('');
  SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), 7);

  TController.SetState(ConfigFile, Config);

  APort := Config.Port;
  Writeln(Format('Starting HTTP Server on port %d', [APort]));
  LServer := TIdHTTPWebBrokerBridge.Create(nil);

  ListenersWhiteList := TController.GetListenersIPs;
  ProvidersWhiteList := TController.GetProvidersIPs;

  if (Length(ListenersWhiteList) = 0) then
  begin
    Writeln('The listener IP whitelist is empty. No subscriptions will succeed.');
  end
  else
  begin
    Writeln('Allowed IPs for listeners:');
    for Item in ListenersWhiteList do
      Writeln(Item);
  end;
  if (Length(ProvidersWhiteList) = 0) then
  begin
    Writeln('The provider IP whitelist is empty. No one will succeed to enqueue the data.');
  end
  else
  begin
    Writeln('Allowed IPs for data providers:');

    for Item in ProvidersWhiteList do
      Writeln(Item);
  end;

  numberOfListeners := Config.Listeners.Count;
  if numberOfListeners = 0 then
    Writeln('No subscriptions found in the config file.')
  else
    Writeln(inttostr(numberOfListeners) + ' subscription(s) found.');

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
    // ConfigUpdated := TAQConfig.Create(Config.Port, Config.ListenersIPs, Config.ProvidersIPs, TController.GetListeners());
    // jo := Mapper.ObjectToJSONObject(ConfigUpdated);
    // OutFile := GetAvailablePath(ConfigFileName, '-YYYY-mm-dd_hh_nn_ss');
    // SaveConfigToFile(OutFile, jo.ToString);
    LServer.Free;
    // jo.DisposeOf;
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
    Config := Mapper.JSONObjectToObject<TAQConfig>(JsonConfig);
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
