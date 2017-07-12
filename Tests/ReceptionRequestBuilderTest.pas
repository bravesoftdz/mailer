unit ReceptionRequestBuilderTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TReceptionRequestBuilderTest = class(TObject)
  public
    [Test]
    procedure SetHtml;
    [Test]
    procedure SetText;
  end;

implementation

uses
  SendDataTemplate, System.JSON, ObjectsMappers;

procedure TReceptionRequestBuilderTest.SetText;
var
  request: TReceptionRequest;
  builder: TReceptionRequestBuilder;
begin
  builder := TReceptionRequestBuilder.Create;
  builder.SetText('a text');
  request := builder.Build;
  Assert.AreEqual(request.text, 'a text');
end;

procedure TReceptionRequestBuilderTest.SetHtml;
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

TDUnitX.RegisterTestFixture(TReceptionRequestBuilderTest);

end.
