unit TestReceptionRequest;

interface

uses
  DUnitX.TestFramework, ReceptionRequest, System.JSON;

type

  [TestFixture]
  TTestReceptionRequest = class(TObject)
  private
    request: TReceptionRequest;
    json: TJsonObject;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Test suit for converting the instance into a json
    [Test]
    procedure ObjToJsonKeyFromIsPresent;
    [Test]
    procedure ObjToJsonKeyHtmlIsPresent;
    [Test]
    procedure ObjToJsonKeyBodytextIsPresent;
    [Test]
    procedure ObjToJsonKeyAttachIsPresent;
    [Test]
    procedure ObjToJsonKeyTokenIsPresent;

    /// Test suit for constructing an instance from a json
    /// partition the input as follows:
    [Test]
    procedure JsonToObjEmpty;

  end;

implementation

uses
  ObjectsMappers;

procedure TTestReceptionRequest.ObjToJsonKeyHtmlIsPresent;
begin
  Assert.AreEqual(json.GetValue('bodyhtml').Value, 'html content');
end;

procedure TTestReceptionRequest.ObjToJsonKeyTokenIsPresent;
begin
  Assert.IsNotNull(json.GetValue('token'));
end;

procedure TTestReceptionRequest.ObjToJsonKeyBodytextIsPresent;
begin
  Assert.AreEqual(json.GetValue('bodytext').Value, 'text content');
end;

procedure TTestReceptionRequest.Setup;
begin
  request := TReceptionRequestBuilder.Create()
    .SetFrom('admin@google.com')
    .SetText('text content')
    .setHtml('html content')
    .setToken('token')
    .Build;
  json := Mapper.ObjectToJSonObject(request);
end;

procedure TTestReceptionRequest.TearDown;
begin
end;

procedure TTestReceptionRequest.JsonToObjEmpty;
var
  obj: TReceptionRequest;
begin
  obj := Mapper.JSONObjectToObject<TReceptionRequest>(TJsonObject.Create);
  Assert.IsNotNull(obj);

end;

procedure TTestReceptionRequest.ObjToJsonKeyAttachIsPresent;
begin
  Assert.IsNotNull(json.GetValue('attach'));
end;

procedure TTestReceptionRequest.ObjToJsonKeyFromIsPresent;
begin
  Assert.AreEqual(json.GetValue('from').Value, 'admin@google.com');
end;

initialization

TDUnitX.RegisterTestFixture(TTestReceptionRequest);

end.
