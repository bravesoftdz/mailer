unit ReceptionResponce;

interface

type

  /// <summary>
  /// A reception responce. It is a mutable object, everybody can change its fields.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TReceptionResponce = class(TObject)
  strict private
  const
    MESSAGE_KEY = 'message';
    STATUS_KEY = 'status';

  var
    FMessage: String;
    FStatus: Boolean;
  public
    [MapperJSONSer(MESSAGE_KEY)]
    property msg: String read FMessage write FMessage;
    [MapperJSONSer(STATUS_KEY)]
    property status: Boolean read FStatus write FStatus;

    constructor Create(const Status: Boolean; const Msg: String);
  end;

implementation


{ TResponce }

constructor TReceptionResponce.Create(const Status: Boolean; const Msg: String);
begin
  FMessage := Msg;
  FStatus := Status;
end;

end.
