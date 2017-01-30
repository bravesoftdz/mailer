unit SimpleMailerResponce;

interface

type

  [MapperJSONNaming(JSONNameLowerCase)]
  TSimpleMailerResponce = class
  private
    FMessage: String;
    procedure SetMessage(const msg: String);
  public
    property message: String read FMessage write SetMessage;
  end;

implementation

{ TSimpleMailerResponce }

procedure TSimpleMailerResponce.setMessage(const msg: String);
begin
  FMessage := msg;
end;

end.
