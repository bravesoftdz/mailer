unit ActionDispatcher;

interface

uses
  MailerAction, System.Generics.Collections, VenditoriOrder;

type
  { Abstract factory for producing mailer actions that should perform operations
    for given the requests }
  TActionDispatcher = class
  private
  var
    FDefaultAction: TMailerAction;
    { A dictionary of available mailer actions. 
      In order to avoid continiuos iteration over the list of available actions, 
      it is better to create an index in order to find quickly an action. }
    FIndex: TDictionary<String, TMailerAction>;
    { create the index of available actions. The index is a map from a string 
      key to an action. The key is a string calculated for each action. 
      No different actions may have equal keys. }
    function CreateIndex(const Actions: TObjectList<TMailerAction>): TDictionary<String, TMailerAction>;

    { create a key from two strings. These are two strings that are passed as a 
      received from the controller, so that it is important that the way in which
      the key is generated is correlated with the way it is generated for an action.
      If those ways are not correlated, no one action can be found to manage
      the requests from the controller. }
    function CreateKey(const key1, key2: String): String;
    function CreateActionKey(const Action: TMailerAction): String;
  public
    { Find an action that should manage the request. It must always return an action,
      no nil is allowed as the return value. }
    function FindAction(const Destination, Action: String): TMailerAction;
    constructor Create(const Actions: TObjectList<TMailerAction>; const DefaultAction: TMailerAction);
  end;

implementation

uses
  EmptyAction, System.SysUtils;

{ TActionDispatcher }

constructor TActionDispatcher.Create(const Actions: TObjectList<TMailerAction>; const DefaultAction: TMailerAction);
begin
  FDefaultAction := DefaultAction;
  FIndex := CreateIndex(Actions)
end;

function TActionDispatcher.CreateIndex(
  const Actions: TObjectList<TMailerAction>): TDictionary<String, TMailerAction>;
var
  worker: TMailerAction;
  Key: String;
begin
  Result := TDictionary<String, TMailerAction>.Create;
  for worker in Actions do
  begin
    Key := CreateKey(worker.getDestinationName, worker.getActionName);
    if Result.ContainsKey(Key) then
      raise Exception.Create('Failed to create the index of the actions: key "' + key + '" already exists.');
    Result.Add(Key, worker);
  end;
end;

function TActionDispatcher.CreateKey(const key1, key2: String): String;
begin
  Result := key1 + '/' + key2;
end;

function TActionDispatcher.CreateActionKey(const Action: TMailerAction): String;
begin
  Result := CreateKey(Action.getDestinationName, Action.getActionName);
end;

function TActionDispatcher.FindAction(const Destination,
  Action: String): TMailerAction;
var
  Key: String;
begin
  Key := CreateKey(Destination, Action);
  if FIndex.ContainsKey(Key) then
    Result := FIndex[Key]
  else
    Result := FDefaultAction;
end;

end.
