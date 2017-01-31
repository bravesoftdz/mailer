unit SimpleInputData;

interface

uses
  System.JSON;

type
  TSimpleInputData = class
  private
    FToken: String;
    FOrigin: String;
    FData: TJsonObject;
  public
    constructor Create(const Token, Origin: String; const Data: TJsonObject);
  end;

implementation

{ TSimpleInputData }

constructor TSimpleInputData.Create(const Token, Origin: String;
  const Data: TJsonObject);
begin
  FToken := Token;
  FOrigin := Origin;
  FData := Data;
end;

end.
