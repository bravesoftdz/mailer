unit VenditoriOrder;

interface

uses
  MailerAction, SimpleInputData, SimpleMailerResponce;

type
  TVenditoriOrder = class(TMailerAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create;
  end;

implementation

{ TVenditoriOrder }

constructor TVenditoriOrder.Create;
begin
  inherited Create('venditori', 'order');
end;

function TVenditoriOrder.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
var
  Msg: String;
begin
  Result := TSimpleMailerResponce.Create;
  Result.message := getDestinationName + ' ' + getActionName + ' -> ' + Data.ToString;
end;

end.
