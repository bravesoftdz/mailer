unit ActiveQueueEntry;

interface

uses
  System.Generics.Collections, Attachment;

type
  /// <summary>An ADT that represents a single entry for the Active Queue server.</summary>
  TActiveQueueEntry = class(TObject)
  private
    FToken: String;
    FBody: String;
    FAttachments: TObjectList<TAttachment>;

  public
    /// <summary>Create a copy of this instance</summary>
    function Clone(): TActiveQueueEntry;

    property Token: String read FToken write FToken;
    property Body: String read FBody write FBody;
    property Attachments: TObjectList<TAttachment> read FAttachments write FAttachments;

    constructor Create();
    destructor Destroy(); override;

  end;

type
  /// <summary>A wrapper for a collection of TActiveQueueEntry.</summary>
  TActiveQueueEntries = class(TObject)
  strict private
    FItems: TObjectList<TActiveQueueEntry>;
    function GetItems: TObjectList<TActiveQueueEntry>;
    procedure SetItems(Items: TObjectList<TActiveQueueEntry>);
  public
    constructor Create(const Items: TObjectList<TActiveQueueEntry>); overload;
    constructor Create; overload;
    destructor Destroy; override;
    [MapperListOf(TActiveQueueEntry)]
    property Items: TObjectList<TActiveQueueEntry> read GetItems write SetItems;
  end;

implementation

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
  /// stub
  Result := TActiveQueueEntry.Create();
end;

constructor TActiveQueueEntry.Create;
begin
  FAttachments := TObjectList<TAttachment>.Create;
end;

destructor TActiveQueueEntry.Destroy;
begin
  FAttachments.Clear;
  FAttachments.DisposeOf;
  inherited;
end;

end.
