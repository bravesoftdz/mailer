unit FrontEndRequest;

interface

uses
  System.JSON, System.Generics.Collections, Attachment, REST.Json.Types;

type

  /// <summary> A request that arrives from the front end.
  /// It is elaborated and a responce is returned.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TFrontEndRequest = class
  const
    MSG_TOKEN = 'message';
    ATTACHMENTS_TOKEN = 'attachments';
  private
    [JSONMarshalled(True)]
    [JSonName('html')]
    FHtml: String;

    [JSONMarshalled(True)]
    [JSonName('text')]
    FText: String;

    [JSONMarshalled(True)]
    [JSonName('attachments')]
    FAttachments: TObjectList<TAttachment>;
  public
    /// <summary> Constructor</summary>
    /// <param name="aData">data associated with the request.</param>
    constructor Create(const aText, anHtml: String; const Attachs: TObjectList<TAttachment>);
    property Html: String read FHtml;
    property Text: String read FText;
    property Attachments: TObjectList<TAttachment> read FAttachments;
    function ToString(): String;
  end;

implementation

uses
  System.SysUtils;

{ TSimpleInputData }

constructor TFrontEndRequest.Create(const aText, anHtml: String;
  const Attachs: TObjectList<TAttachment>);
begin
  FText := aText;
  FHtml := anHtml;
  FAttachments := Attachs;
end;

function TFrontEndRequest.ToString: String;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  Builder.Append(', html: ');
  Builder.Append(FHtml);
  Result := Builder.ToString;
  Builder.DisposeOf;
end;

end.
