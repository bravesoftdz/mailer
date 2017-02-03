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
    property Data: TJsonObject read FData;
    function ToString(): String;
  end;

implementation

uses
  System.SysUtils;

{ TSimpleInputData }

constructor TSimpleInputData.Create(const Destination: String;
  const Data: TJsonObject);
begin
  FDestination := Destination;
  FData := Data;
end;

function TSimpleInputData.ToString: String;
var
  Builder: TStringBuilder;
  item: TJsonPair;
begin
  Builder := TStringBuilder.Create;
  Builder.Append('destination: ');
  Builder.Append(Fdestination);
  Builder.Append(', data: [');
  for item in FData do
  begin
    Builder.Append(item.JsonString.Value);
    Builder.Append(': ');
    Builder.Append(item.JsonValue.Value);
    Builder.Append(', ');
  end;
  Builder.Append(']');
  Result := Builder.ToString;
  Builder.DisposeOf;
end;

end.
