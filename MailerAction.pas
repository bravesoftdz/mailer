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
    constructor Create(const DestinationName, ActionName: String); virtual;
  end;

implementation

{ TMailerAction }

constructor TMailerAction.Create(const DestinationName, ActionName: String);
begin
  FDestinationName := DestinationName;
  FActionName := ActionName;
end;

function TMailerAction.getActionName: String;
begin
  Result := FActionName;
end;

function TMailerAction.getDestinationName: String;
begin
  Result := FDestinationName;
end;

end.
