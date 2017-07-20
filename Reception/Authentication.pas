unit Authentication;

interface

uses System.Generics.Collections, Client;

type
  TAuthentication = class(TObject)
  strict private
    FItems: TDictionary<String, TClient>;

  public
    constructor Create(Items: TObjectList<TClient>);
    destructor Destroy(); override;
    /// <summary> Return true if the list of clients contains a one with given IP and token.
    /// Otherwise, return false.
    /// </summary>
    function isAuthenticated(const item: TClient): Boolean;

    /// <summary> return a list of clients</summary>
    function GetClients(): TObjectList<TClient>;

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
    FItems.add(Token, Item.Clone);
  end;

end;

destructor TAuthentication.Destroy;
var
  Key: String;
begin
  for Key in FItems.Keys do
    FItems[Key].DisposeOf;
  FItems.Clear;
  FItems.DisposeOf;
  inherited;
end;

function TAuthentication.GetClients: TObjectList<TClient>;
var
  Client: TClient;
begin
  Result := TObjectList<TClient>.Create;
  for Client in FItems.Values do
  begin
    Result.Add(TClient.Create(Client.IP, Client.Token));
  end;

end;

function TAuthentication.isAuthenticated(const item: TClient): Boolean;
begin
  Result := FItems.ContainsKey(item.Token) AND (FItems[Item.Token].IP = Item.IP);
end;

end.
