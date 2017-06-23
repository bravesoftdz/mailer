unit Model;

interface

uses
  DispatcherConfig, IpAuthentication, DispatcherResponce, DispatcherEntry;

type
  TModel = class(TObject)

  strict private
  var
    FConfig: TDispatcherConfig;
    FAuthentication: IAuthentication;

    function GetConfig(): TDispatcherConfig;
    procedure SetConfig(const Config: TDispatcherConfig);

  public
    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;
    function Elaborate(const Entry: TDispatcherEntry): TDispatcherResponce;
    property Config: TDispatcherConfig read GetConfig write SetConfig;
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

{ TModel }

constructor TModel.Create;
begin

end;

destructor TModel.Destroy;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  FAuthentication := nil;
  inherited;
end;

function TModel.Elaborate(const Entry: TDispatcherEntry): TDispatcherResponce;
begin
  { TODO 1 : Implement this method }
end;

function TModel.GetBackEndIp: String;
begin
  Result := FConfig.BackEndIp
end;

function TModel.GetBackEndPort: Integer;
begin
  Result := FConfig.BackEndPort
end;

function TModel.GetClientIps: TArray<String>;
begin
  Result := FAuthentication.GetIps();
end;

function TModel.GetConfig: TDispatcherConfig;
begin
  Result := TDispatcherConfig.Create(FConfig.Port, FConfig.ClientIPs, FConfig.BackEndIp, FConfig.BackEndPort);
end;

function TModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port;
end;

function TModel.isAuthorised(const IP: String): Boolean;
begin
  Result := (FAuthentication <> nil) AND FAuthentication.isAuthorised(IP);
end;

procedure TModel.SetConfig(const Config: TDispatcherConfig);
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  FConfig := TDispatcherConfig.Create(Config.Port, Config.ClientIPs, Config.BackEndIp, Config.BackEndPort);
  FAuthentication := TIpAuthentication.Create(Config.ClientIPs);

end;

end.
