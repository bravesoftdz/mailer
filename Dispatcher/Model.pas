unit Model;

interface

uses
  DispatcherConfig;

type
  TModel = class(TObject)

  strict private
  var
    FConfig: TDispatcherConfig;

    function GetConfig(): TDispatcherConfig;
    procedure SetConfig(const Config: TDispatcherConfig);

  public
    function GetPort(): Integer;
    property Config: TDispatcherConfig read GetConfig write SetConfig;
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

{ TModel }

constructor TModel.Create;
begin

end;

destructor TModel.Destroy;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  inherited;
end;

function TModel.GetConfig: TDispatcherConfig;
begin
  Result := TDispatcherConfig.Create(FConfig.Port);
end;

function TModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port;
end;

procedure TModel.SetConfig(const Config: TDispatcherConfig);
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  FConfig := TDispatcherConfig.Create(Config.Port);

end;

end.
