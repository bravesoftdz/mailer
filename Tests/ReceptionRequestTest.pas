unit ReceptionRequestTest;

interface

uses
  DUnitX.TestFramework, ReceptionRequest, System.JSON;

type

  [TestFixture]
  TReceptionRequestTest = class(TObject)
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

procedure TReceptionRequestTest.ObjToJsonKeyHtmlIsPresent;
begin
  Assert.AreEqual(json.GetValue('bodyhtml').Value, 'html content');
end;

procedure TReceptionRequestTest.ObjToJsonKeyTokenIsPresent;
begin
  Assert.IsNotNull(json.GetValue('token'));
end;

procedure TReceptionRequestTest.ObjToJsonKeyBodytextIsPresent;
begin
  Assert.AreEqual(json.GetValue('bodytext').Value, 'text content');
end;

procedure TReceptionRequestTest.Setup;
begin
  request := TReceptionRequestBuilder.Create()
    .SetFrom('admin@google.com')
    .SetText('text content')
    .setHtml('html content')
    .setToken('token')
    .Build;
  json := Mapper.ObjectToJSonObject(request);
end;

procedure TReceptionRequestTest.TearDown;
begin
end;

procedure TReceptionRequestTest.JsonToObjEmpty;
var
  obj: TReceptionRequest;
begin
  obj := Mapper.JSONObjectToObject<TReceptionRequest>(TJsonObject.Create);
  Assert.IsNotNull(obj);
end;

procedure TReceptionRequestTest.JsonToObjPrimitiveNonEmpty;
var
  jo: TJsonObject;
  obj: TReceptionRequest;
begin
  jo := TJsonObject.Create;
  jo.AddPair(TJsonPair.Create('from', '@e.mail.c.m'));
  jo.AddPair(TJsonPair.Create('server', 'server ip'));
  jo.AddPair(TJsonPair.Create('sender', 'Somebody'));
  jo.AddPair(TJsonPair.Create('port', TJSONNumber.Create(63)));
  jo.AddPair(TJsonPair.Create('useauth', TJSONTrue.Create));
  jo.AddPair(TJsonPair.Create('user', 'login user name'));
  jo.AddPair(TJsonPair.Create('password', 'my secure pswd'));
  jo.AddPair(TJsonPair.Create('usessl', TJsonFalse.Create));
  jo.AddPair(TJsonPair.Create('bodyhtml', 'html<br>part'));
  jo.AddPair(TJsonPair.Create('bodytext', 'text version'));
  jo.AddPair(TJsonPair.Create('subject', 'a subject'));
  jo.AddPair(TJsonPair.Create('recipto', 'email1@a.com, email2@bbb.com'));
  jo.AddPair(TJsonPair.Create('recipcc', 'aaa@bbb.ccc, vvv@rrr.eee'));
  jo.AddPair(TJsonPair.Create('recipbcc', '1@, a@b.c'));
  jo.AddPair(TJsonPair.Create('attachment', TJsonArray.Create));
  jo.AddPair(TJsonPair.Create('token', 'a token'));

  obj := Mapper.JSONObjectToObject<TReceptionRequest>(jo);
  Assert.AreEqual('@e.mail.c.m', obj.from);
  Assert.AreEqual('server ip', obj.server);
  Assert.AreEqual('Somebody', obj.sender);
  Assert.AreEqual(63, obj.port);
  Assert.IsTrue(obj.useauth);
  Assert.AreEqual('my secure pswd', obj.password);
  Assert.IsFalse(obj.usessl);
  Assert.AreEqual('html<br>part', obj.html);
  Assert.AreEqual('text version', obj.text);
  Assert.AreEqual('a subject', obj.subject);
  Assert.AreEqual('email1@a.com, email2@bbb.com', obj.recipto);
  Assert.AreEqual('aaa@bbb.ccc, vvv@rrr.eee', obj.recipcc);
  Assert.AreEqual('1@, a@b.c', obj.recipbcc);
  Assert.AreEqual(0, obj.attachment.Count);
  Assert.AreEqual('a token', obj.token);
end;

procedure TReceptionRequestTest.ObjToJsonKeyAttachIsPresent;
begin
  Assert.IsNotNull(json.GetValue('attach'));
end;

procedure TReceptionRequestTest.ObjToJsonKeyFromIsPresent;
begin
  Assert.AreEqual(json.GetValue('from').Value, 'admin@google.com');
end;

initialization

TDUnitX.RegisterTestFixture(TReceptionRequestTest);

end.
