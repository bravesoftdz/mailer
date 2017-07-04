unit ActiveQueueEntry;

interface

uses
  System.Generics.Collections, Attachment;

type
  /// <summary>An ADT that represents a single entry for the Active Queue server.</summary>
  TActiveQueueEntry = class(TObject)
  private
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

    FAttachments: TObjectList<TAttachment>;

  public
    /// <summary>Create a copy of this instance</summary>
    function Clone(): TActiveQueueEntry;

    property Token: String read FToken write FToken;
    property Body: String read FBody write FBody;
    property Marker: String read FOrigin write FOrigin;
    property Category: String read FCategory write FCategory;
    property Attachments: TObjectList<TAttachment> read FAttachments write FAttachments;

    constructor Create(const Origin, Category, Body, Token: string; const Attachments: TObjectList<TAttachment>); overload;
    constructor Create(); overload;
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
  Result := TActiveQueueEntry.Create(FOrigin, Fcategory, FBody, FToken, FAttachments);
end;

constructor TActiveQueueEntry.Create;
begin
  FAttachments := TObjectList<TAttachment>.Create;
end;

constructor TActiveQueueEntry.Create(const Origin, Category, Body, Token: string; const Attachments: TObjectList<TAttachment>);
var
  Attachment: TAttachment;
begin
  Create();
  FToken := Token;
  FBody := Body;
  FOrigin := Origin;
  FCategory := Category;
  if Attachments <> nil then
  begin
    for Attachment in Attachments do
    begin
      FAttachments.add(Attachment.Clone);
    end;
  end;

end;

destructor TActiveQueueEntry.Destroy;
begin
  FAttachments.Clear;
  FAttachments.DisposeOf;
  inherited;
end;

end.
