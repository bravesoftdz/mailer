unit VenditoriSimple;

interface

uses
  Provider;

type
  TVenditoriSimple = class(TProvider)
  public
    constructor Create;
  end;

implementation

uses
  System.Generics.Collections, Action;

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
