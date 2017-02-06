unit ActionSend;

interface

uses
  Action, SimpleInputData, SimpleMailerResponce;

type
  TActionSend = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
  end;

implementation

{ TActionSend }

constructor TActionSend.Create;
begin
  inherited Create('send')
end;

function TActionSend.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
begin
  /// stub
  Result := TSimpleMailerResponce.Create;
  Result.message := 'not implemented yet';
end;

end.
