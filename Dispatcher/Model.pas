unit Model;

interface

type
  TModel = class(TObject)

  public
    constructor Create();
    destructor Destroy(); override;

  end;

implementation

{ TModel }

constructor TModel.Create;
begin

end;

destructor TModel.Destroy;
begin

  inherited;
end;

end.
