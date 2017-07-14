unit Consumer;

interface

uses ObjectsMappers, JsonableInterface, System.JSON;

type

  /// <summary> An ADT that contains complete information about
  /// a listener (i.e. a subscriptor)</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TConsumer = class(TInterfacedObject, JSonable)
  strict private
  const
    /// names of the keys in order to transform the instance into a json or construct it from a json.
    TOKEN_KEY = 'token';
    IP_KEY = 'ip';
    PORT_KEY = 'port';
    CATEGORY_KEY = 'category';

  var
    FToken: String;
    FIP: String;
    FPort: Integer;
    FCategory: String;
  public
    constructor Create(); overload;
    constructor Create(const IP: String; const Port: Integer; const Token, Category: String); overload;
    [MapperJSONSer(TOKEN_KEY)]
    property token: String read FToken write FToken;
    [MapperJSONSer(IP_KEY)]
    property IP: String read FIP write FIP;
    [MapperJSONSer(PORT_KEY)]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer(CATEGORY_KEY)]
    property Category: String read FCategory write FCategory;

    function ToJson(): TJsonObject;
    function Clone(): TConsumer;
  end;

type
  TConsumerBuilder = class(TObject)
  strict private
    FToken: String;
    FIP: String;
    FPort: Integer;
    FCategory: String;
  public
    constructor Create();
    function SetToken(const AToken: String): TConsumerBuilder;
    function SetIP(const AnIP: String): TConsumerBuilder;
    function SetPort(const APort: Integer): TConsumerBuilder;
    function SetCategory(const ACategory: String): TConsumerBuilder;
    function Build(): TConsumer;
  end;

implementation

{ TListenerInfo }

constructor TConsumer.Create;
begin
  Create('', 0, '', '');
end;

function TConsumer.Clone: TConsumer;
begin
  Result := TConsumer.Create(FIP, FPort, FToken, FCategory);
end;

constructor TConsumer.Create(const IP: String; const Port: Integer; const Token, Category: String);
begin
  FToken := Token;
  FIP := IP;
  FPort := Port;
  FCategory := Category;
end;

function TConsumer.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TOKEN_KEY, FToken);
  Result.AddPair(IP_KEY, FIp);
  Result.AddPair(CATEGORY_KEY, FCategory);
  Result.AddPair(TJsonPair.Create(PORT_KEY, TJsonNumber.Create(FPort)));
end;

{ TListenerInfoBuilder }

function TConsumerBuilder.Build: TConsumer;

begin
  Result := TConsumer.Create(FIP, FPort, FToken, FCategory);
end;

constructor TConsumerBuilder.Create;
begin
  /// impose the default values
  FPort := 0;
  FCategory := '';
  FToken := '';
  FIP := '';
end;

function TConsumerBuilder.SetIP(const AnIP: String): TConsumerBuilder;
begin
  FIP := AnIP;
  Result := Self;
end;

function TConsumerBuilder.SetCategory(const ACategory: String): TConsumerBuilder;
begin
  FCategory := ACategory;
  Result := Self;
end;

function TConsumerBuilder.SetPort(const APort: Integer): TConsumerBuilder;
begin
  FPort := APort;
  Result := Self;
end;

function TConsumerBuilder.SetToken(const AToken: String): TConsumerBuilder;
begin
  FToken := AToken;
  Result := Self;
end;

end.
