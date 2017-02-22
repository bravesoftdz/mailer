unit Attachment;

interface

type

  /// <summary>Immutable type to represent a single attachment</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAttachment = class
  private
    FName: String;
    FContent: String;
  public
    /// <summary> name of the attachment</summary>
    property Name: String read FName;
    /// <summary> content of the attachment</summary>
    property Content: String read FContent;
    /// <summary> constructor </summary>
    /// <param name="aName"> name of the attachment</param>
    /// <param name="aContent"> content of the attachment</param>
    constructor Create(const aName, aContent: String);
  end;

implementation

{ TAttachment }

constructor TAttachment.Create(const aName, aContent: String);
begin
  FName := aName;
  FContent := aContent;
end;

end.
