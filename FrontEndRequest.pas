unit FrontEndRequest;

interface

uses
  System.JSON, System.Generics.Collections, Attachment, ObjectsMappers;

type

  /// <summary> A request that arrives from the front end.
  /// It is elaborated and a responce is returned.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TFrontEndRequest = class
  private
    FHtml: String;
    FText: String;
    FAttachments: TObjectList<TAttachment>;
    procedure SetAttachments(const Value: TObjectList<TAttachment>);
  public
    /// <summary> Constructor</summary>
    /// <param name="aData">data associated with the request.</param>
    constructor Create(const aText, anHtml: String; const Attachs: TObjectList<TAttachment>); overload;
    constructor Create(); overload;
    [MapperColumnAttribute('html')]
    property Html: String read FHtml write FHtml;
    [MapperColumnAttribute('text')]
    property Text: String read FText write FText;
    [MapperColumnAttribute('attachments')]
    [MapperItemsClassType(TAttachment)]
    property Attachments: TObjectList<TAttachment> read FAttachments write SetAttachments;
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

constructor TFrontEndRequest.Create;
begin
  FText := '';
  FHTml := '';
  FAttachments := TObjectList<TAttachment>.Create;
end;

procedure TFrontEndRequest.SetAttachments(
  const Value: TObjectList<TAttachment>);
begin
  FAttachments := Value;
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
