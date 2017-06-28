unit Responce;

interface

type

  /// <summary>
  /// A reception responce.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TResponce = class(TObject)
  private
    FMessage: String;
    FStatus: Boolean;
  public
    property msg: String read FMessage write FMessage;
    property Status: Boolean read FStatus write FStatus;
    constructor Create(const Status: Boolean; const Msg: String);
  end;

implementation


{ TResponce }

constructor TResponce.Create(const Status: Boolean; const Msg: String);
begin
  FMessage := Msg;
  FStatus := Status;
end;

end.
