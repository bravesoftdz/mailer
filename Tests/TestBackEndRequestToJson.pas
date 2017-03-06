unit TestBackEndRequestToJson;

interface

uses
  DUnitX.TestFramework, BackEndRequest, System.JSON;

type

  [TestFixture]
  TTestBackEndRequestToJson = class(TObject)
  private
    request: TBackEndRequest;
    json: TJsonObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure KeyFromIsPresent;
    [Test]
    procedure KeyHtmlIsPresent;
    [Test]
    procedure KeyBodytextIsPresent;
    [Test]
    procedure KeyAttachIsPresent;

  end;

implementation

uses
  ObjectsMappers;

procedure TTestBackEndRequestToJson.KeyHtmlIsPresent;
begin
  Assert.AreEqual(json.GetValue('bodyhtml').Value, 'html content');
end;

procedure TTestBackEndRequestToJson.KeyBodytextIsPresent;
begin
  Assert.AreEqual(json.GetValue('bodytext').Value, 'text content');
end;

procedure TTestBackEndRequestToJson.Setup;
begin
  request := TBackEndRequestBuilder.Create()
    .SetFrom('admin@google.com')
    .SetText('text content')
    .setHtml('html content')
    .Build;
  json := Mapper.ObjectToJSonObject(request);
end;

procedure TTestBackEndRequestToJson.TearDown;
begin
end;

procedure TTestBackEndRequestToJson.KeyAttachIsPresent;
begin
  Assert.IsNotNull(json.GetValue('attach'));
end;

procedure TTestBackEndRequestToJson.KeyFromIsPresent;
begin
  Assert.AreEqual(json.GetValue('from').Value, 'admin@google.com');
end;

initialization

TDUnitX.RegisterTestFixture(TTestBackEndRequestToJson);

end.
