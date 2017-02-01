unit SimpleInputData;

interface

uses
  System.JSON;

type
  TSimpleInputData = class
  private
    FDestination: String;
    FData: TJsonObject;
  public
    constructor Create(const Destination: String; const Data: TJsonObject);
  end;

implementation

{ TSimpleInputData }

constructor TSimpleInputData.Create(const Destination: String;
  const Data: TJsonObject);
begin
  FDestination := Destination;
  FData := Data;
end;

end.
