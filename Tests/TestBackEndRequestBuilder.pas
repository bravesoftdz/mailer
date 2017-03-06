unit TestBackEndRequestBuilder;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TTestBackEndRequestBuilder = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure SetHtml;
    [Test]
    procedure SetText;
  end;

implementation

uses
  BackEndRequest, System.JSON, ObjectsMappers;

procedure TTestBackEndRequestBuilder.SetText;
var
  request: TBackEndRequest;
  builder: TBackEndRequestBuilder;
begin
  builder := TBackEndRequestBuilder.Create;
  builder.SetText('a text');
  request := builder.Build;
  Assert.AreEqual(request.text, 'a text');
end;

procedure TTestBackEndRequestBuilder.Setup;
begin
end;

procedure TTestBackEndRequestBuilder.TearDown;
begin
end;

procedure TTestBackEndRequestBuilder.SetHtml;
var
  request: TBackEndRequest;
  builder: TBackEndRequestBuilder;
begin
  builder := TBackEndRequestBuilder.Create;
  builder.SetHtml('some string');
  request := builder.Build;
  Assert.AreEqual(request.html, 'some string');

end;

initialization

TDUnitX.RegisterTestFixture(TTestBackEndRequestBuilder);

end.
