unit DispatcherResponce;

interface

uses ObjectsMappers, AQResponce;

type
  TDispatcherResponceMessages = class abstract(TObject)
  const
    INVALID_BODY = 'Invalid request body.';
    MISSING_BODY = 'No request body found.';
    NOT_AUTHORISED = 'Not authorized';
    SUCCESS_REPORT = 'Dispatcher successefuly put %d items to the backend server queue.';
    FAILURE_REPORT = 'Dispatcher received a failure from the back end server. Reason: %s';
    EXCEPTION_REPORT = 'Dispacther encountered an error when sending items to the back end server: %s';
  end;

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
