unit ConsumerConfig;

interface

uses
  System.JSON;

type
  TConsumerConfig = class(TObject)
  strict private
  const
    PORT_KEY = 'port';
    BACKEND_IP_KEY = 'data-provider-ip';
    BACKEND_PORT_KEY = 'data-provider-port';

  var
    FPort: Integer;
    FProviderIP: String;
    FProviderPort: Integer;

  public
    constructor Create(const Port: Integer); Overload;
    constructor Create(const Json: TJsonObject); Overload;
    destructor Destroy(); override;
    property Port: Integer read Fport;
    property ProviderIp: String read FProviderIp;
    property ProviderPort: Integer read FProviderPort;

  end;

implementation

uses
  System.SysUtils;

{ TConsumerConfig }

constructor TConsumerConfig.Create(const Port: Integer);
begin
  FPort := Port;
end;

constructor TConsumerConfig.Create(const Json: TJsonObject);
begin
  FPort := strtoint(Json.GetValue(PORT_KEY).Value);
  FProviderPort := strtoint(Json.GetValue(BACKEND_PORT_KEY).Value);
  FProviderIP := Json.GetValue(BACKEND_IP_KEY).Value;
end;

destructor TConsumerConfig.Destroy;
begin

  inherited;
end;

end.
