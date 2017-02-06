unit VenditoriSimple;

interface

uses
  SimpleInputData, SimpleMailerResponce, Provider, Action;

type
  TVenditoriSimple = class(TProvider)
  public
    constructor Create;
  end;

implementation

uses
  System.Generics.Collections, ActionSend;

{ TVenditoriOrder }

constructor TVenditoriSimple.Create;
var
  Actions: TObjectList<TAction>;
begin
  Actions := TObjectList<TAction>.Create();
  Actions.AddRange([TActionSend.Create()]);
  inherited Create('venditori', Actions);
end;

end.
