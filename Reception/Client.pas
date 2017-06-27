unit Client;

interface

uses ObjectsMappers;

type

  /// <summary>An ADT for representing a client.
  /// A client is defined by its ip address and a token.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TClient = class(TObject)
  strict private
    FToken: String;
    FIP: String;
  public
    [MapperJSONSer('ip')]
    property IP: String read FIP write FIP;
    [MapperJSONSer('token')]
    property Token: String read FToken write FToken;
    constructor Create(const IP: String; const Token: String); overload;
    constructor Create(); overload;
  end;

implementation

{ TClient }

constructor TClient.Create(const IP, Token: String);
begin
  FIP := IP;
  FToken := Token;
end;

constructor TClient.Create;
begin
  Create('', '');
end;

end.
