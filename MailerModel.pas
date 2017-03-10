unit MailerModel;

interface

uses
  FrontEndResponce, ProviderFactory, FrontEndRequest, BackEndSettings;

type
  TMailerModel = class
  strict private
    class var FFactory: TProviderFactory;
  public
    class function Elaborate(const aRequestor: string; const anAction: string; const aRequest: TFrontEndRequest; const ASettings: TBackEndSettings): TFrontEndResponce;
    constructor Create();
  end;

implementation

uses
  Provider, Action, System.Contnrs, System.Generics.Collections,
  VenditoriSimple, SoluzioneAgenti;

{ TMailerModel }

constructor TMailerModel.Create;
var
  Providers: TObjectList<TProvider>;
begin
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
end;

class function TMailerModel.Elaborate(const aRequestor: string;
  const anAction: string; const aRequest: TFrontEndRequest;
  const ASettings: TBackEndSettings): TFrontEndResponce;
var
  Provider: TProvider;
  Action: TAction;
  Responce: TFrontEndResponce;
begin
  Provider := FFactory.FindByName(aRequestor);
  if (Provider <> nil) then
  begin
    Action := Provider.FindByName(anAction);
  end;

  if (Action <> nil) then
  begin
    Responce := Action.Elaborate(aRequest, ASettings);
  end
  else
  begin
    Responce := TFrontEndResponce.Create;
    Responce.msg := 'authorization missing...';
  end;

  Result := Responce;
end;

end.
