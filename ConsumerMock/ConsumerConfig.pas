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
    /// extract the key value from the json object as an integer. In case of failure, the dafualt value
    /// is returned.
    function GetIntValue(const jo: TJsonObject; const key: String; const DefaultValue: Integer): Integer;

    /// extract the key value from the json object as a string. In case of failure, the dafualt value
    /// is returned.
    function GetStrValue(const jo: TJsonObject; const key: String; const DefaultValue: String): String;

    /// extract the key value from the json object as a boolean. In case of failure, the dafualt value
    /// is returned.
    function GetBoolValue(const jo: TJsonObject; const key: String; const DefaultValue: Boolean): Boolean;

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
begin
  FPort := GetIntValue(Json, PORT_KEY, -1);
  FProviderPort := GetIntValue(Json, BACKEND_PORT_KEY, -1);
  FProviderIP := GetStrValue(Json, BACKEND_IP_KEY, '');
  FSubscriptionStatus := GetBoolValue(Json, SUBSCRIPTION_STATUS_KEY, False);
  FSubscriptionToken := GetStrValue(Json, SUBSCRIPTION_TOKEN_KEY, '');
end;

function TConsumerConfig.GetBoolValue(const jo: TJsonObject; const key: String;
  const DefaultValue: Boolean): Boolean;
var
  value: TJsonValue;
begin
  value := jo.GetValue(key);
  if (Value <> nil) AND (Value is TJsonBool) then
  begin
    try
      Result := (value as TJSONBool).AsBoolean;
    except
      on E: Exception do
        Result := DefaultValue;
    end;
  end
  else
    Result := DefaultValue;
end;

function TConsumerConfig.GetIntValue(const jo: TJsonObject; const key: String;
  const DefaultValue: Integer): Integer;
var
  value: TJsonValue;
begin
  value := jo.GetValue(key);
  if Value <> nil then
  begin
    try
      Result := strtoint(value.Value);
    except
      on E: Exception do
        Result := DefaultValue;
    end;
  end
  else
    Result := DefaultValue;
end;

function TConsumerConfig.GetStrValue(const jo: TJsonObject; const key,
  DefaultValue: String): String;
var
  value: TJsonValue;
begin
  value := jo.GetValue(key);
  if Value <> nil then
  begin
    try
      Result := value.Value;
    except
      on E: Exception do
        Result := DefaultValue;
    end;
  end
  else
    Result := DefaultValue;
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
