unit ReceptionModel;

interface

uses
  ReceptionResponce, ProviderFactory, FrontEndRequest, ActiveQueueSettings,
  Web.HTTPApp;

type
  TReceptionModel = class
  strict private
    class var FFactory: TProviderFactory;
  public
    /// <summary>
    /// Elaborate an action from a requestor. The request might contain a plain
    /// text data and attachments.</summary>
    /// <param name="Requestor">who requests the action</param>
    /// <param name="anAction">what action should be performed</param>
    /// <param name="aData">a string version of a json to be passed to the action executor</param>
    /// <param name="AttachedFiles">provided files to be passed to the executor</param>
    /// <param name="ASettings">Settings for the back end server</param>
    class function Elaborate(const Requestor: string; const anAction: string;
      const aData: String; const AttachedFiles: TAbstractWebRequestFiles;
      const ASettings: TActiveQueueSettings): TReceptionResponce;
    constructor Create();
  end;

implementation

uses
  Provider, Action, System.Contnrs, System.Generics.Collections,
  VenditoriSimple, SoluzioneAgenti, System.JSON, System.SysUtils,
  ObjectsMappers, FrontEndData;

{ TMailerModel }

constructor TReceptionModel.Create;
var
  Providers: TObjectList<TProvider>;
begin
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
end;

class function TReceptionModel.Elaborate(const Requestor, anAction, aData: String;
  const AttachedFiles: TAbstractWebRequestFiles;
  const ASettings: TActiveQueueSettings): TReceptionResponce;
var
  AJson: TJsonObject;
  Request: TFrontEndRequest;
  Provider: TProvider;
  Action: TAction;
  Responce: TReceptionResponce;
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
  Provider := FFactory.FindByName(Requestor);
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
    Responce := TReceptionResponce.Create;
    Responce.msg := 'authorization missing...';
  end;
  Result := Responce;

end;

end.
