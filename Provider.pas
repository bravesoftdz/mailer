unit Provider;

interface

uses
  ReceptionResponce, FrontEndRequest, System.Generics.Collections, Action;

type
  TProvider = class
  protected
    FPath: String;
    FIndex: TDictionary<String, TAction>;
  private
    function createIndex(const Actions: TObjectList<TAction>): TDictionary<String, TAction>;
  public
    { a part of the RESTful path to which current provider must respond }
    function getPath(): String;
    function FindByName(const Name: String): TAction;
    constructor Create(const Path: String; const Actions: TObjectList<TAction>); virtual;
  end;

implementation

uses
  System.SysUtils;

{ TMailerAction }

constructor TProvider.Create(const Path: String; const Actions: TObjectList<TAction>);
begin
  FPath := Path;
  FIndex := CreateIndex(Actions);
end;

function TProvider.createIndex(
  const Actions: TObjectList<TAction>): TDictionary<String, TAction>;
var
  Action: TAction;
  Name: String;
begin
  Result := TDictionary<String, TAction>.Create;
  for Action in Actions do
  begin
    Name := Action.Name;
    if Not(Result.ContainsKey(Name)) then
      Result.Add(Name, Action)
    else
      raise Exception.Create('Duplicate action name: ' + Name)
  end;
end;

function TProvider.FindByName(const Name: String): TAction;
begin
  if FIndex.ContainsKey(Name) then
    Result := FIndex[Name]
  else
    Result := nil;
end;

function TProvider.getPath: String;
begin
  Result := FPath;
end;

end.
