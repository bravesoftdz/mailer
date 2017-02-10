unit Action;

interface

uses
  SimpleMailerResponce, SimpleInputData, OutputData, REST.JSON;

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

type
  TActionOrder = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
  end;

implementation

uses
  Credentials, System.JSON;

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
var
  builder:
    TOutputDataBuilder;
begin
  Result := TSimpleMailerResponce.Create;
  builder := TOutputDataBuilder.Create();
  builder.SetFrom(TVenditoriCredentials.From())
    .SetSender(TVenditoriCredentials.Name())
    .SetBody(Data.Data.GetValue('text').Value)
    .SetRecipTo(TVenditoriCredentials.Recipients);

  Result.message := TJson.ObjectToJsonString(builder.Build);
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

end.
