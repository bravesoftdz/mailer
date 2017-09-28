unit RequestToFileSystemStorage;

interface

uses
  RequestStorageInterface, System.JSON, RepositoryConfig, MVCFramework.Logger,
  System.SysUtils, System.Generics.Collections;

type
  TRequestToFileSystemStorage<T: Class, constructor> = class(TInterfacedObject, IRequestStorage<T>)
  strict private
  const
    /// <summary>name of the folder inside the working one in which the requests should be saved</summary>
    STORAGE_FOLDER_NAME = 'incoming' + PathDelim;

    /// <summary>name of the folder inside the working one in which requests are placed when "deleting"</summary>
    RECYCLE_BIN_FOLDER_NAME = 'recycled' + PathDelim;

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
    FLockObj: TObject;

    /// <summary>Generate available name (i.e. a file that does not exist and hence can be created)
    /// for a file in the given folder using given name as a suggestion.
    /// It does not require any lock since it is a private method and it is called from
    /// public ones that might require a lock.
    /// </summary>
    /// <param name="Seed">a suggested name (without extension)</param>
    /// <param name="Folder">path to the folder in which a file might be created</param>
    /// <param name="Extension">extension for the available name</param>
    function GetAvailableName(const Seed, Folder, Extension: String): String;

    /// <summary>Try to create a folder with given path. If it exists, do nothing.</summary>
    procedure CreateFolderIfNotExist(const Path: String);

  public
    constructor Create(const WorkingFolder: String); overload;
    constructor Create(const Config: TRepositoryConfig); overload;

    destructor Destroy();

    /// <summary>save given object in the repository folder.
    /// Requires a lock.</sumamry>
    function Save(const Obj: T): String;

    /// <summary>delete a file with given id in the repository folder.
    /// Requires a lock.</sumamry>
    function Delete(const Id: String): Boolean;

    /// <summary>Get the repository properties.
    /// Does not require any lock since it needs just a read-only access.</sumamry>
    function GetParams(): TArray<TPair<String, String>>;

    /// <summary>Return a list of requests that have been saved but have never been deleted.
    /// The keys are file names without extensions that are located in the incoming folder.
    /// Requires a lock.</sumamry>
    function GetPendingRequests(): TDictionary<String, T>;

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
  FLockObj := TObject.Create;
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
      FIncomingFolder := FWorkingFolder + STORAGE_FOLDER_NAME;
      FElaboratedFolder := FWorkingFolder + RECYCLE_BIN_FOLDER_NAME;
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
        Log.Error('CreateFolderIfNotExist: error when creating a repository folder "' + Path + '"', TAG);
      end;
    end;
end;

function TRequestToFileSystemStorage<T>.Delete(const Id: String): Boolean;
var
  SourceFullPath, TargetFullPath: String;
begin
  TMonitor.Enter(FLockObj);
  SourceFullPath := FIncomingFolder + Id + FFileExtension;
  try
    if not(TFile.Exists(SourceFullPath)) then
      Result := False
    else
    begin
      try
        TargetFullPath := FElaboratedFolder + GetAvailableName(Id, FElaboratedFolder, FFileExtension) + FFileExtension;
        if not(TFile.Exists(TargetFullPath)) then
        begin
          TFile.Move(SourceFullPath, TargetFullPath);
          Result := True;
        end
        else
        begin
          Log.Warn('Delete: target file ' + TargetFullPath + ' already exists. Therefore, the source file ' + SourceFullPath + ' gets removed.', TAG);
          TFile.Delete(SourceFullPath);
          Result := True
        end;
      except
        on E: Exception do
        begin
          raise Exception.Create('The filesystem storage failed to remove file ' + id);
        end;
      end
    end;
  finally
    TMonitor.Exit(FLockObj);
  end;

end;

function TRequestToFileSystemStorage<T>.GetAvailableName(const Seed, Folder, Extension: String): String;
var
  FullPath: String;
  Counter: Integer;
  NewName, BaseName: String;
begin
  FullPath := Folder + Seed + Extension;
  if not(TFile.Exists(FullPath)) then
    Result := Seed
  else
  begin
    BaseName := Seed + formatdatetime(Suffix, Now());
    NewName := BaseName;
    FullPath := Folder + BaseName + Extension;
    Counter := 1;
    while (TFile.Exists(FullPath)) do
    begin
      NewName := Format('%s-%d', [BaseName, Counter]);
      FullPath := Folder + NewName + Extension;;
      Counter := Counter + 1;
    end;
    Result := NewName;
  end;
end;

function TRequestToFileSystemStorage<T>.Save(const Obj: T): String;
var
  FullPath: String;
  Jo: TJsonObject;
begin
  TMonitor.Enter(FLockObj);
  try

    Result := GetAvailableName(FFileName, FIncomingFolder, FFileExtension);
    FullPath := FIncomingFolder + Result + FFileExtension;
    if TFile.Exists(FullPath) then
    begin
      raise Exception.Create('File ' + Result + ' exists. Hence it is not available.');
    end
    else
    begin
      try
        JO := Mapper.ObjectToJSONObject(Obj);
        TFile.AppendAllText(FullPath, Jo.ToString);
        Writeln('File ' + FullPath + ' is saved.');
      finally
        JO.DisposeOf;
      end;
    end;
  finally
    TMonitor.Exit(FLockObj);
  end;
end;

function TRequestToFileSystemStorage<T>.GetParams: TArray<TPair<String, String>>;
var
  Pair: TPair<String, String>;
begin
  Result := TArray < TPair < String, String >>.Create();
  SetLength(Result, 4);
  Result[0] := TPair<String, String>.Create('type', 'filesystem');
  Result[1] := TPair<String, String>.Create('working folder', FWorkingFolder);
  Result[2] := TPair<String, String>.Create('subfolder for incoming requests', STORAGE_FOLDER_NAME);
  Result[3] := TPair<String, String>.Create('subfolder for elaborated requests', RECYCLE_BIN_FOLDER_NAME);
end;

function TRequestToFileSystemStorage<T>.GetPendingRequests: TDictionary<String, T>;
var
  FilePath: String;
  TheFiles: TStringDynArray;
  JO: TJsonObject;
  AFile: String;
  obj: T;
begin
  TMonitor.Enter(FLockObj);
  try
    TheFiles := TDirectory.GetFiles(FIncomingFolder);
    Result := TDictionary<String, T>.Create();

    for AFile in TheFiles do
    begin
      try
        try
          JO := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(TFile.ReadAllText(AFile)), 0) as TJSONObject;
          obj := Mapper.JSONObjectToObject<T>(JO);
          Result.Add(TPath.GetFileNameWithoutExtension(AFile), obj);
        except
          on E: Exception do
          begin
            Log.Error('GetPendingRequests: failed to reconstruct an object from the content of file "' + AFile + '". Reason: ' + E.Message, TAG);
          end;
        end;
      finally
        if JO <> nil then
          JO.DisposeOf;
      end;
    end;
  finally
    TMonitor.Exit(FLockObj);
  end;
end;

destructor TRequestToFileSystemStorage<T>.Destroy();
begin
  FLockObj.DisposeOf;
end;

end.
