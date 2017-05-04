unit SubscriptionData;

interface

uses ObjectsMappers;

// <summary>Data class that contains information necessary for
// perform the subscription.</summary>
type

  [MapperJSONNaming(JSONNameLowerCase)]
  TSubscriptionData = class(TObject)
  strict private
    FUrl: String;
    FIP: String;
    FPort: Integer;
    FPath: String;
    /// <summary> Calculate a hash code of a string</summary>
    /// <param name="Text">a text whose hash code should be calculated</param>
    /// <param name="Base">a parameter that influences on the collision frequency.
    /// If zero, the resulting hash code is zero for all strings.
    /// The bigger, the lower collision frequency.</param>
    function StringHash(const Text: String; const Base: Integer): Integer;
  public
    [MapperJSONSer('url')]
    property Url: String read FUrl write FUrl;
    [MapperJSONSer('ip')]
    property Ip: String read FIp write FIp;
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer('path')]
    property Path: String read FPath write FPath;
    constructor Create(const Ip, Url: String; const Port: Integer; const Path: String); overload;
    constructor Create(); overload;
    /// <summary>Compare objects by their content, not by their references.</summary>
    function Equals(Obj: TObject): Boolean; override;
    /// <summary>Since the  method Equals() is overriden, hash code must be overriden as well. </summary>
    function GetHashCode(): Integer; override;
    /// <summary>Returns a copy of the object</summary>
    function Copy(): TSubscriptionData;
  end;

implementation

{ TSubscriptionData }

constructor TSubscriptionData.Create(const Ip, Url: String; const Port: Integer;
  const Path: String);
begin
  FIP := Ip;
  FUrl := Url;
  FPort := Port;
  FPath := Path;
end;

function TSubscriptionData.Copy: TSubscriptionData;
begin
  Result := TSubscriptionData.Create(FIp, FUrl, FPort, FPath);
end;

constructor TSubscriptionData.Create;
begin
  FUrl := '';
  FPort := 0;
  FPath := '';
end;

function TSubscriptionData.Equals(Obj: TObject): Boolean;
var
  that: TSubscriptionData;
begin
  if Not(Obj is TSubscriptionData) then
    Result := False
  else
  begin
    that := Obj as TSubscriptionData;
    Result := (Self.Url = That.Url) AND (Self.Ip = That.Ip) AND (Self.Port = That.Port) AND (Self.Path = That.Path);
  end;
end;

function TSubscriptionData.GetHashCode: Integer;
const
  Seed = 17; // some mutually prime numbers
  Base = 31;
begin
  Result := Seed;
  Result := Base * Result + StringHash(Url, Base);
  Result := Base * Result + StringHash(Ip, Base);
  Result := Base * Result + StringHash(Path, Base);
  Result := Base * Result + Port;
end;

function TSubscriptionData.StringHash(const Text: String; const Base: Integer): Integer;
var
  S, I: Integer;
begin
  Result := 0;
  S := Length(Text);
  for I := 1 to S do
    Result := Base * Result + Ord(Text[I]);
end;

end.
