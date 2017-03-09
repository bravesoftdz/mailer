unit BackEndSettings;

interface

type
  TBackEndSettings = class
  strict private
    FUrl: String;
    FPort: Integer;
  public
    property Url: String read FUrl;
    property Port: Integer read FPort;
    constructor Create(const Url: String; const Port: Integer);
  end;

implementation

{ TBackEndSettings }

constructor TBackEndSettings.Create(const Url: String; const Port: Integer);
begin
  FUrl := Url;
  FPort := Port;
end;

end.
