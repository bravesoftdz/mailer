unit AQSubscriptionEntry;

interface

uses ObjectsMappers;

// <summary>Data class that contains information about a consumer necessary to
// subscribe/unsubscribe it.</summary>
type

  [MapperJSONNaming(JSONNameLowerCase)]
  TAQSubscriptionEntry = class(TObject)
  strict private
  const
    PORT_KEY = 'port';
    CATEGORY_KEY = 'category';
    Seed = 17; // some mutually prime numbers for calculating a hash code
    Base = 31;

  var
    /// consumer's port
    FPort: Integer;
    /// type of events to which the consumer subscribes
    FCategory: String;
    /// <summary> Calculate a hash code of a string</summary>
    /// <param name="Text">a text whose hash code should be calculated</param>
    /// <param name="Base">a parameter that influences on the collision frequency.
    /// If zero, the resulting hash code is zero for all strings.
    /// The bigger, the lower collision frequency.</param>
    function StringHash(const Text: String; const Base: Integer): Integer;
  public
    [MapperJSONSer(PORT_KEY)]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer(CATEGORY_KEY)]
    property Category: String read FCategory write FCategory;

    constructor Create(const Port: Integer; const Category: String); overload;
    constructor Create(); overload;
    destructor Destroy(); override;
    /// <summary>Compare objects by their content, not by their references.</summary>
    function Equals(Obj: TObject): Boolean; override;
    /// <summary>Since the  method Equals() is overriden, hash code must be overriden as well. </summary>
    function GetHashCode(): Integer; override;
    /// <summary>Returns a copy of the object</summary>
    function Copy(): TAQSubscriptionEntry;
  end;

implementation

{ TAQSubscriptionData }

function TAQSubscriptionEntry.Copy: TAQSubscriptionEntry;
begin
  Result := TAQSubscriptionEntry.Create(FPort, FCategory);
end;

constructor TAQSubscriptionEntry.Create;
begin
  Create(0, '');
end;

constructor TAQSubscriptionEntry.Create(const Port: Integer; const Category: String);
begin
  FPort := Port;
  FCategory = Category;
end;

destructor TAQSubscriptionEntry.Destroy;
begin
  Writeln('Destroying a TAQSubscriptionData istance');
  inherited;
end;

function TAQSubscriptionEntry.Equals(Obj: TObject): Boolean;
var
  that: TAQSubscriptionEntry;
begin
  if Not(Obj is TAQSubscriptionEntry) then
    Result := False
  else
  begin
    that := Obj as TAQSubscriptionEntry;
    Result := (Self.Port = That.Port) AND (Self.Category = That.Category);
  end;
end;

function TAQSubscriptionEntry.GetHashCode: Integer;
begin
  Result := Seed;
  Result := Base * Result + StringHash(Category, Base);
  Result := Base * Result + Port;
end;

function TAQSubscriptionEntry.StringHash(const Text: String; const Base: Integer): Integer;
var
  S, I: Integer;
begin
  Result := 0;
  S := Length(Text);
  for I := 1 to S do
    Result := Base * Result + Ord(Text[I]);
end;

end.
