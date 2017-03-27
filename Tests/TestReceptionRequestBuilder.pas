unit TestReceptionRequestBuilder;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TTestReceptionRequestBuilder = class(TObject)
  public
    [Test]
    procedure SetHtml;
    [Test]
    procedure SetText;
  end;

implementation

uses
  ReceptionRequest, System.JSON, ObjectsMappers;

procedure TTestReceptionRequestBuilder.SetText;
var
  request: TReceptionRequest;
  builder: TReceptionRequestBuilder;
begin
  builder := TReceptionRequestBuilder.Create;
  builder.SetText('a text');
  request := builder.Build;
  Assert.AreEqual(request.text, 'a text');
end;


procedure TTestReceptionRequestBuilder.SetHtml;
var
  request: TReceptionRequest;
  builder: TReceptionRequestBuilder;
begin
  builder := TReceptionRequestBuilder.Create;
  builder.SetHtml('some string');
  request := builder.Build;
  Assert.AreEqual(request.html, 'some string');

end;

initialization

TDUnitX.RegisterTestFixture(TTestReceptionRequestBuilder);

end.
