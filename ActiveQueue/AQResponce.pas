unit AQResponce;

interface

uses
  ObjectsMappers;

type
  TAQResponceMessages = class abstract(TObject)
  const
    BODY_MISSING = 'AQ: no request body is present';
    ERROR_CAST_REPORT = 'AQ: failed to cast the request body into TActiveQueueEntries. Reason: %s';
    ERROR_PERSIST_REPORT = 'AQ: failed to save the requests. Reason: %s';
    ERROR_ENQUEUE_REPORT = 'AQ: failed to enqueue the requests. Reason: %s';
    SUCCESS = 'AQ has successfully enqueued the items.';
    FAILURE = 'AQ has failed to enqueu the items.';
  end;

type

  /// <summary>Abstract data type to represent the responces from the
  /// back end server corresponding to previously made requests.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAQResponce = class(TObject)
  strict private
    FStatus: Boolean;
    FMessage: String;
    FToken: String;
  public
    /// <param name="status">A status of the previously made request.</param>
    [MapperJSONSer('status')]
    property status: Boolean read FStatus write FStatus;
    /// <param name="Msg">Additional info concerning the outcome of the
    /// previously made request</param>
    [MapperJSONSer('msgstat')]
    property Msg: String read FMessage write FMessage;
    [MapperJSONSer('token')]
    property Token: String read FToken write FToken;
    constructor Create(const Status: Boolean; const Msg: String); overload;
    constructor Create(); overload;

  end;

implementation

{ TBackEndResponce }

constructor TAQResponce.Create;
begin
  FStatus := False;
  FMessage := '';
  FToken := '';
end;

constructor TAQResponce.Create(const Status: Boolean; const Msg: String);
begin
  FStatus := Status;
  FMessage := Msg;
end;

end.
