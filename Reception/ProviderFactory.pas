unit ProviderFactory;

interface

uses
  Action, System.Generics.Collections, Provider;

type
  { Abstract factory for producing mailer actions that should perform operations
    for given the requests }
  TProviderFactory = class(TObject)
  private
  var
    /// <summary> A dictionary of available providers.
    /// In order to avoid perpetous iterations over the list of available providers,
    /// it is better to construct an index in order to access them quickly. </summary>
    FIndex: TDictionary<String, TProvider>;
    /// <summary> create the index of available actions. The index is a map from a string
    /// key to an action. The key is a string calculated for each action.
    /// No different actions may have equal keys.  </summary>
    function CreateIndex(const Providers: TObjectList<TProvider>): TDictionary<String, TProvider>;

    /// <summary> create a key from two strings. These are two strings that are passed as a
    /// received from the controller, so that it is important that the way in which
    /// the key is generated is correlated with the way it is generated for an action.
    /// If those ways are not correlated, no one action can be found to manage
    /// the requests from the controller. </summary>
    /// <param name="Provider">data provider</param>
    /// <param name="Action">action to be performed</param>
    function CreateKey(const Provider: TProvider; const Action: TAction): String;
  public
    /// <summary> Find a provider that should manage the request. If no provider
    /// can handle the request, nil is returned. </summary>
    /// <param name="Name">string by which a provider must be found</param>
    function FindByName(const Name: String): TProvider;
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

function TProviderFactory.CreateIndex(const Providers: TObjectList<TProvider>): TDictionary<String, TProvider>;
var
  Provider: TProvider;
  Path: String;
  Actions: TObjectList<TAction>;
begin
  Result := TDictionary<String, TProvider>.Create;
  for Provider in Providers do
  begin
    Path := Provider.getPath();
    if Result.ContainsKey(Path) then
      raise Exception.Create('Failed to create the index of the provider: path "' + Path + '" already exists.');
    Actions := Provider.getActions;
    Result.Add(Path, TProvider.Create(Path, Actions));
    Actions.Clear;
    Actions.DisposeOf;
  end;
end;

function TProviderFactory.CreateKey(const Provider: TProvider;
  const Action: TAction): String;
begin
  Result := Provider.getPath() + '/' + Action.Name;
end;

destructor TProviderFactory.Destroy;
var
  key: String;
begin
  Writeln('Provider factory destroy');
  for key in FIndex.Keys do
    FIndex[key].DisposeOf;
  FIndex.Clear;
  FIndex.DisposeOf;
  inherited;
end;

function TProviderFactory.FindByName(const Name: String): TProvider;
begin
  if FIndex.ContainsKey(Name) then
    Result := FIndex[Name]
  else
    Result := nil;
end;

end.
