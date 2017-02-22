unit FrontEndRequest;

interface

uses
  System.JSON, System.Generics.Collections, Attachment;

type

  /// <summary> A request that arrives from the front end.
  /// It is elaborated and a responce is returned.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TFrontEndRequest = class
  const
    MSG_TOKEN = 'message';
    ATTACHMENTS_TOKEN = 'attachments';

  private
    FOrigin: String;
    FData: String;
    // FAttachments: TObjectList<TAttachment>;
  public
    /// <summary> Constructor</summary>
    /// <param name="Origin">origin of the request</param>
    /// <param name="Data">data associated with the request. It is a json object
    /// from which actually only a key 'message' is taken into account.</param>
    constructor Create(const Origin: String; const aData: TJSonObject);
    property Data: String read FData;
    property Origin: String read FOrigin;
    // property Attachments: TObjectList<TAttachment> read FAttachments;
    function ToString(): String;
  end;

implementation

uses
  System.SysUtils;

{ TSimpleInputData }

constructor TFrontEndRequest.Create(const Origin: String;
  const aData: TJSonObject);
var
  msg: String;
  val: TJsonValue;
begin
  FOrigin := Origin;
  if (aData <> nil) then
  begin
    val := aData.GetValue(MSG_TOKEN);
    if val <> nil then
      FData := val.Value;
  end;
end;

function TFrontEndRequest.ToString: String;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  Builder.Append('destination: ');
  Builder.Append(FOrigin);
  Builder.Append(', data: ');
  Builder.Append(FData);
  Result := Builder.ToString;
  Builder.DisposeOf;
end;

end.
