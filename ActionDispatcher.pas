unit ActionDispatcher;

interface

uses
  MailerAction, System.Generics.Collections;

type
  { Abstract factory for producing mailer actions that should perform operations
    for given the requests }
  TActionDispatcher = class
  private
    class var FActions: TObjectList<TMailerAction>;
  public
    class function FindAction(const Destination, Action: String): TMailerAction;
  end;

implementation

uses
  VenditoriOrder, EmptyAction;

{ TActionDispatcher }

{ Find an action that should manage the request. It must always return an action,
  no nil is allowed as the return value. }
class function TActionDispatcher.FindAction(const Destination,
  Action: String): TMailerAction;
var
  worker: TMailerAction;
begin
  for worker in FActions do
  begin
    if (worker.getDestinationName = Destination) AND (worker.getActionName = Action) then
    begin
      Result := worker;
      Exit;
    end;
  end;
  Result := TEmptyAction.Create;
end;

initialization

TActionDispatcher.FActions := TObjectList<TMailerAction>.Create;
TActionDispatcher.FActions.Add(TVenditoriOrder.Create);

finalization

TActionDispatcher.FActions[0].DisposeOf;
TActionDispatcher.FActions.Clear;
TActionDispatcher.FActions.DisposeOf;

end.
