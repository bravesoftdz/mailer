unit EmptyAction;

interface

uses
  MailerAction, SimpleInputData, SimpleMailerResponce;

type
  TEmptyAction = class(TMailerAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;

  end;

implementation

{ TEmptyAction }

function TEmptyAction.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
begin
  Result := TSimpleMailerResponce.Create;
  Result.message := 'unclear request';
end;

end.
