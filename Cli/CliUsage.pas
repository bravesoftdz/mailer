unit CliUsage;

interface

uses CliParam, System.Generics.Collections;

type
  /// A class that generates a text describing how to use command line arguments.
  TCliUsage = class(TObject)
  strict private
    FFileName: String;
    FCliParams: Tarray<TCliParam>;
    function GenerateText(): String;

  const
    HORIZONTAL_SPACE = ' ';
    VERTICAL_SPACE = sLineBreak;
  public
    /// <summary>Create a text describing the usage of the command line arguments.</sumamry>
    /// <param name="FileName">the name of the program to which the command line arguments refer to</param>
    /// <param name="CliParams">array of command line arguments</param>
    class function CreateText(const FileName: String; const CliParams: TArray<TCliParam>): String;
    constructor Create(const FileName: String; const CliParams: TArray<TCliParam>);
    destructor Destroy(); override;
    function Parse(): TDictionary<String, String>;
    property Text: String read GenerateText;
  end;

implementation

uses
  System.SysUtils;

{ TCliUsage }

constructor TCliUsage.Create(const FileName: String; const CliParams: TArray<TCliParam>);
var
  I, S: Integer;
begin
  FFileName := FileName;
  FCliParams := Tarray<TCliParam>.Create();
  S := Length(CliParams);
  SetLength(FCliParams, S);
  for I := 0 to S - 1 do
  begin
    FCliParams[I] := CliParams[I].Copy;
  end;

end;

class function TCliUsage.CreateText(const FileName: String;
  const CliParams: TArray<TCliParam>): String;
var
  L, I: Integer;
  Short, Long: String;
begin
  L := Length(CliParams);
  Short := '';
  Long := '';
  for I := 0 to L - 1 do
  begin
    Short := Short + CliParams[I].CliUsage + HORIZONTAL_SPACE;
    Long := Long + CliParams[I].Explanation + VERTICAL_SPACE;
  end;
  Result := 'Usage:' + VERTICAL_SPACE + FileName + HORIZONTAL_SPACE + Short + VERTICAL_SPACE + 'where' + VERTICAL_SPACE + Long;

end;

destructor TCliUsage.Destroy;
var
  I, S: Integer;
begin
  S := Length(FCliParams);
  for I := 0 to S - 1 do
  begin
    FCliParams[I].DisposeOf;
  end;
  SetLength(FCliParams, 0);
  inherited;
end;

function TCliUsage.GenerateText: String;
var
  L, I: Integer;
  Short, Long: String;
begin
  L := Length(FCliParams);
  Short := '';
  Long := '';
  for I := 0 to L - 1 do
  begin
    Short := Short + FCliParams[I].CliUsage + HORIZONTAL_SPACE;
    Long := Long + FCliParams[I].Explanation + VERTICAL_SPACE;
  end;
  Result := 'Usage:' + VERTICAL_SPACE + FFileName + HORIZONTAL_SPACE + Short + VERTICAL_SPACE + 'where' + VERTICAL_SPACE + Long;

end;

function TCliUsage.Parse: TDictionary<String, String>;
var
  Param: TCliParam;
  value: String;
  isPresent: Boolean;
begin
  Result := TDictionary<String, String>.Create();
  for Param in FCliParams do
  begin
    Value := '';
    isPresent := FindCmdLineSwitch(Param.SwitchString, Value, False);
    if Param.IsRequired AND not(isPresent) then
    begin
      Result.Clear();
      raise Exception.Create('Required parameter ' + Param.SwitchString + ' is missing.');
    end;
    if isPresent then
      Result.Add(Param.SwitchString, Value);
  end;

end;

end.
