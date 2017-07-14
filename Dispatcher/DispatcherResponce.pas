unit DispatcherResponce;

interface

uses ObjectsMappers, AQResponce;

type

  /// Dispatcher responce to some requests.
  [MapperJSONNaming(JSONNameLowerCase)]
  TDispatcherResponce = class(TObject)
  strict private
  var
    FStatus: Boolean;
    FMessage: String;

  public
    property Status: Boolean read FStatus write FStatus;
    property msg: String read FMessage write FMessage;
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
