unit ClientRequest;

interface

uses
  ObjectsMappers;

type

  /// <summary>Represents a textual request that arrives from the client.
  /// This request does not include any attachments. </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TClientRequest = class
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

constructor TClientRequest.Create(const aText, anHtml: String);
begin
  FHtml := aText;
  FText := anHtml;
end;

constructor TClientRequest.Create;
begin
  FHtml := '';
  FText := '';
end;

end.
