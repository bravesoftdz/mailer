unit MailerAction;

interface

uses
  System.JSON, SimpleMailerResponce, SimpleInputData;

type
  TMailerAction = class
  public
    procedure SetInputData(const Data: TJSonObject);
    function Elaborate(const data: TSimpleInputData): TSimpleMailerResponce;
  end;

implementation

{ TMailerAction }

function TMailerAction.Elaborate(const data: TSimpleInputData): TSimpleMailerResponce;
begin
  Result := TSimpleMailerResponce.Create;
  Result.message := 'processing the input';
end;

procedure TMailerAction.SetInputData(const Data: TJSonObject);
begin
end;

end.
