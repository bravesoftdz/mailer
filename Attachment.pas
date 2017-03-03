unit Attachment;

interface

uses
  ObjectsMappers, System.Classes;

type

  /// <summary>Immutable type to represent a single attachment</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAttachment = class(TObject)
  private
    FName: String;
    FContent: TMemoryStream;
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
    constructor Create(const aName: String; const aContent: TMemoryStream);
  end;

implementation

{ TAttachment }

constructor TAttachment.Create(const aName: String; const aContent: TMemoryStream);
begin
  FName := aName;
  FContent := aContent;
end;

end.
