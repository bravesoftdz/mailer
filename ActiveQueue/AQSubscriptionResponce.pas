unit AQSubscriptionResponce;

interface

uses
  ObjectsMappers;

type

  /// <summary>Abstract data type to represent a responce to a previously made
  /// subscribe/unsubscribe request.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TAQSubscriptionResponce = class(TObject)
  strict private
  const
    STATUS_KEY = 'status';
    TOKEN_KEY = 'token';
    MESSAGE_KEY = 'message';

  var
    FStatus: Boolean;
    FMessage: String;
    FToken: String;
  public
    /// <param name="status">Outcome of the request: true for success, false for failure</param>
    [MapperJSONSer(STATUS_KEY)]
    property status: Boolean read FStatus write FStatus;

    /// <param name="Msg">Additional info concerning the outcome of the request</param>
    [MapperJSONSer(MESSAGE_KEY)]
    property Msg: String read FMessage write FMessage;

    /// <param name="Token">Token assigned to the consumer</param>
    [MapperJSONSer(TOKEN_KEY)]
    property Token: String read FToken write FToken;

    constructor Create(const Status: Boolean; const Msg, Token: String); overload;
    constructor Create(); overload;

  end;

implementation

{ TBackEndResponce }

constructor TAQSubscriptionResponce.Create;
begin
  Create(False, '', '');
end;

constructor TAQSubscriptionResponce.Create(const Status: Boolean; const Msg, Token: String);
begin
  FStatus := Status;
  FMessage := Msg;
  FToken := Token;
end;

end.
