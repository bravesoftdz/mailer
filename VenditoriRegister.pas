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
begin
  Result := TSimpleMailerResponce.Create;
  Result.message := getDestinationName + ' ' + getActionName + ' -> ' + Data.ToString;
end;

end.
