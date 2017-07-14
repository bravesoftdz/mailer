unit Client;

interface

uses ObjectsMappers, System.JSON;

type

  /// <summary>An ADT for representing a client.
  /// A client is defined by its ip address and a token.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TClient = class(TObject)
  strict private
  const
    TOKEN_KEY = 'token';
    IP_KEY = 'ip';

  var
    FToken: String;
    FIP: String;
  public
    [MapperJSONSer(IP_KEY)]
    property IP: String read FIP write FIP;

    [MapperJSONSer(TOKEN_KEY)]
    property Token: String read FToken write FToken;

    constructor Create(const IP: String; const Token: String); overload;
    constructor Create(); overload;
    function Clone(): TClient;

    function ToJson(): TJsonObject;
  end;

implementation

{ TClient }

constructor TClient.Create(const IP, Token: String);
begin
  FIP := IP;
  FToken := Token;
end;

function TClient.Clone: TClient;
begin
  Result := TClient.Create(FIP, FToken);
end;

constructor TClient.Create;
begin
  Create('', '');
end;

function TClient.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  Result.AddPair(IP_KEY, FIP);
  Result.AddPair(TOKEN_KEY, FToken)
end;

end.
