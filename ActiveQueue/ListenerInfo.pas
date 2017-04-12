unit ListenerInfo;

interface

uses ObjectsMappers;

type

  /// <summary> An ADT that contains complete information about
  /// a listener (i.e. a subscriptor)</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TListenerInfo = class
  strict private
    FToken: String;
    FIP: String;
    FPort: Integer;
    FPath: String;
  public
    constructor Create();
    [MapperJSONSer('token')]
    property token: String read FToken write FToken;
    [MapperJSONSer('ip')]
    property IP: String read FIP write FIP;
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer('path')]
    property Path: String read FPath write FPath;
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
end;

function TListenerInfoBuilder.SetPath(
  const APath: String): TListenerInfoBuilder;
begin
  FPath := APath;
end;

function TListenerInfoBuilder.SetPort(
  const APort: Integer): TListenerInfoBuilder;
begin
  FPort := APort;
end;

function TListenerInfoBuilder.SetToken(
  const AToken: String): TListenerInfoBuilder;
begin
  FToken := AToken;
end;

end.
