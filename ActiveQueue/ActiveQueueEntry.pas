unit ActiveQueueEntry;

interface

uses
  System.Generics.Collections;

type
  /// <summary>An ADT that represents a single entry for the Active Queue server.</summary>
  TActiveQueueEntry = class(TObject)

  end;

type
  TActiveQueueEntries = class(TObject)
  private
    FItems: TObjectList<TActiveQueueEntry>;

  public
    constructor Create(const Items: TObjectList<TActiveQueueEntry>); overload;
    constructor Create; overload;
    destructor Destroy; override;
    procedure SetItems(Items: TObjectList<TActiveQueueEntry>);

    [MapperListOf(TActiveQueueEntry)]
    property Items: TObjectList<TActiveQueueEntry> read FItems write SetItems;

  end;

implementation

end.
