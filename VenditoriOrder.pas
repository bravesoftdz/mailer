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
//  FDestinationName := 'venditori';
//  FActionName := 'order';
end;

function TVenditoriOrder.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
var
  Msg: String;
begin
  if (Data.Data = nil) then
    Msg := 'no data'
  else
    Msg := 'venditori order: ' + Data.Data.ToString;
  Result := TSimpleMailerResponce.Create;
  Result.message := Msg;
end;

end.
