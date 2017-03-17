unit BackEndResponce;

interface

uses
  ObjectsMappers;

type

  /// <summary>Abstract data type to represent the responces from the
  /// back end server corresponding to previously made requests.</summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TBackEndResponce = class
  private
    FStatus: Boolean;
    FMessage: String;
  public
    /// <param name="status">A status of the previously made request.</param>
    [MapperJSONSer('status')]
    property status: Boolean read FStatus write FStatus;
    /// <param name="Msg">Additional info concerning the outcome of the
    /// previously made request</param>
    [MapperJSONSer('msgstat')]
    property Msg: String read FMessage write FMessage;
    constructor Create(const Status: Boolean; const Msg: String); overload;
    constructor Create(); overload;

  end;

implementation

{ TBackEndResponce }

constructor TBackEndResponce.Create;
begin
  FStatus := False;
  FMessage := '';
end;

constructor TBackEndResponce.Create(const Status: Boolean; const Msg: String);
begin
  FStatus := Status;
  FMessage := Msg;
end;

end.
