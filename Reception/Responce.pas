unit Responce;

interface

type

  /// <summary>
  /// A responce that a Reception instance provides to a client.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TResponce = class
  private
    FMessage: String;
    FToken: String;
    procedure SetMessage(const Value: String);
    procedure SetToken(const Value: String);
  public
    property msg: String read FMessage write SetMessage;

    { TODO : Does the client really need the token in the responce? }
    property token: String read FToken write SetToken;
  end;

implementation

{ TSimpleMailerResponce }

procedure TResponce.setMessage(const Value: String);
begin
  FMessage := Value;
end;

procedure TResponce.SetToken(const Value: String);
begin
  FToken := Value;
end;

end.
