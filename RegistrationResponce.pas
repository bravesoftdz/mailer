unit RegistrationResponce;

interface

uses
  MailerResponceInterface;

type
  TRegistrationResponce = class(TInterfacedObject, IMailerResponce)
  const
    FMessage = 'test message';
    function
      getMessage: String;
  end;

implementation

{ TRegistrationResponce }

function TRegistrationResponce.getMessage: String;
begin
  Result := FMessage;
end;

end.
