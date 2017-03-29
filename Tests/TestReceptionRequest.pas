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
    /// Partition the input as follows:
    /// 1. key "from": absent, empty, non-empty
    /// 2. key "sender": absent, empty, non-empty
    /// 3. key "server": absent, empty, non-empty
    /// 4. key "port": absent, empty, non-empty
    /// 5. key "useauth": absent, empty, non-empty
    /// 6. key "user": absent, empty, non-empty
    /// 7. key "password": absent, empty, non-empty
    /// 8. key "usessl": absent, empty, non-empty
    /// 9. key "html": absent, empty, non-empty
    /// 10. key "text": absent, empty, non-empty
    /// 11. key "subject": absent, empty, non-empty
    /// 12. key "recipto": absent, empty, non-empty
    /// 13. key "recipcc": absent, empty, non-empty
    /// 14. key "recipbcc": absent, empty, non-empty
    /// 15. key "attachment": absent, empty, non-empty
    /// 16. key "token": absent, empty, non-empty

    [Test]
    /// Cover: all keys are absent
    procedure JsonToObjEmpty;

    [Test]
    /// Cover: all keys are absent
    procedure JsonToObjPrimitiveNonEmpty;

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

procedure TTestReceptionRequest.JsonToObjPrimitiveNonEmpty;
var
  jo: TJsonObject;
  obj: TReceptionRequest;
begin
  jo := TJsonObject.Create;
  jo.AddPair(TJsonPair.Create('from', '@e.mail.c.m'));
  jo.AddPair(TJsonPair.Create('server', 'server ip'));
  jo.AddPair(TJsonPair.Create('sender', 'Somebody'));
  jo.AddPair(TJsonPair.Create('port', '63'));
  obj := Mapper.JSONObjectToObject<TReceptionRequest>(jo);
  Assert.AreEqual('@e.mail.c.m', obj.from);
  Assert.AreEqual('server ip', obj.server);
  Assert.AreEqual('Somebody', obj.sender);
  Assert.AreEqual(63, obj.port);
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
