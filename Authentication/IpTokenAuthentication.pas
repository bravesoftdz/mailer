unit IpTokenAuthentication;

interface

uses
  System.Generics.Collections, System.Classes;

type
  TIpTokenAuthentication = class(TObject)
  strict private
  var
    /// Map from tokens to ips.
    /// Tokens are unique among all clients.
    FItems: TDictionary<String, String>;
  public
    function isAuthorised(const IP: String; const Token: String): Boolean;
    function GetIPs(): TArray<String>;
    constructor Create(const IPs, Tokens: TArray<String>);
    destructor Destroy(); override;

  end;

implementation

uses
  System.SysUtils;

{ TIpTokenAuthentication }

constructor TIpTokenAuthentication.Create(const IPs, Tokens: TArray<String>);
var
  I, L: Integer;
begin
  L := Length(IPs);
  if Length(Tokens) <> L then
    raise Exception.Create('List of ips and list of tokens must have the same length.');
  FItems := TDictionary<String, String>.Create();
  for I := 0 to L - 1 do
  begin
    FItems.Add(Tokens[I], IPs[i]);
  end;
end;

destructor TIpTokenAuthentication.Destroy;
begin
  FItems.DisposeOf;
  inherited;
end;

function TIpTokenAuthentication.GetIPs: TArray<String>;
var
  L, I: Integer;
  Item: String;
begin
  Result := TArray<String>.Create();
  L := FItems.Count;
  SetLength(Result, L);
  I := 0;
  for Item in FItems.Values do
  begin
    Result[I] := Item;
    I := I + 1;
  end;
end;

function TIpTokenAuthentication.isAuthorised(const IP, Token: String): Boolean;
begin
  Writeln(Format('ip: %s, token: %s', [IP, Token]));
  if FItems.ContainsKey(Token) then
  begin
    Writeln(Format('token should correspond to %s', [FItems[Token]]));
  end
  else
    Writeln('token is not recognized.');
  Result := FItems.ContainsKey(Token) AND (FItems[Token] = IP);
end;

end.
