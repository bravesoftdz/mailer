unit DispatcherController;

interface

uses
  MVCFramework, MVCFramework.Commons, Model;

type

  [MVCPath('/')]
  TDispatcherController = class(TMVCController)
  strict private
    class var Model: TModel;

  public
    [MVCPath('/')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

    [MVCPath('/hellos/($FirstName)')]
    [MVCHTTPMethod([httpGET])]
    procedure GetSpecializedHello(const FirstName: String);

    class procedure Setup();
    class procedure TearDown();
    class procedure LoadConfigFromFile(const FilePath: String);
    class function GetPort(): Integer;
    class function GetClientIps(): TArray<String>;

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, System.JSON, System.IOUtils, System.SysUtils,
  DispatcherConfig;

procedure TDispatcherController.Index;
begin
  // use Context property to access to the HTTP request and response
  Render('Hello World');
end;

class procedure TDispatcherController.LoadConfigFromFile(const FilePath: String);
var
  Content, ErrorMessage: String;
  Json: TJsonObject;
  Config: TDispatcherConfig;
begin
  if Not(TFile.Exists(FilePath)) then
    raise Exception.Create('Error: config file ' + FilePath + ' not found.');
  ErrorMessage := '';
  Content := TFile.ReadAllText(FilePath);
  try
    Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONObject;
  except
    on E: Exception do
    begin
      ErrorMessage := E.message;
      Json := nil;
    end;
  end;
  if Json <> nil then
  begin
    try
      try
        Config := TDispatcherConfig.CreateFromJson(Json);
      except
        on E: Exception do
        begin
          ErrorMessage := ErrorMessage + ', ' + E.Message;
          Config := nil;
        end;

      end;
    finally
      Json.DisposeOf;
    end;

  end;
  if Config <> nil then
  begin
    Model.Config := Config;
    Config.DisposeOf;
  end;
  if not(ErrorMessage.IsEmpty) then
    raise Exception.Create(ErrorMessage);
end;

class function TDispatcherController.GetClientIps: TArray<String>;
begin
  Result := Model.GetClientIps();
end;

class function TDispatcherController.GetPort: Integer;
begin
  Result := Model.GetPort();
end;

procedure TDispatcherController.GetSpecializedHello(const FirstName: String);
begin
  Render('Hello ' + FirstName);
end;

procedure TDispatcherController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TDispatcherController.OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

class procedure TDispatcherController.Setup;
begin
  Model := TModel.Create();
end;

class procedure TDispatcherController.TearDown;
begin
  Model.DisposeOf;
end;

initialization

TDispatcherController.Setup();

finalization

TDispatcherController.TearDown();

end.
