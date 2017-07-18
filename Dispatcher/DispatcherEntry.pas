unit DispatcherEntry;

interface

uses
  ObjectsMappers, System.Generics.Collections, Attachment, System.JSON;

type

  /// Represent a request that the dispatcher is able to handle.
  [MapperJSONNaming(JSONNameLowerCase)]
  TDispatcherEntry = class(TObject)
  strict private
  const
    ORIGIN_KEY = 'origin';
    ACTION_KEY = 'action';
    TOKEN_KEY = 'token';
    ATTACHMENT_KEY = 'attachments';
    CONTENT_KEY = 'content';

  var
    FOrigin: String;
    FAction: String;
    FAttachments: TObjectList<TAttachment>;
    FToken: String;
    FContent: String;

    procedure SetAttachments(const TheAttachments: TObjectList<TAttachment>);

  public
    constructor Create(); overload;
    constructor Create(const Origin: String; const Action: String; const Content: String;
      const Attachs: TObjectList<TAttachment>; const Token: String); overload;
    destructor Destroy(); override;
    property Origin: String read FOrigin write FOrigin;
    property Action: String read FAction write FAction;
    property Token: String read FToken write FToken;
    [MapperListOf(TAttachment)]
    property Attachments: TObjectList<TAttachment> read FAttachments write FAttachments;
    property Content: String read FContent write FContent;

    function toJson(): TJsonObject;
  end;

implementation

uses
  System.Classes, System.SysUtils;

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

procedure TDispatcherEntry.SetAttachments(const TheAttachments: TObjectList<TAttachment>);
var
  Attachment: TAttachment;
begin
  FAttachments.Clear;
  for Attachment in TheAttachments do
  begin
    FAttachments.Add(Attachment.Clone());
  end;
end;

function TDispatcherEntry.toJson: TJsonObject;
begin
  Result := Mapper.ObjectToJSONObject(Self);
end;

end.
