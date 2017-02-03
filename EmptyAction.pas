unit EmptyAction;

interface

uses
  MailerAction, SimpleInputData, SimpleMailerResponce;

type
  TEmptyAction = class(TMailerAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create;
  end;

implementation

{ TEmptyAction }

constructor TEmptyAction.Create;
begin
  inherited Create('no-destination', 'no-action');
end;

function TEmptyAction.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
begin
  Result := TSimpleMailerResponce.Create;
  Result.message := 'unclear request';
end;

end.
