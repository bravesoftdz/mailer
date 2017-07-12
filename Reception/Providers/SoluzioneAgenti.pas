unit SoluzioneAgenti;

interface

uses
  Provider, Actions;

type
  { Perform the operations related to the site "soluzioneagenti.it".
    The class contains the following actions:
    1. Send
    2. Contact
  }
  TSoluzioneAgenti = class(TProvider)
  private
    const
    PATH = 'soluzione-agenti';
  public
    constructor Create;
  end;

implementation

uses
  System.Generics.Collections;

{ TSoluzioneAgenti }

constructor TSoluzioneAgenti.Create;
var
  Actions: TObjectList<TAction>;
begin
  Actions := TObjectList<TAction>.Create();
  Actions.AddRange([TActionSend.Create(), TActionContact.Create()]);
  inherited Create(PATH, Actions);
  Actions.Clear;
  Actions.DisposeOf;
end;

end.
