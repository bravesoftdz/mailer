unit OfferteNuoviMandati;

interface

uses
  Provider, Action;

type
  TOfferteNuoviMandati = class(TProvider)
  private
    const
    PATH = 'onm';
  public
    constructor Create;

  end;

implementation

uses
  System.Generics.Collections;

{ TOfferteNuoviMandati }

constructor TOfferteNuoviMandati.Create;
var
  Actions: TObjectList<TAction>;
begin
  Actions := TObjectList<TAction>.Create();
  Actions.AddRange([TOMNSendToClient.Create(), TOMNSendToCodicione.Create()]);
  inherited Create(PATH, Actions);
end;

end.
