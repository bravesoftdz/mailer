unit DispatcherEntry;

interface

uses
  System.JSON, System.Generics.Collections, Attachment, ObjectsMappers;

type

  /// Represent a request that the dispatcher is able to handle.
  [MapperJSONNaming(JSONNameLowerCase)]
  TDispatcherEntry = class(TObject)
  strict private
  var
    FOrigin: String;
    FAction: String;
    FContent: TJsonObject;
    FAttachments: TObjectList<TAttachment>;
    FToken: String;

    procedure SetContent(const Content: TJsonObject);
    procedure SetAttachments(const Attachments: TObjectList<TAttachment>);
    function GetAttachmentsCopy: TObjectList<TAttachment>;
    function GetContentCopy: TJsonObject;

  public
    constructor Create(); overload;
    constructor Create(const Origin: String; const Action: String; const Content: TJsonObject; const Attachs: TObjectList<TAttachment>; const Token: String); overload;
    destructor Destroy(); override;

    property Origin: String read FOrigin write FOrigin;
    property Action: String read FAction write FAction;
    property Token: String read FToken write FToken;
    property Attachments: TObjectList<TAttachment> read GetAttachmentsCopy write SetAttachments;
    property Content: TJsonObject read GetContentCopy write SetContent;
  end;

implementation

uses
  System.Classes;

{ TDispatcherEntry }

constructor TDispatcherEntry.Create;
begin
  FContent := TJsonObject.Create();
  FAttachments := TObjectList<TAttachment>.Create();
end;

constructor TDispatcherEntry.Create(const Origin, Action: String; const Content: TJsonObject;
  const Attachs: TObjectList<TAttachment>; const Token: String);
begin
  Create();
  FOrigin := Origin;
  FAction := Action;
  FToken := Token;
  SetContent(Content);
  SetAttachments(Attachs);

end;

destructor TDispatcherEntry.Destroy;
begin
  FContent.DisposeOf;
  FAttachments.Clear;
  FAttachments.DisposeOf;
  inherited;
end;

function TDispatcherEntry.GetAttachmentsCopy: TObjectList<TAttachment>;
var
  Attachment: TAttachment;
  Content: TMemoryStream;
begin
  Result := TObjectList<TAttachment>.Create();
  for Attachment in FAttachments do
  begin
    Content := Attachment.Content;
    Result.Add(TAttachment.Create(Attachment.Name, Content));
    Content.DisposeOf;
  end;
end;

function TDispatcherEntry.GetContentCopy: TJsonObject;
begin
  Result := FContent.Clone as TJsonObject;
end;

procedure TDispatcherEntry.SetAttachments(const Attachments: TObjectList<TAttachment>);
var
  Attachment: TAttachment;
  Content: TMemoryStream;
begin
  FAttachments.Clear;
  for Attachment in FAttachments do
  begin
    Content := Attachment.Content;
    FAttachments.Add(TAttachment.Create(Attachment.Name, Content));
    Content.DisposeOf;
  end;
end;

procedure TDispatcherEntry.SetContent(const Content: TJsonObject);
begin
  FContent.DisposeOf;
  if Content <> nil then
    FContent := Content.Clone as TJsonObject
  else
    FContent := TJsonObject.Create();
end;

end.
