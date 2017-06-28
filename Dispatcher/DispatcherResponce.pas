unit DispatcherResponce;

interface

type
  /// Dispatcher responce to some requests.
  TDispatcherResponce = class(TObject)
  strict private
  var
    FStatus: Boolean;
    FMessage: String;

  public
    property Status: Boolean read FStatus;
    property msg: String read FMessage;

    constructor Create(const Status: Boolean; const Msg: String);

  end;

implementation

{ TDispatcherResponce }

constructor TDispatcherResponce.Create(const Status: Boolean; const Msg: String);
begin
  FStatus := Status;
  FMessage := Msg;
end;

end.
