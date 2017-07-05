unit ProviderFactory;

interface

uses
  Actions, System.Generics.Collections, Provider;

type
  { Abstract factory for producing mailer actions that should perform operations
    for given the requests }
  TProviderFactory = class(TObject)
  private
  var
    /// <summary> A dictionary of available providers.
    /// In order to avoid perpetous iterations over the list of available providers,
    /// it is better to construct an index in order to access them quickly. </summary>
    FIndex: TDictionary<String, TObjectList<TAction>>;
    /// <summary> create the index of available actions. The index is a map from a string
    /// key to a list of actions: to a path "agent321/send" might correspond various actions.
    /// The key is a string calculated based on provider and action.</summary>
    function CreateIndex(const Providers: TObjectList<TProvider>): TDictionary<String, TObjectList<TAction>>;

    /// <summary> create a key from two strings. These are two strings that are
    /// received from the controller, so that it is important that the way in which
    /// the key is generated is correlated with the way it is generated for an action.
    /// If those ways are not correlated, no one action can be found to manage
    /// the requests from the controller. </summary>
    /// <param name="Provider">data provider</param>
    /// <param name="Action">action to be performed</param>
    function CreateKey(const Provider: TProvider; const Action: TAction): String; overload;
    /// <summary>Create a key from given strings.</summary>
    function CreateKey(const Part1, Part2: String): String; overload;
  public
    /// <summary>Find actions of all providers that can elaborate data coming from a Requestor
    /// with a specific action. For example, if a requestor is "agent321" and the acton is "register",
    /// then a list of actions should be returned: an action for saving data in db, an action for sending
    /// a notification to the client etc.</summary>
    function FindActions(const Requestor: String; const Act: String): TObjectList<TAction>;
    constructor Create(const Providers: TObjectList<TProvider>);
    destructor Destroy(); override;
  end;

implementation

uses
  System.SysUtils;

{ TActionDispatcher }

constructor TProviderFactory.Create(const Providers: TObjectList<TProvider>);
begin
  Writeln('Provider factory create');
  FIndex := CreateIndex(Providers);
end;

function TProviderFactory.CreateIndex(const Providers: TObjectList<TProvider>): TDictionary<String, TObjectList<TAction>>;
var
  aProvider: TProvider;
  Key: String;
  Actions: TObjectList<TAction>;
  anAction: TAction;
begin
  Writeln('Creating the index...');
  Result := TDictionary < String, TObjectList < TAction >>.Create();
  for aProvider in Providers do
  begin
    Actions := aProvider.Actions;
    for anAction in Actions do
    begin
      Key := CreateKey(aProvider, anAction);
      if not(Result.ContainsKey(Key)) then
      begin
        Writeln('Create a key ' + Key + ' in the dictionary.');
        Result.Add(Key, TObjectList<TAction>.Create);
      end;
      Writeln('Append an action ' + anAction.Category + 'to the key ' + Key);
      Result[Key].Add(anAction.Clone())
    end;
    Actions.Clear;
    Actions.DisposeOf;
  end;
end;

function TProviderFactory.CreateKey(const Part1, Part2: String): String;
begin
  Result := Part1 + '/' + Part2;
end;

function TProviderFactory.CreateKey(const Provider: TProvider;
  const Action: TAction): String;
begin
  Result := CreateKey(Provider.getPath(), Action.Category);
end;

destructor TProviderFactory.Destroy;
var
  key: String;
begin
  for Key in FIndex.Keys do
    FIndex[Key].DisposeOf;
  FIndex.Clear;
  FIndex.DisposeOf;
  inherited;
end;

function TProviderFactory.FindActions(const Requestor, Act: String): TObjectList<TAction>;
var
  Key: String;
  Action: TAction;
begin
  Result := TObjectList<TAction>.Create();
  Key := CreateKey(Requestor, Act);
  if FIndex.ContainsKey(Key) then
  begin
    for Action in FIndex[Key] do
      Result.Add(Action.Clone);
  end;

end;

end.
