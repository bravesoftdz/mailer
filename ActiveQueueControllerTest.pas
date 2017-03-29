unit ActiveQueueControllerTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TActiveQueueControllerTest = class(TObject)
  public
    // Test suit for the constructing a collection of objects from a json array
    // Partition the input as follows
    // Size of items: 0, 1, > 1

    // Cover:
    // Size of items: 0
    [Test]
    [Ignore]
    procedure ListFromEmptyJsonArray;
    // Cover:
    // Size of items: 1
    [Test]
    procedure ListFromOneItemJsonArray;
    // Cover:
    // Size of items: > 1
    [Test]
    [Ignore]
    procedure ListFromThreeItemsJsonArray;

    [Test]
    [Ignore]
    procedure AAAA;

  end;

implementation

uses
  System.JSON, ReceptionRequest, System.SysUtils, ObjectsMappers,
  System.Generics.Collections;

procedure TActiveQueueControllerTest.AAAA;
var
  request: TReceptionRequest;
  json: TJsonObject;
begin
  request := TReceptionRequestBuilder.Create()
    .SetFrom('admin@google.com')
    .SetText('text content')
    .setHtml('html content')
    .setToken('token')
    .Build;
  json := Mapper.ObjectToJSonObject(request);
  Assert.IsNotNull(json.GetValue('attach'));
end;

procedure TActiveQueueControllertest.ListFromEmptyJsonArray;
var
  jo: TJSONArray;
  obj: TObjectList<TReceptionRequest>;
begin
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes('[]'), 0) as TJSONArray;
  obj := Mapper.JSONArrayToObjectList<TReceptionRequest>(jo);
  Assert.AreEqual(0, obj.Count);
end;

procedure TActiveQueueControllerTest.ListFromOneItemJsonArray;
var
  JArray: TJSONArray;
  list: TObjectList<TReceptionRequest>;
  request: TReceptionRequest;
  str: String;
  arr: TJsonArray;
  obj: TJsonObject;

begin
  request := TReceptionRequestBuilder.Create()
    .SetFrom('info@mail.com')
    .SetText('text content')
    .setHtml('html content')
    .setToken('token')
    .SetPort(28)
    .Build;
  obj := Mapper.ObjectToJSonObject(request);
  JArray := TJsonArray.Create();
  JArray.AddElement(obj);

  // JArray := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes('[' + str + ']'), 0) as TJSONArray;
  list := Mapper.JSONArrayToObjectList<TReceptionRequest>(JArray);
  Assert.AreEqual(1, list.Count);
  Assert.AreEqual('p@gmail.com', list[0].from);
  Assert.AreEqual('Google', list[0].sender);
  Assert.AreEqual('01.02.03.04', list[0].server);
end;

procedure TActiveQueueControllerTest.ListFromThreeItemsJsonArray;
var
  str: String;
  jo: TJSONArray;
  obj: TObjectList<TReceptionRequest>;
begin
  str := '{"from":"info@mail.com","port":25,"useauth":false,"usessl":false,"bodyhtml":"html content","bodytext":"text content","attach":[],"token":"token"}';

  // '[{"from":"info@mail.com","sender":"a person", "server":"127.0.1"},' +
  // ' {"from":"bill@microsoft.com", "sender":"Bill Gates", "bodyhtml":"hi, how are you?" }, ' +
  // '{"from":"mark@fb.com", "recipcc":"one, two" } ]'
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes('[' + str + ',' + str + ',' + str + ']'), 0) as TJSONArray;
  obj := Mapper.JSONArrayToObjectList<TReceptionRequest>(jo);
  Assert.AreEqual(3, obj.Count);
  Assert.AreEqual('info@mail.com', obj[0].from);
  Assert.AreEqual('a person', obj[0].sender);
  Assert.AreEqual('127.0.1', obj[0].server);

  Assert.AreEqual('bill@microsoft.com', obj[1].from);
  Assert.AreEqual('Bill Gates', obj[1].sender);
  Assert.AreEqual('hi, how are you?', obj[1].html);

  Assert.AreEqual('mark@fb.com', obj[0].from);
  Assert.AreEqual('one, two', obj[0].recipcc);

end;

initialization

TDUnitX.RegisterTestFixture(TActiveQueueControllertest);

end.
