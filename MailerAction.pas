unit MailerAction;

interface

uses
  SimpleMailerResponce, SimpleInputData;

type
  TMailerAction = class
  protected
    FDestinationName: String;
    FActionName: String;
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; virtual; abstract;
    function getDestinationName(): String;
    function getActionName(): String;
  end;

implementation

{ TMailerAction }

function TMailerAction.getActionName: String;
begin
  Result := FActionName;
end;

function TMailerAction.getDestinationName: String;
begin
  Result := FDestinationName;
end;

end.
