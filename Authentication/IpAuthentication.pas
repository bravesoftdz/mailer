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
    FItems: TList<String>;
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
  FItems := TList<String>.Create();
  Items := SplitString(IPs, ',');
  for Item in Items do
    Fitems.Add(Item.Trim([' ']));
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
  I, L: Integer;
begin
  Result := TArray<String>.Create();
  L := FItems.Count;
  SetLength(Result, L);
  for I := 0 to L - 1 do
    Result[I] := Fitems[I];
end;

function TIpAuthentication.isAuthorised(const IP: String): Boolean;
begin
  /// stub
  Result := False;
end;

end.
