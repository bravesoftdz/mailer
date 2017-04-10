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

implementation

{ TListenerInfo }

constructor TListenerInfo.Create;
begin
  FToken := '';
  FIP := '';
  FPort := 0;
  FPath := '';
end;

end.
