unit ListenerInfo;

interface

uses ObjectsMappers, JsonableInterface, System.JSON;

type

  /// <summary> An ADT that contains complete information about
  /// a listener (i.e. a subscriptor)</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TListenerInfo = class(TInterfacedObject, JSonable)
  strict private
  const
    /// names of the keys in order to transform the instance into a json or construct it from a json.
    TOKEN_KEY_NAME = 'token';
    IP_KEY_NAME = 'ip';
    PORT_KEY_NAME = 'port';

  var
    FToken: String;
    FIP: String;
    FPort: Integer;
    FPath: String;
  public
    constructor Create();
    [MapperJSONSer(TOKEN_KEY_NAME)]
    property token: String read FToken write FToken;
    [MapperJSONSer(IP_KEY_NAME)]
    property IP: String read FIP write FIP;
    [MapperJSONSer(PORT_KEY_NAME)]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer('path')]
    property Path: String read FPath write FPath;

    function ToJson(): TJsonObject;
  end;

type
  TListenerInfoBuilder = class
  strict private
    FToken: String;
    FIP: String;
    FPort: Integer;
    FPath: String;
  public
    constructor Create();
    function SetToken(const AToken: String): TListenerInfoBuilder;
    function SetIP(const AnIP: String): TListenerInfoBuilder;
    function SetPort(const APort: Integer): TListenerInfoBuilder;
    function SetPath(const APath: String): TListenerInfoBuilder;
    function Build(): TListenerInfo;

  end;

implementation

{ TListenerInfo }

constructor TListenerInfo.Create;
begin
  FToken := '';
  FIP := '';
  FPort := 0;
  FPath := '';
end;

function TListenerInfo.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TOKEN_KEY_NAME, FToken);
  Result.AddPair(IP_KEY_NAME, FIp);
  Result.AddPair(TJsonPair.Create(PORT_KEY_NAME, TJsonNumber.Create(FPort)));
end;

{ TListenerInfoBuilder }

function TListenerInfoBuilder.Build: TListenerInfo;

begin
  Result := TListenerInfo.Create();
  Result.token := FToken;
  Result.IP := FIP;
  Result.Port := FPort;
  Result.Path := FPath;
end;

constructor TListenerInfoBuilder.Create;
begin
  /// impose the default values
  FPort := 0;
  FPath := '';
  FToken := '';
  FToken := '';
end;

function TListenerInfoBuilder.SetIP(const AnIP: String): TListenerInfoBuilder;
begin
  FIP := AnIP;
  Result := Self;
end;

function TListenerInfoBuilder.SetPath(
  const APath: String): TListenerInfoBuilder;
begin
  FPath := APath;
  Result := Self;
end;

function TListenerInfoBuilder.SetPort(
  const APort: Integer): TListenerInfoBuilder;
begin
  FPort := APort;
  Result := Self;
end;

function TListenerInfoBuilder.SetToken(
  const AToken: String): TListenerInfoBuilder;
begin
  FToken := AToken;
  Result := Self;
end;

end.
