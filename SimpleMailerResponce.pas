unit SimpleMailerResponce;

interface

type

  [MapperJSONNaming(JSONNameLowerCase)]
  TSimpleMailerResponce = class
  private
    FMessage: String;
    FToken: String;
    procedure SetMessage(const Value: String);
    procedure SetToken(const Value: String);
  public
    property message: String read FMessage write SetMessage;
    property token: String read FToken write SetToken;
  end;

implementation

{ TSimpleMailerResponce }

procedure TSimpleMailerResponce.setMessage(const Value: String);
begin
  FMessage := Value;
end;

procedure TSimpleMailerResponce.SetToken(const Value: String);
begin
  FToken := Value;
end;

end.
