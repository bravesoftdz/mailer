unit FrontEndData;

interface

uses
  ObjectsMappers;

type

  /// <summary>Represents a textual request that arrives from the front end.
  /// This request does not include any attachments. The attachments are
  /// supposed to be elaborated somewhere else. </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TFrontEndData = class
  private
    FHtml: String;
    FText: String;
  public
    /// <summary> Constructor</summary>
    constructor Create(const aText, anHtml: String); overload;
    constructor Create(); overload;
    [MapperJSONSer('html')]
    property Html: String read FHtml write FHtml;
    [MapperJSONSer('text')]
    property Text: String read FText write FText;
  end;

implementation

{ TFrontEndData }

constructor TFrontEndData.Create(const aText, anHtml: String);
begin
  FHtml := aText;
  FText := anHtml;
end;

constructor TFrontEndData.Create;
begin
  FHtml := '';
  FText := '';
end;

end.
