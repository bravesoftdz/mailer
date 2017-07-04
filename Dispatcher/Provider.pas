unit Provider;

interface

uses
  Responce, FrontEndRequest, System.Generics.Collections, Action;

type
  TProvider = class(TObject)
  protected
    FPath: String;
    FActions: TObjectList<TAction>;
  private
  public
    { a part of the RESTful path to which current provider must respond }
    function GetPath(): String;
    constructor Create(const Path: String; const Actions: TObjectList<TAction>); virtual;
    destructor Destroy(); override;
    property Actions: TObjectList<TAction> read FActions;
  end;

implementation

uses
  System.SysUtils;

{ TMailerAction }

constructor TProvider.Create(const Path: String; const Actions: TObjectList<TAction>);
var
  Action: TAction;
begin
  Writeln('Provider ' + Path + ' create');
  FPath := Path;
  FActions := TObjectList<TAction>.Create;
  for Action in Actions do
    FActions.Add(Action.Clone())
end;

destructor TProvider.Destroy;
begin
  FActions.Clear;
  FActions.DisposeOf;
  inherited;
end;

function TProvider.getPath: String;
begin
  Result := FPath;
end;

end.
