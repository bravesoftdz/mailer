unit ConsumerConfig;

interface

uses
  System.JSON, JsonableInterface;

type
  TConsumerConfig = class(TInterfacedObject, JSonable)
  strict private
  const
    PORT_KEY = 'port';
    BACKEND_IP_KEY = 'data-provider-ip';
    BACKEND_PORT_KEY = 'data-provider-port';
    SUBSCRIPTION_STATUS_KEY = 'subscription-status';
    SUBSCRIPTION_TOKEN_KEY = 'subscription-token';

  var
    FPort: Integer;
    FProviderIP: String;
    FProviderPort: Integer;
    FSubscriptionStatus: Boolean;
    FSubscriptionToken: String;

  public
    constructor Create(const Port: Integer; const BackEndIp: String; const BackEndPort: Integer;
      const SubscriptionStatus: Boolean; const SubscriptionToken: String); Overload;
    constructor Create(const Json: TJsonObject); Overload;
    destructor Destroy(); override;
    function ToJson(): TJsonObject;
    property Port: Integer read Fport;
    property ProviderIp: String read FProviderIp;
    property ProviderPort: Integer read FProviderPort;
    property SubscriptionStatus: Boolean read FSubscriptionStatus;
    property SubscriptionToken: String read FSubscriptionToken;

  end;

implementation

uses
  System.SysUtils;

{ TConsumerConfig }

constructor TConsumerConfig.Create(const Json: TJsonObject);
var
  BoolOptional: TJsonValue;
  StrOptional: TJsonValue;
begin
  FPort := strtoint(Json.GetValue(PORT_KEY).Value);
  FProviderPort := strtoint(Json.GetValue(BACKEND_PORT_KEY).Value);
  FProviderIP := Json.GetValue(BACKEND_IP_KEY).Value;
  BoolOptional := Json.GetValue(SUBSCRIPTION_STATUS_KEY);
  if (BoolOptional <> nil) AND (BoolOptional is TJSONBool) then
    FSubscriptionStatus := (BoolOptional as TJSONBool).AsBoolean
  else
    FSubscriptionStatus := False;
  BoolOptional.DisposeOf;
  StrOptional := Json.GetValue(SUBSCRIPTION_TOKEN_KEY);
  if StrOptional <> nil then
    FSubscriptionToken := StrOptional.Value
  else
    FSubscriptionToken := '';
  StrOptional.DisposeOf;
end;

constructor TConsumerConfig.Create(const Port: Integer; const BackEndIp: String;
  const BackEndPort: Integer; const SubscriptionStatus: Boolean; const SubscriptionToken: String);
begin
  FPort := Port;
  FProviderIP := BackEndIp;
  FProviderPort := BackEndPort;
  FSubscriptionStatus := SubscriptionStatus;
  FSubscriptionToken := SubscriptionToken;
end;

destructor TConsumerConfig.Destroy;
begin

  inherited;
end;

function TConsumerConfig.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TJsonPair.Create(PORT_KEY, TJsonNumber.Create(FPort)));
  Result.AddPair(TJsonPair.Create(BACKEND_IP_KEY, FProviderIP));
  Result.AddPair(TJsonPair.Create(BACKEND_PORT_KEY, TJsonNumber.Create(FProviderPort)));
  Result.AddPair(TJsonPair.Create(SUBSCRIPTION_STATUS_KEY, TJsonBool.Create(FSubscriptionStatus)));
  Result.AddPair(TJsonPair.Create(SUBSCRIPTION_TOKEN_KEY, FSubscriptionToken));
end;

end.
