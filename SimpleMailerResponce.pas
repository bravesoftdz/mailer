unit SimpleMailerResponce;

interface

uses
  MailerResponceInterface;

type
  TSimpleMailerResponce = class(TInterfacedObject, IMailerResponce)
  private
    FMessage: String;
  public
    function getMessage(): String;
    procedure setMessage(const msg: String);
    constructor Create(); overload;
  end;

implementation

{ TSimpleMailerResponce }

constructor TSimpleMailerResponce.Create;
begin
  FMessage := 'Start message';
end;

function TSimpleMailerResponce.getMessage: String;
begin
  Result := FMessage;
end;

procedure TSimpleMailerResponce.setMessage(const msg: String);
begin
  FMessage := msg;
end;

end.
