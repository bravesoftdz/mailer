unit FrontEndRequest;

interface

uses
  System.JSON;

type
  TFrontEndRequest = class
  private
    FDestination: String;
    FData: String;
  public
    constructor Create(const Destination: String; const Data: TFrontEndRequest);
    property Data: String read FData;
    function ToString(): String;
  end;

implementation

uses
  System.SysUtils;

{ TSimpleInputData }

constructor TFrontEndRequest.Create(const Destination: String;
  const Data: TFrontEndRequest);
begin
  FDestination := Destination;
  FData := Data.ToString;
end;

function TFrontEndRequest.ToString: String;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  Builder.Append('destination: ');
  Builder.Append(Fdestination);
  Builder.Append(', data: ');
  Builder.Append(Data);
  Result := Builder.ToString;
  Builder.DisposeOf;
end;

end.
