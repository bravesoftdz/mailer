unit DispatcherEntry;

interface

uses
  ObjectsMappers, System.Generics.Collections, Attachment;

type

  /// Represent a request that the dispatcher is able to handle.
  [MapperJSONNaming(JSONNameLowerCase)]
  TDispatcherEntry = class(TObject)
  strict private
  var
    FOrigin: String;
    FAction: String;
    FAttachments: TObjectList<TAttachment>;
    FToken: String;
    FContent: String;

    procedure SetAttachments(const Attachments: TObjectList<TAttachment>);
    function GetAttachmentsCopy: TObjectList<TAttachment>;

  public
    constructor Create(); overload;
    constructor Create(const Origin: String; const Action: String; const Content: String;
      const Attachs: TObjectList<TAttachment>; const Token: String); overload;
    destructor Destroy(); override;
    property Origin: String read FOrigin write FOrigin;
    property Action: String read FAction write FAction;
    property Token: String read FToken write FToken;
    property Attachments: TObjectList<TAttachment> read GetAttachmentsCopy write SetAttachments;
    property Content: String read FContent write FContent;
  end;

implementation

uses
  System.Classes;

{ TDispatcherEntry }

constructor TDispatcherEntry.Create;
begin
  FAttachments := TObjectList<TAttachment>.Create();
end;

constructor TDispatcherEntry.Create(const Origin, Action: String; const Content: String;
  const Attachs: TObjectList<TAttachment>; const Token: String);
begin
  Create();
  FOrigin := Origin;
  FAction := Action;
  FToken := Token;
  FContent := Content;
  SetAttachments(Attachs);
end;

destructor TDispatcherEntry.Destroy;
begin
  FAttachments.Clear;
  FAttachments.DisposeOf;
  inherited;
end;

function TDispatcherEntry.GetAttachmentsCopy: TObjectList<TAttachment>;
var
  Attachment: TAttachment;
  StreamCopy: TMemoryStream;
begin
  Result := TObjectList<TAttachment>.Create();
  for Attachment in FAttachments do
  begin
    StreamCopy := Attachment.Content;
    Result.Add(TAttachment.Create(Attachment.Name, StreamCopy));
    StreamCopy.DisposeOf;
  end;
end;

procedure TDispatcherEntry.SetAttachments(const Attachments: TObjectList<TAttachment>);
var
  Attachment: TAttachment;
  StreamCopy: TMemoryStream;
begin
  FAttachments.Clear;
  for Attachment in FAttachments do
  begin
    StreamCopy := Attachment.Content;
    FAttachments.Add(TAttachment.Create(Attachment.Name, StreamCopy));
    StreamCopy.DisposeOf;
  end;
end;

end.
