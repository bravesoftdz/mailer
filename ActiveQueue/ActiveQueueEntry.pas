unit ActiveQueueEntry;

interface

uses
  System.Generics.Collections, JsonableInterface, System.JSON, ObjectsMappers;

type

  /// <summary>An ADT that represents a single entry for the Active Queue server.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TActiveQueueEntry = class(TInterfacedObject, Jsonable)
  strict private
  const
    /// names of keys to be used in a json to store correpsondign property values
    TOKEN_KEY = 'token';
    BODY_KEY = 'body';
    ORIGIN_KEY = 'origin';
    CATEGORY_KEY = 'category';

  var
    /// <summary>A token based on which the server decides whether to allow the request or not</summary>
    FToken: String;
    /// <summary>The body of the request. It is a json in a string format</summary>
    FBody: String;
    /// <summary>Origin of the request (who has created the request)</summary>
    FOrigin: String;
    /// <summary>Category of the request. It might be useful for differentiating btw
    /// different requests (for example, in order to be able to select specific requests for
    /// cancelling, postponing etc. by the consumers) </summary>
    FCategory: String;

  public
    /// <summary>Create a copy of this instance</summary>
    function Clone(): TActiveQueueEntry;

    [MapperJSONSer(TOKEN_KEY)]
    property Token: String read FToken write FToken;
    [MapperJSONSer(BODY_KEY)]
    property Body: String read FBody write FBody;
    [MapperJSONSer(ORIGIN_KEY)]
    property Origin: String read FOrigin write FOrigin;
    [MapperJSONSer(CATEGORY_KEY)]
    property Category: String read FCategory write FCategory;

    constructor Create(const Origin, Category, Body, Token: string); overload;
    constructor Create(); overload;

    function ToJson(): TJsonObject;

  end;

type
  /// <summary>A wrapper for a collection of TActiveQueueEntry.</summary>
  TActiveQueueEntries = class(TObject)
  strict private
  const
    ITEMS_KEY = 'items';

  var
    FItems: TObjectList<TActiveQueueEntry>;
    function GetItems: TObjectList<TActiveQueueEntry>;
    procedure SetItems(Items: TObjectList<TActiveQueueEntry>);
  public
    constructor Create(const Items: TObjectList<TActiveQueueEntry>); overload;
    constructor Create; overload;
    destructor Destroy; override;
    [MapperJSONSer(ITEMS_KEY)]
    [MapperListOf(TActiveQueueEntry)]
    property Items: TObjectList<TActiveQueueEntry> read GetItems write SetItems;
  end;

implementation

uses
  System.SysUtils;

{ TActiveQueueEntries }

constructor TActiveQueueEntries.Create(const Items: TObjectList<TActiveQueueEntry>);
begin
  Create();
  SetItems(Items);
end;

constructor TActiveQueueEntries.Create;
begin
  FItems := TObjectList<TActiveQueueEntry>.Create();
end;

destructor TActiveQueueEntries.Destroy;
begin
  FItems.Clear;
  FItems.DisposeOf;
  inherited;
end;

function TActiveQueueEntries.GetItems: TObjectList<TActiveQueueEntry>;
begin
  Result := TObjectList<TActiveQueueEntry>.Create();
end;

procedure TActiveQueueEntries.SetItems(Items: TObjectList<TActiveQueueEntry>);
var
  Item: TActiveQueueEntry;
begin
  FItems.Clear;
  if Items <> nil then
  begin
    for Item in Items do
      FItems.Add(Item.Clone())
  end;
end;

{ TActiveQueueEntry }

function TActiveQueueEntry.Clone: TActiveQueueEntry;
begin
  Result := TActiveQueueEntry.Create(FOrigin, Fcategory, FBody, FToken);
end;

constructor TActiveQueueEntry.Create;
begin
  FToken := '';
  FBody := '';
  FOrigin := '';
  FCategory := '';
end;

constructor TActiveQueueEntry.Create(const Origin, Category, Body, Token: string);
begin
  FToken := Token;
  FBody := Body;
  FOrigin := Origin;
  FCategory := Category;
end;

function TActiveQueueEntry.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create;
  Result.AddPair(TOKEN_KEY, FTOKEN);
  Result.AddPair(BODY_KEY, FBODY);
  Result.AddPair(CATEGORY_KEY, FCategory);
  Result.AddPair(ORIGIN_KEY, FOrigin);
end;

end.
