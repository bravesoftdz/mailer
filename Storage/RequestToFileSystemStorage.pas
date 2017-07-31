unit RequestToFileSystemStorage;

interface

uses
  RequestStorageInterface, System.JSON, RepositoryConfig, MVCFramework.Logger,
  System.SysUtils, System.Generics.Collections;

type
  TRequestToFileSystemStorage<T: Class, constructor> = class(TInterfacedObject, IRequestStorage<T>)
  strict private
  const
    /// <summary>name of the folder inside the working one in which incoming requests should be stored</summary>
    INCOMING_FOLDER_NAME = 'incoming' + PathDelim;

    /// <summary>name of the folder inside the working one in which requests that have been already elaborated should be stored</summary>
    ELABORATED_FOLDER_NAME = 'elaborated' + PathDelim;

    /// <summary>pattern to extract a name of the working folder from the config instance</summary>
    WORKING_DIR_PATTERN = '^file:\/\/(.*)$';

    FFileExtension = '.txt';
    FFileName = 'request';
    Suffix = '-YYYY-mm-dd-hh-nn-ss';

    /// tag for the logger
    TAG = 'TRequestToFileSystemStorage';

  var
    FWorkingFolder: String;
    FIncomingFolder: String;
    FElaboratedFolder: String;

    function GetAvailableName(): String;

    /// <summary>Try to create a folder with given path. If it exists, do nothing.</summary>
    procedure CreateFolderIfNotExist(const Path: String);

  public
    constructor Create(const WorkingFolder: String); overload;
    constructor Create(const Config: TRepositoryConfig); overload;

    function Save(const Obj: TJsonObject): String;
    function Delete(const Id: String): Boolean;
    function GetParams(): TArray<TPair<String, String>>;
    function GetPendingRequests(): Integer;

  end;

implementation

uses
  System.IOUtils, System.RegularExpressions, System.Types, System.TypInfo, ObjectsMappers;

{ TRequestToFileSystemStorage }

constructor TRequestToFileSystemStorage<T>.Create(const WorkingFolder: String);
begin
  Log.Warn('Create: this constructor is deprecated. Use TRequestToFileSystemStorage.Create(const Config: TRepositoryConfig) instead', TAG);
  FWorkingFolder := WorkingFolder;
  if not(TDirectory.Exists(FWorkingFolder)) then
    TDirectory.CreateDirectory(FWorkingFolder);
end;

constructor TRequestToFileSystemStorage<T>.Create(const Config: TRepositoryConfig);
var
  Temp: TMatch;
begin
  if (Config = nil) then
    Log.Warn('No config file is provided in TRequestToFileSystemStorage constructor', TAG)
  else
  begin
    Temp := TRegEx.Match(Config.Dsn, WORKING_DIR_PATTERN);
    if (Temp.Groups.Count = 2) then
    begin
      FWorkingFolder := StringReplace(Temp.Groups.Item[1].Value, '/', PathDelim, [rfReplaceAll, rfIgnoreCase]);
      if (TPath.IsRelativePath(FWorkingFolder)) then
        FWorkingFolder := GetCurrentDir + PathDelim + FWorkingFolder;
      FIncomingFolder := FWorkingFolder + INCOMING_FOLDER_NAME;
      FElaboratedFolder := FWorkingFolder + ELABORATED_FOLDER_NAME;
      CreateFolderIfNotExist(FWorkingFolder);
      CreateFolderIfNotExist(FIncomingFolder);
      CreateFolderIfNotExist(FElaboratedFolder);
    end
    else
    begin
      Log.warn('Problem with matching pattern ''' + WORKING_DIR_PATTERN + ''' against string ''' + Config.Dsn + '''.', TAG);
    end;
  end;
end;

procedure TRequestToFileSystemStorage<T>.CreateFolderIfNotExist(const Path: String);
begin
  if not(TDirectory.Exists(Path)) then
    try
      TDirectory.CreateDirectory(Path);
    except
      on E: Exception do
      begin
        Log.Error('CreateFolderIfNotExist : error when creating a repository folder "' + Path + '"', TAG);
      end;
    end;
end;

function TRequestToFileSystemStorage<T>.Delete(const Id: String): Boolean;
var
  FullPath: String;
begin
  FullPath := FWorkingFolder + Id + FFileExtension;
  if not(TFile.Exists(FullPath)) then
    Result := False
  else
  begin
    try
      Writeln('Deleting file ' + FullPath);
      TFile.Delete(FullPath);
      Result := True;
    except
      on E: Exception do
      begin
        raise Exception.Create('File system storage failed to remove file ' + id);
      end;
    end
  end;

end;

function TRequestToFileSystemStorage<T>.GetAvailableName: String;
var
  FullPath: String;
  Counter: Integer;
  NewName, BaseName: String;
begin
  FullPath := FWorkingFolder + FFileName + FFileExtension;
  if not(TFile.Exists(FullPath)) then
    Result := FFileName
  else
  begin
    BaseName := FFileName + formatdatetime(Suffix, Now());
    NewName := BaseName;
    FullPath := FWorkingFolder + BaseName + FFileExtension;
    Counter := 1;
    while (TFile.Exists(FullPath)) do
    begin
      NewName := Format('%s-%d', [BaseName, Counter]);
      FullPath := FWorkingFolder + NewName + FFileExtension;;
      Counter := Counter + 1;
      Writeln('Loop: new name = ' + NewName);
    end;
    Result := NewName;

  end;
  Writeln('Available file name: ' + Result);
end;

function TRequestToFileSystemStorage<T>.Save(const Obj: TJsonObject): String;
var
  FullPath: String;
begin
  Result := GetAvailableName();
  FullPath := FWorkingFolder + Result + FFileExtension;
  if TFile.Exists(FullPath) then
  begin
    raise Exception.Create('File ' + Result + ' exists. Hence it is not available.');
  end
  else
    TFile.AppendAllText(FullPath, Obj.ToString);
end;

function TRequestToFileSystemStorage<T>.GetParams: TArray<TPair<String, String>>;
var
  Pair: TPair<String, String>;
begin
  Result := TArray < TPair < String, String >>.Create();
  SetLength(Result, 4);
  Result[0] := TPair<String, String>.Create('type', 'filesystem');
  Result[1] := TPair<String, String>.Create('working folder', FWorkingFolder);
  Result[2] := TPair<String, String>.Create('subfolder for incoming requests', INCOMING_FOLDER_NAME);
  Result[3] := TPair<String, String>.Create('subfolder for elaborated requests', ELABORATED_FOLDER_NAME);
end;

function TRequestToFileSystemStorage<T>.GetPendingRequests: Integer;
var
  FilePath: String;
  Items: TStringDynArray;
  JO: TJsonObject;
  Item: String;
  obj: T;
  ListOfT: TObjectList<T>;
begin
  Items := TDirectory.GetFiles(FIncomingFolder);
  ListOfT := TObjectList<T>.Create();
  for Item in Items do
  begin
    JO := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(TFile.ReadAllText(Item)), 0) as TJSONObject;
    obj := Mapper.JSONObjectToObject<T>(JO);
    ListOfT.Add(obj);
  end;
  Result := ListOfT.Count;
end;

end.
