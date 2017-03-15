unit BackEndProxy;

interface

uses
  BackEndRequest, BackEndResponce, BackEndSettings;

type
  TBackEndProxy = class
  strict private
    class var FInstance: TBackEndProxy;
    constructor Create();

  var
    FSettings: TBackEndSettings;

  public
    function Send(const Request: TBackEndRequest): TBackEndResponce;
    class function getInstance(): TBackEndProxy;
    procedure SetSettings(const Settings: TBackEndSettings);

  end;

implementation

uses
  MVCFramework.RESTAdapter, SendServerProxy.interfaces;

{ TBackEndProxy }

constructor TBackEndProxy.Create;
begin

end;

class function TBackEndProxy.getInstance: TBackEndProxy;
begin
  if not Assigned(Self.FInstance) then
    Self.FInstance := TBackEndProxy.Create();
  Result := Self.FInstance;
end;

function TBackEndProxy.Send(const Request: TBackEndRequest): TBackEndResponce;
var
  adapter: TRestAdapter<ISendServerProxy>;
  server: ISendServerProxy;
  Responce: TBackEndResponce;
begin
  adapter := TRestAdapter<ISendServerProxy>.Create();
   server := adapter.Build(FSettings.Url, FSettings.Port);
end;

procedure TBackEndProxy.SetSettings(const Settings: TBackEndSettings);
begin
  FSettings := TBackEndSettings.Create(Settings.Url, Settings.Port);
end;

end.
