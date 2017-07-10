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
    TOKEN_KEY = 'token';
    IP_KEY = 'ip';
    PORT_KEY = 'port';
    PATH_KEY = 'path';

  var
    FToken: String;
    FIP: String;
    FPort: Integer;
    FPath: String;
  public
    constructor Create(); overload;
    constructor Create(const IP: String; const Port: Integer; const Token, Path: String); overload;
    [MapperJSONSer(TOKEN_KEY)]
    property token: String read FToken write FToken;
    [MapperJSONSer(IP_KEY)]
    property IP: String read FIP write FIP;
    [MapperJSONSer(PORT_KEY)]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer(PATH_KEY)]
    property Path: String read FPath write FPath;

    function ToJson(): TJsonObject;
    function Clone(): TListenerInfo;
  end;

type
  TListenerInfoBuilder = class(TObject)
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
  Create('', 0, '', '');
end;

function TListenerInfo.Clone: TListenerInfo;
begin
  Result := TListenerInfo.Create(FIP, FPort, FToken, FPath);
end;

constructor TListenerInfo.Create(const IP: String; const Port: Integer; const Token, Path: String);
begin
  FToken := Token;
  FIP := IP;
  FPort := Port;
  FPath := Path;
end;

function TListenerInfo.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  Result.AddPair(TOKEN_KEY, FToken);
  Result.AddPair(IP_KEY, FIp);
  Result.AddPair(TJsonPair.Create(PORT_KEY, TJsonNumber.Create(FPort)));
end;

{ TListenerInfoBuilder }

function TListenerInfoBuilder.Build: TListenerInfo;

begin
  Result := TListenerInfo.Create(FIP, FPort, FToken, FPath);
  // Result.token := FToken;
  // Result.IP := FIP;
  // Result.Port := FPort;
  // Result.Path := FPath;
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
