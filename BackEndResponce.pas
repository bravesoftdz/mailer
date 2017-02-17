unit BackEndResponce;

interface

type

  [MapperJSONNaming(JSONNameLowerCase)]
  TBackEndResponce = class
  private
    FStatus: Boolean;
    FMessage: String;
  public
    property status: Boolean read FStatus write FStatus;
    property msgstat: String read FMessage write FMessage;

  end;

implementation

end.
