unit MailerAction;

interface

uses
  System.JSON, SimpleMailerResponce, SimpleInputData;

type
  TMailerAction = class
  private
    FDestination: String;
    FAction: String;
  public
    procedure SetInputData(const Data: TJSonObject);
    function Elaborate(const data: TSimpleInputData): TSimpleMailerResponce;
    constructor Create(const destination, action: String);
  end;

implementation

{ TMailerAction }

constructor TMailerAction.Create(const destination, action: String);
begin
  FAction := action;
  FDestination := destination;
end;

function TMailerAction.Elaborate(const data: TSimpleInputData): TSimpleMailerResponce;
begin
  Result := TSimpleMailerResponce.Create;
  Result.message := 'processing action ' + FAction + '  for ' + FDestination;
end;

procedure TMailerAction.SetInputData(const Data: TJSonObject);
begin
end;

end.
