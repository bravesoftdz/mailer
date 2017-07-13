unit KeyStroke;

interface

uses
  ConsumerController;

type
  TConsumerKeyStroke = class(TObject)
  const
    KEYSTROKE_SUBSCRIBE = 48;
    KEYSTROKE_UNSUBSCRIBE = 49;

  strict private
    FController: TClass;
  public
    constructor Create(const Controller: TClass);
    function Elaborate(const KeyCode: Integer): Integer;
  end;

implementation

uses
  Winapi.Windows;

{ TConsumerKeyStroke }

constructor TConsumerKeyStroke.Create(const Controller: TClass);
begin
  FController := Controller;
end;

function TConsumerKeyStroke.Elaborate(const KeyCode: Integer): Integer;
begin
  case KeyCode of
    VK_ESCAPE:
      Result := 0;
    KEYSTROKE_SUBSCRIBE:
      begin
        result := 1;
        Writeln(KEYSTROKE_SUBSCRIBE);
      end;
    KEYSTROKE_UNSUBSCRIBE:
      begin
        result := 1;
        Writeln(KEYSTROKE_UNSUBSCRIBE);
      end;

  end;
end;

end.
