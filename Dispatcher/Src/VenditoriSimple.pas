unit VenditoriSimple;

interface

uses
  Provider, Actions;

type
  { Perform the operations related to the site "venditori.com".
    The class contains the following actions:
    1. Send
    2. Contact
  }
  TVenditoriSimple = class(TProvider)
  private
    const
    PATH = 'venditori';
  public
    constructor Create;
  end;

implementation

uses
  System.Generics.Collections, System.Classes;

{ TVenditoriOrder }

constructor TVenditoriSimple.Create;
var
  Actions: TObjectList<TAction>;
begin
  Actions := TObjectList<TAction>.Create();
  Actions.AddRange([TActionSend.Create, TActionSend.Create]);
  inherited Create(PATH, Actions);
  Actions.Clear;
  Actions.DisposeOf;

end;

end.
