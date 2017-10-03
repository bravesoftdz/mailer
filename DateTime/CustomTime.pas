unit CustomTime;

interface

type
  TCustomTime = class(TObject)
  public
    function LastAccessTime(Path: String): String;

  end;

implementation

uses
  Winapi.Windows, System.SysUtils, System.DateUtils;

{ TCustomTime }

function TCustomTime.LastAccessTime(Path: String): String;
var
  FileSpecs: TGetFileExInfoLevels;
  FolderData: TWin32FileAttributeData;
  FileTime: TSystemTime;

  LocalSystemTime: TSystemTime;
  UTCSystemTime: TSystemTime;
  LocalFileTime: TFileTime;
  UTCFileTime: TFileTime;

  UTCDateTime: TDateTime;
begin
  fillchar(FileSpecs, sizeof(FileSpecs), 0);
  FileSpecs := GetFileExInfoStandard;
  fillchar(FolderData, sizeof(folderdata), 0);
  if GetFileAttributesEx(PChar(Path), FileSpecs, @FolderData) then
  begin
    FileTimeToSystemTime(folderdata.ftLastWriteTime, FileTime);
    Result := formatDateTime('dd mmm yyyy hh:nn:ss', IncHour(SystemTimeToDateTime(filetime), 2));
  end;
end;

end.
