unit RequestSaverFactory;

interface

uses
  RequestStorageInterface, ServerConfig, RepositoryConfig;

type
  TRequestSaverFactory = class(TObject)
  public
    function CreateStorage(const Config: TRepositoryConfig): IRequestStorage;
  end;

implementation

uses
  RequestToFileSystemStorage, System.SysUtils;

{ TRequestSaverFactory }

function TRequestSaverFactory.CreateStorage(const Config: TRepositoryConfig): IRequestStorage;
begin
  if (Config <> nil) then
  begin
    if (Config.TypeName = 'filesystem') then
      Result := TRequestToFileSystemStorage.Create(Config)
    else
      raise Exception.Create('Failed to create a request saver: the only supported type is "filesystem", requested "' + Config.TypeName + '".');
  end
  else
    raise Exception.Create('Failed to select a request saver due to a nil configuration instance.');

end;

end.
