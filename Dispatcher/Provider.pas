unit Provider;

interface

uses
  FrontEndRequest, System.Generics.Collections, Actions;

type
  TProvider = class(TObject)
  protected
    FPath: String;
    FActions: TObjectList<TAction>;
  private
    function GetActions: TObjectList<TAction>;
  public
    { a part of the RESTful path to which current provider must respond }
    function GetPath(): String;
    constructor Create(const Path: String; const Actions: TObjectList<TAction>);
    destructor Destroy(); override;
    property Actions: TObjectList<TAction> read GetActions;
  end;

implementation

uses
  System.SysUtils;

{ TMailerAction }

constructor TProvider.Create(const Path: String; const Actions: TObjectList<TAction>);
var
  AnAction: TAction;
begin
  Writeln('Provider ' + Path + ' create');
  FPath := Path;
  FActions := TObjectList<TAction>.Create;
  for AnAction in Actions do
    FActions.Add(AnAction.Clone())
end;

destructor TProvider.Destroy;
var
  Action: TAction;
begin
  FActions.Clear;
  FActions.DisposeOf;
  inherited;
end;

function TProvider.GetActions: TObjectList<TAction>;
var
  Action: TAction;
begin
  Result := TObjectList<TAction>.Create;
  for Action in FActions do
    Result.Add(Action.Clone);

end;

function TProvider.getPath: String;
begin
  Result := FPath;
end;

end.

