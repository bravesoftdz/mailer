unit FrontEndResponce;

interface

type

  /// <summary>
  ///  A front-end responce.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TFrontEndResponce = class
  private
    FMessage: String;
    FToken: String;
    procedure SetMessage(const Value: String);
    procedure SetToken(const Value: String);
  public
    property msg: String read FMessage write SetMessage;
    property token: String read FToken write SetToken;
  end;

implementation

{ TSimpleMailerResponce }

procedure TFrontEndResponce.setMessage(const Value: String);
begin
  FMessage := Value;
end;

procedure TFrontEndResponce.SetToken(const Value: String);
begin
  FToken := Value;
end;

end.
