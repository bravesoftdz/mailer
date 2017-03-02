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
  MVCFramework.Logger, System.JSON, ObjectsMappers, System.Classes;

procedure TBackEndMockController.send(const Ctx: TWebContext);
var
  responce: TBackEndResponce;
  Ajson: TJsonObject;
  request: TBackEndRequest;
  list: TStringList;
  data: String;
begin
  responce := TBackEndResponce.Create;
  responce.status := false;
  Ajson := Ctx.Request.BodyAsJSONObject;
  request := Mapper.JSONObjectToObject<TBackEndRequest>(Ajson);
  list := TStringList.Create();
  list.loadfromstream(request.data);


  responce.msgstat := Ajson.ToString + ' ---> ' + list.text;
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
