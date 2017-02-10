unit Action;

interface

uses
  SimpleMailerResponce, SimpleInputData, SenderInputData;

type
  TAction = class
  private
    function GetName: String;
  protected
    FName: String;
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; virtual; abstract;
    procedure SetData(const Data: TSenderInputData); virtual; abstract;
    property Name: String read GetName;
    constructor Create(const Name: String);
  end;

type
  TActionSend = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    procedure SetData(const Data: TSenderInputData); override;
    constructor Create();
  end;

type
  TActionContact = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    procedure SetData(const Data: TSenderInputData); override;
    constructor Create();
  end;

type
  TActionOrder = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    procedure SetData(const Data: TSenderInputData); override;
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

procedure TActionSend.SetData(const Data: TSenderInputData);
begin
  /// stub
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

procedure TActionContact.SetData(const Data: TSenderInputData);
begin
  /// stub
end;

{ TActionOrder }

constructor TActionOrder.Create;
begin
  inherited Create('order');
end;

function TActionOrder.Elaborate(
  const Data: TSimpleInputData): TSimpleMailerResponce;
begin
  /// stub
  Result := TSimpleMailerResponce.Create;
  Result.message := 'contact action: not implemented yet';
end;

procedure TActionOrder.SetData(const Data: TSenderInputData);
begin
  /// stub
end;

end.
