unit RequestToFileSystemStorage;

interface

uses
  RequestStorageInterface, System.JSON;

type
  TRequestToFileSystemStorage = class(TInterfacedObject, IRequestStorage)
  strict private
  const
    FFileExtension = '.txt';
    FFileName = 'request';
    Suffix = '-YYYY-mm-dd-hh-nn-ss';

  var
    FTargetFolder: String;
    function GetAvailableName(): String;
  public
    constructor Create(const TargetFolder: String);
    function Save(const Obj: TJsonObject): String;
    function Delete(const Id: String): Boolean;

  end;

implementation

uses
  System.SysUtils, System.IOUtils;

{ TRequestToFileSystemStorage }

constructor TRequestToFileSystemStorage.Create(const TargetFolder: String);
begin
  FTargetFolder := TargetFolder;
  if not(TDirectory.Exists(FTargetFolder)) then
    TDirectory.CreateDirectory(FTargetFolder);

end;

function TRequestToFileSystemStorage.Delete(const Id: String): Boolean;
var
  FullPath: String;
begin
  FullPath := FTargetFolder + Id + FFileExtension;
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
  FullPath := FTargetFolder + FFileName + FFileExtension;
  if not(TFile.Exists(FullPath)) then
    Result := FFileName
  else
  begin
    BaseName := FFileName + formatdatetime(Suffix, Now());
    NewName := BaseName;
    FullPath := FTargetFolder + BaseName + FFileExtension;
    Counter := 1;
    while (TFile.Exists(FullPath)) do
    begin
      NewName := Format('%s-%d', [BaseName, Counter]);
      FullPath := FTargetFolder + NewName + FFileExtension;;
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
  FullPath := FTargetFolder + Result + FFileExtension;
  if TFile.Exists(FullPath) then
  begin
    raise Exception.Create('File ' + Result + ' exists. Hence it is not available.');
  end
  else
    TFile.AppendAllText(FullPath, Obj.ToString);
end;

end.
