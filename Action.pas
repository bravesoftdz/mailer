unit Action;

interface

uses
  SimpleMailerResponce, SimpleInputData;

type
  TAction = class
  private
    function GetName: String;
  protected
    FName: String;
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; virtual; abstract;
    property Name: String read GetName;
    constructor Create(const Name: String);
  end;

implementation

{ TMailerAction }

constructor TAction.Create(const Name: String);
begin
  FName := Name;
end;

function TAction.GetName: String;
begin
  Result := FName;
end;

end.
