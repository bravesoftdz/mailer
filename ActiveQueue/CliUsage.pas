unit CliUsage;

interface

uses CliParam;

type
  /// A class that generates a text describing how to use command line arguments.
  TCliUsage = class
  strict private
  var
    FCliParams: TArray<TCliParam>;
    FFileName: String;
    function CreateUsageText: String;
  public
    /// <summary>Constructor</sumamry>
    /// <param name="FileName">the name of the program to which the command line arguments refer to</param>
    /// <param name="CliParams">array of command line arguments</param>
    constructor Create(const FileName: String; const CliParams: TArray<TCliParam>);
    destructor Destroy();
    property Text: String read CreateUsageText;

  end;

implementation

uses
  System.Generics.Collections;

{ TCliUsage }

constructor TCliUsage.Create(const FileName: String; const CliParams: TArray<TCliParam>);
begin
  FCliParams := CliParams;
  FFileName := FileName;
end;

function TCliUsage.CreateUsageText: String;
var
  L, I: Integer;
  Short, Long: String;
begin
  L := Length(FCliParams);
  Short := '';
  Long := '';
  for I := 0 to L - 1 do
  begin
    Short := Short + FCliParams[I].CliUsage + sLineBreak;
    Long := Long + FCliParams[I].Explanation + sLineBreak;
  end;
  Result := 'Usage:' + sLineBreak + FFileName + ' ' + Short + 'where' + sLineBreak + Long;

end;

destructor TCliUsage.Destroy;
begin
  SetLength(FCliParams, 0);

end;

end.
