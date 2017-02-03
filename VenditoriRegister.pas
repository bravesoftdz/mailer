unit VenditoriRegister;

interface

uses
  MailerAction, SimpleInputData, SimpleMailerResponce;

type
  TVenditoriRegister = class(TMailerAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create;
  end;

implementation

{ TVenditoriRegister }

constructor TVenditoriRegister.Create;
begin
  inherited Create('venditori', 'register');
end;

function TVenditoriRegister.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
var
  Msg: String;
begin
  if (Data.Data = nil) then
    Msg := 'no data'
  else
    Msg := 'venditori registrazione: ' + Data.Data.ToString;
  Result := TSimpleMailerResponce.Create;
  Result.message := Msg;
end;

end.
