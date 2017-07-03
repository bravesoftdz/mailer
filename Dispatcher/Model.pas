unit Model;

interface

uses
  DispatcherConfig, IpAuthentication, DispatcherResponce, DispatcherEntry,
  ProviderFactory;

type
  TModel = class(TObject)

  strict private
  var
    FConfig: TDispatcherConfig;
    FAuthentication: IAuthentication;
    FFactory: TProviderFactory;

    function GetConfig(): TDispatcherConfig;
    procedure SetConfig(const Config: TDispatcherConfig);

  public
    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;
    /// <summary>Split the entry into a set of single actions and pass them to the back end server.</summary>
    function Elaborate(const Entry: TDispatcherEntry): TDispatcherResponce;
    property Config: TDispatcherConfig read GetConfig write SetConfig;
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

uses
  System.Generics.Collections, Provider, VenditoriSimple, SoluzioneAgenti;

{ TModel }

constructor TModel.Create;
var
  Providers: TObjectList<TProvider>;
begin
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
  Providers.Clear;
  Providers.DisposeOf;
end;

destructor TModel.Destroy;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  FAuthentication := nil;
  FFactory.DisposeOf;
  inherited;
end;

function TModel.Elaborate(const Entry: TDispatcherEntry): TDispatcherResponce;
begin
  Result := TDispatcherResponce.Create(False, 'Dispatcher is not implemented yet');
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
