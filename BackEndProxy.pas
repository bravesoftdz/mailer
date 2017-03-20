unit BackEndProxy;

interface

uses
  ReceptionRequest, ActiveQueueResponce, ActiveQueueSettings;

type
  TBackEndProxy = class
  strict private
    class var FInstance: TBackEndProxy;
    constructor Create();

  var
    FSettings: TActiveQueueSettings;

  public
    function Send(const Request: TBackEndRequest): TActiveQueueResponce;
    class function getInstance(): TBackEndProxy;
    procedure SetSettings(const Settings: TActiveQueueSettings);

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

function TBackEndProxy.Send(const Request: TBackEndRequest): TActiveQueueResponce;
var
  adapter: TRestAdapter<ISendServerProxy>;
  server: ISendServerProxy;
  Responce: TActiveQueueResponce;
begin
  adapter := TRestAdapter<ISendServerProxy>.Create();
   server := adapter.Build(FSettings.Url, FSettings.Port);
end;

procedure TBackEndProxy.SetSettings(const Settings: TActiveQueueSettings);
begin
  FSettings := TActiveQueueSettings.Create(Settings.Url, Settings.Port);
end;

end.
