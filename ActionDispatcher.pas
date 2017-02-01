unit ActionDispatcher;

interface

uses
  MailerAction;

type
  { Abstract factory for producing mailer actions that should perform operations
    for given the requests }
  TActionDispatcher = class
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
begin
  /// stub
  if (Destination = 'venditori') AND (Action = 'order') then
    Result := TVenditoriOrder.Create()
  else
    Result := TEmptyAction.Create;;
end;

end.
