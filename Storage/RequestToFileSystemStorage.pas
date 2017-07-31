unit RequestToFileSystemStorage;

interface

uses
  RequestStorageInterface, System.JSON, RepositoryConfig, MVCFramework.Logger,
  System.SysUtils, System.Generics.Collections;

type
  TRequestToFileSystemStorage = class(TInterfacedObject, IRequestStorage)
  strict private
  const
    /// <summary>name of the folder inside the working one in which incoming requests should be stored</summary>
    INCOMING_FOLDER = 'incoming' + PathDelim;

    /// <summary>name of the folder inside the working one in which requests that have been already elaborated should be stored</summary>
    ELABORATED_FOLDER = 'elaborated' + PathDelim;

    /// <summary>pattern to extract a name of the working folder from the config instance</summary>
    WORKING_DIR_PATTERN = '^file:\/\/(.*)$';

    FFileExtension = '.txt';
    FFileName = 'request';
    Suffix = '-YYYY-mm-dd-hh-nn-ss';

  var
    FWorkingFolder: String;
    function GetAvailableName(): String;
  public
    constructor Create(const WorkingFolder: String); overload;
    constructor Create(const Config: TRepositoryConfig); overload;
    function Save(const Obj: TJsonObject): String;
    function Delete(const Id: String): Boolean;

    function Summary(): TArray<TPair<String, String>>;

  end;

implementation

uses
  System.IOUtils, System.RegularExpressions;

{ TRequestToFileSystemStorage }

constructor TRequestToFileSystemStorage.Create(const WorkingFolder: String);
const
  TAG = 'TRequestToFileSystemStorage.Create';
begin
  Log.Warn('This constructor is deprecated. Use TRequestToFileSystemStorage.Create(const Config: TRepositoryConfig) instead', TAG);
  FWorkingFolder := WorkingFolder;
  if not(TDirectory.Exists(FWorkingFolder)) then
    TDirectory.CreateDirectory(FWorkingFolder);

end;

constructor TRequestToFileSystemStorage.Create(const Config: TRepositoryConfig);
const
  TAG = 'TRequestToFileSystemStorage.Create';
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
      if not(TDirectory.Exists(FWorkingFolder)) then
        try
          TDirectory.CreateDirectory(FWorkingFolder);
        except
          on E: Exception do
          begin
            Log.Error('Error when creating a repository folder "' + FWorkingFolder + '"', TAG);
          end;
        end;
    end
    else
    begin
      Log.warn('Problem with matching pattern ''' + WORKING_DIR_PATTERN + ''' against string ''' + Config.Dsn + '''.', TAG);
    end;
  end;
end;

function TRequestToFileSystemStorage.Delete(const Id: String): Boolean;
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

function TRequestToFileSystemStorage.GetAvailableName: String;
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

function TRequestToFileSystemStorage.Save(const Obj: TJsonObject): String;
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

function TRequestToFileSystemStorage.Summary: TArray<TPair<String, String>>;
var
  Pair: TPair<String, String>;
begin
  Result := TArray < TPair < String, String >>.Create();
  SetLength(Result, 4);
  Result[0] := TPair<String, String>.Create('type', 'filesystem');
  Result[1] := TPair<String, String>.Create('working folder', FWorkingFolder);
  Result[2] := TPair<String, String>.Create('subfolder for incoming requests', INCOMING_FOLDER);
  Result[3] := TPair<String, String>.Create('subfolder for elaborated requests', ELABORATED_FOLDER);
end;

end.
