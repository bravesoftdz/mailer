unit VenditoriSimple;

interface

uses
  Provider, Action;

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
  System.Generics.Collections, ActionSend;

{ TVenditoriOrder }

constructor TVenditoriSimple.Create;
var
  Actions: TObjectList<TAction>;
  ActionSend, ActionOrder: TAction;
begin
  Actions := TObjectList<TAction>.Create();
  ActionSend := TActionSend.Create;
  ActionOrder := TActionOrder.Create;

  Actions.AddRange([ActionSend, ActionOrder]);
  inherited Create(PATH, Actions);
end;

end.
