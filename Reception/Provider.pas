unit Provider;

interface

uses
  Responce, FrontEndRequest, System.Generics.Collections, Action;

type
  TProvider = class(TObject)
  protected
    FPath: String;
    FIndex: TDictionary<String, TAction>;
  private
    /// Create an index of available action. The actions are indexed by their names.
    /// A TAction instance that gets inserted into the resulting dictionary is a copy of an action
    /// of the list passed as the parameter to this method.
    function createIndex(const Actions: TObjectList<TAction>): TDictionary<String, TAction>;
  public
    { a part of the RESTful path to which current provider must respond }
    function getPath(): String;
    /// Returns a copy of actions
    function getActions(): TObjectList<TAction>;
    function FindByName(const Name: String): TAction;
    constructor Create(const Path: String; const Actions: TObjectList<TAction>); virtual;
    destructor Destroy(); override;
  end;

implementation

uses
  System.SysUtils;

{ TMailerAction }

constructor TProvider.Create(const Path: String; const Actions: TObjectList<TAction>);
begin
  Writeln('Provider ' + Path + ' create');
  FPath := Path;
  FIndex := CreateIndex(Actions);
end;

function TProvider.createIndex(const Actions: TObjectList<TAction>): TDictionary<String, TAction>;
var
  Action: TAction;
  Name: String;
begin
  Result := TDictionary<String, TAction>.Create;
  for Action in Actions do
  begin
    Name := Action.Name;
    if Not(Result.ContainsKey(Name)) then
      Result.Add(Name, TAction.Create(Name))
    else
      raise Exception.Create('Duplicate action name: ' + Name)
  end;
end;

destructor TProvider.Destroy;
var
  Key: String;
begin
  for Key in FIndex.Keys do
    FIndex[Key].DisposeOf;
  FIndex.Clear;
  FIndex.DisposeOf;
  inherited;
end;

function TProvider.FindByName(const Name: String): TAction;
begin
  if FIndex.ContainsKey(Name) then
    Result := FIndex[Name]
  else
    Result := nil;
end;

function TProvider.getActions: TObjectList<TAction>;
var
  k: String;
begin
  Result := TObjectList<TAction>.Create();
  for k in FIndex.Keys do
    Result.Add(TAction.Create(FIndex[k].Name));
end;

function TProvider.getPath: String;
begin
  Result := FPath;
end;

end.
