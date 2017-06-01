unit Authentication;

interface

uses System.Generics.Collections, Client;

type
  TAuthentication = class
  strict private
    FItems: TDictionary<String, TClient>;

  public
    constructor Create(Items: TObjectList<TClient>);
    destructor Destroy();
    /// <summary> Return true if the list of clients contains a one with given IP and token.
    /// Otherwise, return false.
    /// </summary>
    function isAuthenticated(item: TClient): Boolean;

  end;

implementation

uses
  System.SysUtils;

{ TAuthentication }

constructor TAuthentication.Create(Items: TObjectList<TClient>);
var
  Item: TClient;
  Token: String;
begin
  FItems := TDictionary<String, TClient>.Create();
  for Item in Items do
  begin
    Token := Item.Token;
    if FItems.ContainsKey(Token) then
      raise Exception.Create('Dublicate token: every token must be registered not more than once.');
    FItems.add(Token, TClient.Create(Item.IP, Token));
  end;

end;

destructor TAuthentication.Destroy;
begin
  FItems.Clear;
  FItems.DisposeOf;

end;

function TAuthentication.isAuthenticated(item: TClient): Boolean;
begin
  Result := FItems.ContainsKey(item.Token) AND (FItems[Item.Token].IP = Item.IP);
end;

end.
