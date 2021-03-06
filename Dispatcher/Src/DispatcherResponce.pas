unit DispatcherResponce;

interface

uses ObjectsMappers, AQResponce;

type
  TDispatcherResponceMessages = class abstract(TObject)
  const
    INVALID_BODY_REPORT = 'Dispatcher failed to cast the request: %s';
    MISSING_BODY = 'No request body found.';
    EMPTY_BODY = 'Null request body found.';
    NOT_AUTHORISED = 'Not authorized';
    SUCCESS = 'Dispatcher successfully passed data to the backend server.';
    EXCEPTION_REPORT = 'Dispatcher has saved the request %s, but failed to connect to the back end server: %s';
    FAILURE_REPORT = 'Dispatcher has saved the request %s, but the back end server failed: %s';
    FAILED_TO_DELETE = 'Dispather failed to delete the previously saved request %s due to %s. When possible it will be sent to the back end server again.';
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
