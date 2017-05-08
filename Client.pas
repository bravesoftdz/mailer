unit Client;

interface

type
  /// <summary>An ADT for representing a client.
  /// A client is defined by its ip address and a token.</summary>
  TClient = class
  strict private
    FToken: String;
    FIP: String;
  public
    property IP: String read FIP;
    property Token: String read FToken;
    constructor Create(const IP: String; const Token: String);
  end;

implementation

{ TClient }

constructor TClient.Create(const IP, Token: String);
begin
  FIP := IP;
  FToken := Token;
end;

end.
