unit IpAuthentication;

interface

uses
  System.Classes, System.Generics.Collections;

type
  IAuthentication = interface(IInvokable)
    ['{B5E132F3-D321-48D1-88E9-DFEF2C248381}']
    function isAuthorised(const IP: String): Boolean;
    function GetIPs(): TArray<String>;
  end;

type
  TIpAuthentication = class(TInterfacedObject, IAuthentication)
  strict private
  var
    /// Collection of allowed ip addresses.
    /// A hash set data type is more suitable, but Delphi has no such type.
    /// The keys of this dictionary are ip addresses which are considered to be authorized,
    /// while values of this dictionary are irrelevant.
    FItems: TDictionary<String, Boolean>;
  public
    function isAuthorised(const IP: String): Boolean;
    function GetIPs(): TArray<String>;
    constructor Create(const Ips: String);
    destructor Destroy(); override;
  end;

implementation

uses
  System.StrUtils, System.Types, System.SysUtils;

{ TIpAuthentication }

constructor TIpAuthentication.Create(const Ips: String);
var
  Items: TStringDynArray;
  Item: String;
begin
  FItems := TDictionary<String, Boolean>.Create();
  Items := SplitString(IPs, ',');
  for Item in Items do
    Fitems.Add(Item.Trim([' ']), True);
  SetLength(Items, 0);
end;

destructor TIpAuthentication.Destroy;
begin
  FItems.Clear;
  FItems.DisposeOf;
  inherited;
end;

function TIpAuthentication.GetIPs: TArray<String>;
var
  L, I: Integer;
  Item: String;
begin
  Result := TArray<String>.Create();
  L := FItems.Count;
  SetLength(Result, L);
  I := 0;
  for Item in FItems.Keys do
  begin
    Result[I] := Item;
    I := I + 1;
  end;
end;

function TIpAuthentication.isAuthorised(const IP: String): Boolean;
begin
  Result := FItems.ContainsKey(IP);
end;

end.
