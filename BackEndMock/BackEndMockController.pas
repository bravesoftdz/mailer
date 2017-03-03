unit BackEndMockController;

interface

uses
  MVCFramework, MVCFramework.Commons, SendServerProxy.interfaces,
  BackEndResponce, BackEndRequest, FrontEndRequest;

type

  [MVCPath('/')]
  TBackEndMockController = class(TMVCController)
  public
    [MVCPath('/send')]
    [MVCHTTPMethod([httpPOST])]
    procedure send(const Ctx: TWebContext);

  protected
    procedure OnBeforeAction(Context: TWebContext; const AActionName: string; var Handled: Boolean); override;
    procedure OnAfterAction(Context: TWebContext; const AActionName: string); override;
  end;

implementation

uses
  MVCFramework.Logger, System.JSON, ObjectsMappers, System.Classes,
  System.SysUtils;

procedure TBackEndMockController.send(const Ctx: TWebContext);
var
  responce: TBackEndResponce;
  Ajson: TJsonObject;
  request: TBackEndRequest;
  reader: TStreamReader;
  data: UTF8String;
  builder: TStringBuilder;
begin
  responce := TBackEndResponce.Create;
  responce.status := false;
  Ajson := Ctx.Request.BodyAsJSONObject;
  request := Mapper.JSONObjectToObject<TBackEndRequest>(Ajson);
  builder := TStringBuilder.Create;
  builder.append(Ajson.toString);
  if (request.data <> nil) then
  begin
    request.data.Position := 0;
    reader := TStreamReader.Create(request.data);
    try
      builder.append(reader.ReadToEnd);
    finally
      reader.Close;
    end;
  end
  else
  begin
    builder.append('data is nil');
  end;
  responce.msgstat := builder.toString;
  builder.DisposeOf;
  Render(Mapper.ObjectToJSONObject(responce));
end;

procedure TBackEndMockController.OnAfterAction(Context: TWebContext; const AActionName: string);
begin
  { Executed after each action }
  inherited;
end;

procedure TBackEndMockController.OnBeforeAction(Context: TWebContext; const AActionName: string;
  var
  Handled:
  Boolean);
begin
  { Executed before each action
    if handled is true (or an exception is raised) the actual
    action will not be called }
  inherited;
end;

end.
