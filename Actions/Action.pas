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

type
  TActionSend = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
  end;

type
  TActionContact = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
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

constructor TActionSend.Create;
begin
  inherited Create('send')
end;

function TActionSend.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
begin
  /// stub
  Result := TSimpleMailerResponce.Create;
  Result.message := 'send action: not implemented yet';
end;

{ TActionContact }

constructor TActionContact.Create;
begin
  inherited Create('contact');
end;

function TActionContact.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
begin
  /// stub
  Result := TSimpleMailerResponce.Create;
  Result.message := 'contact action: not implemented yet';

end;

end.
