unit BackEndSettings;

interface

type
  /// <summary>Immutable class for storing the back end server url and port.</summary>
  TBackEndSettings = class
  strict private
    FUrl: String;
    FPort: Integer;
    /// <summary> String version of this instance. Since this class is
    /// immutable, let's instantiate this field in the constructor
    /// </summary>
    FSummary: String;
  public
    property Url: String read FUrl;
    property Port: Integer read FPort;
    property Summary: String read FSummary;
    constructor Create(const Url: String; const Port: Integer);

  end;

implementation

uses
  System.SysUtils;

{ TBackEndSettings }

constructor TBackEndSettings.Create(const Url: String; const Port: Integer);
begin
  FUrl := Url;
  FPort := Port;
  FSummary := Url + ':' + IntToStr(Port);

end;

end.
