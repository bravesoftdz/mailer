unit FrontEndRequest;

interface

uses
  System.JSON;

type
  /// <summary> A request that arrives from the front end.
  /// It is elaborated and a responce is returned.</summary>
  TFrontEndRequest = class
  private
    FOrigin: String;
    FData: String;
  public
    /// <summary> Constructor</summary>
    /// <param name="Origin">origin of the request</param>
    /// <param name="Data">data associated with the request. It is a json object
    /// from which actually only a key 'message' is taken into account.</param>
    constructor Create(const Origin: String; const Data: TJSonObject);
    property Data: String read FData;
    property Origin: String read FOrigin;
    function ToString(): String;
  end;

implementation

uses
  System.SysUtils;

{ TSimpleInputData }

constructor TFrontEndRequest.Create(const Origin: String;
  const Data: TJSonObject);
const
  MSG_TOKEN = 'message';
var
  msg: String;
  val: TJsonValue;
begin
  FOrigin := Origin;
  if (Data <> nil) then
  begin
    val := Data.GetValue(MSG_TOKEN);
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
  Builder.Append(Data);
  Result := Builder.ToString;
  Builder.DisposeOf;
end;

end.
