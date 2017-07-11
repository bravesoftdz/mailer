unit Attachment;

interface

uses
  ObjectsMappers, System.Classes;

type

  /// <summary>Immutable type to represent a single attachment</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAttachment = class(TObject)
  strict private
    FName: String;
    FContent: TMemoryStream;
    /// Return a copy of FContent.
    function GetContentCopy: TMemoryStream;
    /// free FContent and set a new value. Assume that FContent has already been intialized.
    procedure FreeAndSetContent(const Value: TMemoryStream);
  public
    /// <summary> name of the attachment</summary>
    [MapperJSONSer('name')]
    property Name: String read FName write FName;
    /// <summary> content of the attachment</summary>
    [MapperJSONSer('content')]
    property Content: TMemoryStream read GetContentCopy write FreeAndSetContent;
    /// <summary> constructor </summary>
    /// <param name="aName"> name of the attachment</param>
    /// <param name="aContent"> content of the attachment</param>
    constructor Create(const AName: String; const AContent: TMemoryStream);
    destructor Destroy(); override;
    /// <sumamry>Create a deep copy of the instance.</summary>
    function Clone(): TAttachment;
  end;

implementation

{ TAttachment }

function TAttachment.Clone: TAttachment;
begin
  Result := TAttachment.Create(FName, FContent);
end;

constructor TAttachment.Create(const AName: String; const AContent: TMemoryStream);
begin
  FName := AName;
  FContent := TMemoryStream.Create();
  FreeAndSetContent(AContent);
end;

destructor TAttachment.Destroy;
begin
  FContent.DisposeOf;
  inherited;
end;

function TAttachment.GetContentCopy: TMemoryStream;
begin
  Result := TMemoryStream.Create;
  Result.LoadFromStream(FContent);
end;

procedure TAttachment.FreeAndSetContent(const Value: TMemoryStream);
begin
  FContent.DisposeOf;
  FContent := TMemoryStream.Create();
  if Value <> nil then
    FContent.LoadFromStream(Value);

end;

end.
