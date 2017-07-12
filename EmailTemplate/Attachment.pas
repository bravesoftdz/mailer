unit Attachment;

interface

uses
  ObjectsMappers, System.Classes;

type

  /// <summary>A mutable type to represent a single attachment</summary>
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
    property Content: TMemoryStream read FContent write FContent;

    /// <summary> constructor </summary>
    /// <param name="aName"> name of the attachment</param>
    /// <param name="aContent"> content of the attachment</param>
    constructor Create(const AName: String; const AContent: TMemoryStream); overload;

    /// <summary>Default constructor</summary>
    constructor Create(); overload;

    destructor Destroy(); override;

    /// <sumamry>Create a deep copy of the instance.</summary>
    function Clone(): TAttachment;

    /// <summary>return Content as string</summary>
    function ContentAsString(): String;
  end;

implementation

uses
  System.SysUtils;

{ TAttachment }

function TAttachment.Clone: TAttachment;
begin
  Result := TAttachment.Create(FName, FContent);
end;

constructor TAttachment.Create(const AName: String; const AContent: TMemoryStream);
begin
  Create();
  FName := AName;
  FreeAndSetContent(AContent);
end;

function TAttachment.ContentAsString: String;
var
  aStream: TStringStream;
begin
  aStream := TStringStream.Create('', TEncoding.UTF8);
  aStream.CopyFrom(FContent, 0);
  Result := aStream.DataString;
  aStream.DisposeOf;
end;

constructor TAttachment.Create;
begin
  FContent := TMemoryStream.Create();
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
