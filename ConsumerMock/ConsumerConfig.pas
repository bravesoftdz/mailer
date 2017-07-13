unit ConsumerConfig;

interface

uses
  System.JSON, JsonableInterface, Configuration;

type
  TConsumerConfig = class(TConfiguration, JSonable)
  strict private
  const
    PORT_KEY = 'port';
    BACKEND_IP_KEY = 'data-provider-ip';
    BACKEND_PORT_KEY = 'data-provider-port';
    SUBSCRIPTION_STATUS_KEY = 'subscription-status';
    SUBSCRIPTION_TOKEN_KEY = 'subscription-token';
    // number of items to request from the data server at once
    BLOCK_SIZE_KEY = 'number-of-items';
    DEFAULT_BLOCK_SIZE_VALUE = 5;

  var
    FPort: Integer;
    FProviderIP: String;
    FProviderPort: Integer;
    FSubscriptionStatus: Boolean;
    FSubscriptionToken: String;
    FBlockSize: Integer;

  public
    constructor Create(const Port: Integer; const BackEndIp: String; const BackEndPort: Integer;
      const SubscriptionStatus: Boolean; const SubscriptionToken: String; const BlockSize: Integer);
    class function CreateFromJson(const Json: TJsonObject): TConsumerConfig;
    function ToJson(): TJsonObject;
    property Port: Integer read Fport;
    property ProviderIp: String read FProviderIp;
    property ProviderPort: Integer read FProviderPort;
    property IsSubscribed: Boolean read FSubscriptionStatus;
    property SubscriptionToken: String read FSubscriptionToken;
    property BlockSize: Integer read FBlockSize;

    function Clone(): TConsumerConfig;

  end;

implementation

uses
  System.SysUtils;

{ TConsumerConfig }

class function TConsumerConfig.CreateFromJson(const Json: TJsonObject): TConsumerConfig;
var
  Port, ProviderPort, BlockSize: Integer;
  ProviderIP, SubscriptionToken: String;
  SubscriptionStatus: Boolean;

begin
  Port := GetIntValue(Json, PORT_KEY, -1);
  ProviderPort := GetIntValue(Json, BACKEND_PORT_KEY, -1);
  ProviderIP := GetStrValue(Json, BACKEND_IP_KEY, '');
  SubscriptionStatus := GetBoolValue(Json, SUBSCRIPTION_STATUS_KEY, False);
  SubscriptionToken := GetStrValue(Json, SUBSCRIPTION_TOKEN_KEY, '');
  BlockSize := GetIntValue(Json, BLOCK_SIZE_KEY, DEFAULT_BLOCK_SIZE_VALUE);
  Result := TConsumerConfig.Create(Port, ProviderIP, ProviderPort, SubscriptionStatus, SubscriptionToken, BlockSize);
end;

function TConsumerConfig.Clone: TConsumerConfig;
begin
  Result := TConsumerConfig.Create(FPort, FProviderIP, FProviderPort, FSubscriptionStatus, FSubscriptionToken, FBlockSize);
end;

constructor TConsumerConfig.Create(const Port: Integer; const BackEndIp: String;
  const BackEndPort: Integer; const SubscriptionStatus: Boolean; const SubscriptionToken: String; const BlockSize: Integer);
begin
  FPort := Port;
  FProviderIP := BackEndIp;
  FProviderPort := BackEndPort;
  FSubscriptionStatus := SubscriptionStatus;
  FSubscriptionToken := SubscriptionToken;
  FBlockSize := BlockSize;
end;

function TConsumerConfig.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TJsonPair.Create(PORT_KEY, TJsonNumber.Create(FPort)));
  Result.AddPair(TJsonPair.Create(BACKEND_IP_KEY, FProviderIP));
  Result.AddPair(TJsonPair.Create(BACKEND_PORT_KEY, TJsonNumber.Create(FProviderPort)));
  Result.AddPair(TJsonPair.Create(SUBSCRIPTION_STATUS_KEY, TJsonBool.Create(FSubscriptionStatus)));
  Result.AddPair(TJsonPair.Create(SUBSCRIPTION_TOKEN_KEY, FSubscriptionToken));
  Result.AddPair(TJsonPair.Create(BLOCK_SIZE_KEY, TJsonNumber.Create(FBlockSize)));
end;

end.
