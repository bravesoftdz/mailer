unit CliParam;

interface

type
  /// <summary>Immutable ADT that represents a command line argument.</summary>
  ///  Immutablity is achieved by the fact that all properties are of primitive
  ///  types (string and boolean) and are read-only.
  TCliParam = class
  strict private
    FSwitchString: String;
    FTag: String;
    FDescr: String;
    FIsRequired: Boolean;
    FCliUsage: String;
    FExplanation: String;
  public
    constructor Create(const SwitchString, Tag, Descr: String; const IsRequired: Boolean);
    /// a switch corresponding to the parameter
    property SwitchString: String read FSwitchString;
    /// a tag corresponding to the parameter
    property Tag: String read FTag;
    /// usage  description
    property Description: String read FDescr;
    /// whether the parameter is required or optional
    property IsRequired: Boolean read FIsRequired;
    /// string describing the usage of the parameter in the command line
    property CliUsage: String read FCliUsage;
    /// explanation of what the parameter means
    property Explanation: String read FExplanation;

  end;

implementation

{ TCliParam }

constructor TCliParam.Create(const SwitchString, Tag, Descr: String;
  const IsRequired: Boolean);
const
  OPEN_TAG = '<';
  CLOSE_TAG = '>';
  SWITCH_CHAR = '-';
begin
  FSwitchString := SwitchString;
  FDescr := Descr;
  FTag := Tag;
  FIsRequired := IsRequired;
  FCliUsage := SWITCH_CHAR + FSwitchString + ' ' + OPEN_TAG + FTag + CLOSE_TAG;
  if Not(FIsRequired) then
    FCliUsage := '[' + FCliUsage + ']';
  FExplanation := OPEN_TAG + FTag + CLOSE_TAG + ' - ' + FDescr;
end;

end.
