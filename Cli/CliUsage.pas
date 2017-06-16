unit CliUsage;

interface

uses CliParam;

type
  /// A class that generates a text describing how to use command line arguments.
  TCliUsage = class
  strict private
  const
    HORIZONTAL_SPACE = ' ';
    VERTICAL_SPACE = sLineBreak;
  public
    /// <summary>Create a text describing the usage of the command line arguments.</sumamry>
    /// <param name="FileName">the name of the program to which the command line arguments refer to</param>
    /// <param name="CliParams">array of command line arguments</param>
    class function CreateText(const FileName: String; const CliParams: TArray<TCliParam>): String;

  end;

implementation

uses
  System.Generics.Collections;

{ TCliUsage }

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

end.
