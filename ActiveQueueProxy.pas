unit ActiveQueueProxy;

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
    function Send(const Request: TReceptionRequest): TActiveQueueResponce;
    class function getInstance(): TBackEndProxy;
    /// <summary>settings setter. Performs a defecieve copying.</summary>
    procedure SetSettings(const Settings: TActiveQueueSettings);
    /// <summary>settings getter. Returns a copy of the settings object.</summary>
    function GetSettings(): TActiveQueueSettings;

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

function TBackEndProxy.GetSettings: TActiveQueueSettings;
begin
  Result := TActiveQueueSettings.Create(FSettings.Url, FSettings.Port);
end;

function TBackEndProxy.Send(
  const
  Request:
  TReceptionRequest): TActiveQueueResponce;
var
  adapter: TRestAdapter<ISendServerProxy>;
  server: ISendServerProxy;
  Responce: TActiveQueueResponce;
begin
  adapter := TRestAdapter<ISendServerProxy>.Create();
  server := adapter.Build(FSettings.Url, FSettings.Port);
end;

procedure TBackEndProxy.SetSettings(
  const
  Settings:
  TActiveQueueSettings);
begin
  FSettings := TActiveQueueSettings.Create(Settings.Url, Settings.Port);
end;

end.
