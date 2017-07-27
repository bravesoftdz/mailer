unit RepositoryConfig;

interface

uses ObjectsMappers;

type

  [MapperJSONNaming(JSONNameLowerCase)]
  TRepositoryConfig = class(TObject)
  strict private
  var
    FType: String;
    FDsn: String;

  public
    property TheType: String read FType write FType;
    property Dsn: String read FDsn write FDsn;
  end;

implementation

end.
