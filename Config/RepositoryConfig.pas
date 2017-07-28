unit RepositoryConfig;

interface

uses ObjectsMappers;

type

  /// <summary>
  /// A configuration for a repository.
  /// For the moment, it is supposed that there might be two types of repository:
  /// file system and database.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TRepositoryConfig = class(TObject)
  strict private
  const
    TYPE_KEY = 'type';
    DSN_KEY = 'dsn';

  var
    FType: String;
    FDsn: String;

  public

    /// <summary>the repository type</summary>
    [MapperJSONSer(TYPE_KEY)]
    property TypeName: String read FType write FType;
    /// <summary>string that contains information about how to connect to the repository.
    /// In case of a database repository, it is a string like
    /// "mysql://username:password@198.162.1.88:3306/dbname".
    /// In case of a file system repository, it is a string like
    /// "file://dir_1/dir_2/"
    /// </summary>
    [MapperJSONSer(DSN_KEY)]
    property Dsn: String read FDsn write FDsn;

    constructor Create(); overload;
    constructor Create(const AType, ADsn: String); overload;
  end;

implementation

{ TRepositoryConfig }

constructor TRepositoryConfig.Create;
begin
  FType := '';
  FDsn := '';
end;

constructor TRepositoryConfig.Create(const AType, ADsn: String);
begin
  FType := AType;
  FDsn := ADsn;
end;

end.
