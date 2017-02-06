unit ProviderFactory;

interface

uses
  Action, System.Generics.Collections, Provider;

type
  { Abstract factory for producing mailer actions that should perform operations
    for given the requests }
  TProviderFactory = class
  private
  var
    { A dictionary of available providers.
      In order to avoid perpetous iterations over the list of available providers,
      it is better to construct an index in order to access them quickly. }
    FIndex: TDictionary<String, TProvider>;
    { create the index of available actions. The index is a map from a string
      key to an action. The key is a string calculated for each action.
      No different actions may have equal keys. }
    function CreateIndex(const Providers: TObjectList<TProvider>): TDictionary<String, TProvider>;

    { create a key from two strings. These are two strings that are passed as a
      received from the controller, so that it is important that the way in which
      the key is generated is correlated with the way it is generated for an action.
      If those ways are not correlated, no one action can be found to manage
      the requests from the controller. }
    function CreateKey(const Provider: TProvider; const Action: TAction): String;
    // function CreateActionKey(const Action: TMailerAction): String;
  public
    { Find a provider that should manage the request. It must always return an instance,
      no nil is allowed as the return value. }
    function FindByName(const Name: String): TProvider;
    constructor Create(const Providers: TObjectList<TProvider>);
  end;

implementation

uses
  System.SysUtils;

{ TActionDispatcher }

constructor TProviderFactory.Create(const Providers: TObjectList<TProvider>);
begin
  FIndex := CreateIndex(Providers);
end;

function TProviderFactory.CreateIndex(
  const Providers: TObjectList<TProvider>): TDictionary<String, TProvider>;
var
  Provider: TProvider;
  Path: String;
begin
  Result := TDictionary<String, TProvider>.Create;
  for Provider in Providers do
  begin
    Path := Provider.getPath();
    if Result.ContainsKey(Path) then
      raise Exception.Create('Failed to create the index of the provider: path "' + Path + '" already exists.');
    Result.Add(Path, Provider);
  end;
end;

function TProviderFactory.CreateKey(const Provider: TProvider;
  const Action: TAction): String;
begin
  Result := Provider.getPath() + '/' + Action.Name;
end;

function TProviderFactory.FindByName(const Name: String): TProvider;
begin
  if FIndex.ContainsKey(Name) then
    Result := FIndex[Name]
  else
    Result := nil;
end;

end.
