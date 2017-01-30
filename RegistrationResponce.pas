unit RegistrationResponce;

interface

type
  TRegistrationResponce = class
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
