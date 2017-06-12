unit Model;

interface

uses
  ConsumerConfig, ActiveQueueResponce, JsonSaver;

type
  TConsumerModel = class(TObject)
  strict private
    /// <summary>A path to the config. file</summary>
    FConfigFilePath: String;
    FConfig: TConsumerConfig;
    FFileSaver: TJsonSaver;

  public
    function GetPort(): Integer;
    procedure LoadConfigFromFile(const FilePath: String);
    /// <summary>Get the configuation of the server.</summary>
    function GetConfig(): TConsumerConfig;
    /// <summary>Send a subscription request to the data provider server notifications</summary>
    function Subscribe(): TActiveQueueResponce;
    /// <summary>Send a request to cancel the subscription from the data provider notifications</summary>
    function Unsubscribe(const Token: String): TActiveQueueResponce;

    constructor Create();
    destructor Destroy(); override;

  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.JSON, MVCFramework.RESTAdapter,
  ActiveQueueAPI, SubscriptionData;

{ TConsumerModel }

constructor TConsumerModel.Create;
begin
  FFileSaver := TJsonSaver.Create;
end;

destructor TConsumerModel.Destroy;
begin
  if FConfig <> nil then
    FConfig.DisposeOf;
  FFileSaver.DisposeOf;
  inherited;
end;

function TConsumerModel.GetConfig: TConsumerConfig;
begin
  if FConfig <> nil then
    Result := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIp, FConfig.ProviderPort, FConfig.SubscriptionStatus, FConfig.SubscriptionToken);
end;

function TConsumerModel.GetPort: Integer;
begin
  Result := FConfig.Port;
end;

procedure TConsumerModel.LoadConfigFromFile(const FilePath: String);
var
  Content: String;
  Json: TJsonObject;
begin
  if not TFile.Exists(FilePath) then
    raise Exception.Create('Config file ' + FilePath + ' is not found.');
  FConfigFilePath := FilePath;
  Content := TFile.ReadAllText(FilePath);
  Json := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(Content), 0) as TJSONObject;
  if FConfig <> nil then
    FConfig.DisposeOf;
  FConfig := TConsumerConfig.Create(Json);
  Json.DisposeOf;
end;

function TConsumerModel.Subscribe: TActiveQueueResponce;
var
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
  SubscriptionData: TSubscriptionData;
  Responce: TActiveQueueResponce;
  ConfigNew: TConsumerConfig;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  /// the first argument (correponding to an ip at which the consumer operates) gets
  /// ignored by the data provider server since the ip gets extracted from the http request
  /// that the consumer sends to the data provider.
  SubscriptionData := TSubscriptionData.Create('', '', FConfig.Port, '');
  Result := Server.Subscribe(SubscriptionData);
  if Result.status then
  begin
    ConfigNew := TConsumerConfig.Create(FConfig.Port, FConfig.ProviderIP, FConfig.ProviderPort, Responce.Status, Responce.Token);
    FConfig.DisposeOf;
    FConfig := ConfigNew;
    FFileSaver.Save(FConfigFilePath, FConfig);
  end;

  // SubscriptionData.DisposeOf;
  Server := nil;
  Adapter := nil;
end;

function TConsumerModel.Unsubscribe(const Token: String): TActiveQueueResponce;
var
  Adapter: TRestAdapter<IActiveQueueAPI>;
  Server: IActiveQueueAPI;
begin
  Adapter := TRestAdapter<IActiveQueueAPI>.Create();
  Server := Adapter.Build(FConfig.ProviderIp, FConfig.ProviderPort);
  Result := Server.UnSubscribe(Token);
end;

end.
