unit MailerModel;

interface

uses
  FrontEndResponce, ProviderFactory, FrontEndRequest, BackEndSettings,
  Web.HTTPApp;

type
  TMailerModel = class
  strict private
    class var FFactory: TProviderFactory;
  public
    class function Elaborate(const aRequestor: string; const anAction: string;
      const aData: String; const AttachedFiles: TAbstractWebRequestFiles;
      const ASettings: TBackEndSettings): TFrontEndResponce;
    constructor Create();
  end;

implementation

uses
  Provider, Action, System.Contnrs, System.Generics.Collections,
  VenditoriSimple, SoluzioneAgenti, System.JSON, System.SysUtils,
  ObjectsMappers, FrontEndData;

{ TMailerModel }

constructor TMailerModel.Create;
var
  Providers: TObjectList<TProvider>;
begin
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
end;

class function TMailerModel.Elaborate(const aRequestor, anAction, aData: String;
  const AttachedFiles: TAbstractWebRequestFiles;
  const ASettings: TBackEndSettings): TFrontEndResponce;
var
  AJson: TJsonObject;
  Request: TFrontEndRequest;
  Provider: TProvider;
  Action: TAction;
  Responce: TFrontEndResponce;
  Input: TFrontEndData;

begin
  try
    AJSon := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(aData), 0) as TJSONObject;
    if (AJson <> nil) then
    begin
      Input := Mapper.JSONObjectToObject<TFrontEndData>(AJSon);
    end;
  except
    on E: Exception do
    begin
      AJSon := nil;
    end;
  end;
  Request := TFrontEndRequest.Create(Input, AttachedFiles);
  Provider := FFactory.FindByName(aRequestor);
  if (Provider <> nil) then
  begin
    Action := Provider.FindByName(anAction);
  end;
  if (Action <> nil) then
  begin
    Responce := Action.Elaborate(Request, ASettings);
  end
  else
  begin
    Responce := TFrontEndResponce.Create;
    Responce.msg := 'authorization missing...';
  end;
  Result := Responce;

end;

end.
