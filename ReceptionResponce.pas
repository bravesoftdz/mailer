unit ReceptionResponce;

interface

type

  /// <summary>
  ///  A responce that a Reception instance provides to a client.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TReceptionResponce = class
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

procedure TReceptionResponce.setMessage(const Value: String);
begin
  FMessage := Value;
end;

procedure TReceptionResponce.SetToken(const Value: String);
begin
  FToken := Value;
end;

end.
