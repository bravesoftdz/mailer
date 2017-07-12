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
    procedure ListFromEmptyJsonArray;
    // Cover:
    // Size of items: 1
    [Test]
    procedure ListFromOneItemJsonArray;
    // Cover:
    // Size of items: > 1
    [Test]
    procedure ListFromThreeItemsJsonArray;

  end;

implementation

uses
  System.JSON, System.SysUtils, ObjectsMappers,
  System.Generics.Collections;

procedure TActiveQueueControllertest.ListFromEmptyJsonArray;
var
  jo: TJSONArray;
  // obj: TObjectList<TReceptionRequest>;
begin
//  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes('[]'), 0) as TJSONArray;
//  obj := Mapper.JSONArrayToObjectList<TReceptionRequest>(jo);
  // Assert.AreEqual(0, obj.Count);
end;

procedure TActiveQueueControllerTest.ListFromOneItemJsonArray;
var
  JArray: TJSONArray;
  // list: TObjectList<TReceptionRequest>;
  // request: TReceptionRequest;
  // obj: TJsonObject;
begin
  // request := TReceptionRequestBuilder.Create()
  // .SetFrom('info@mail.com')
  // .SetText('text content')
  // .SetSender('Google')
  // .setHtml('html content')
  // .setToken('token')
  // .SetServer('01.02.03.04')
  // .SetPort(28)
  // .Build;
  // obj := Mapper.ObjectToJSonObject(request);
  // JArray := TJsonArray.Create();
  // JArray.AddElement(obj);
  //
  // list := Mapper.JSONArrayToObjectList<TReceptionRequest>(JArray);
  // Assert.AreEqual(1, list.Count);
  // Assert.AreEqual('info@mail.com', list[0].from);
  // Assert.AreEqual('Google', list[0].sender);
  // Assert.AreEqual('01.02.03.04', list[0].server);
end;

procedure TActiveQueueControllerTest.ListFromThreeItemsJsonArray;
var
  str1, str2, str3: String;
  jo: TJSONArray;
  // obj: TObjectList<TReceptionRequest>;
begin
  // str1 := '{"from":"info1@mail.com","sender":"John","port":25,"useauth":false,"usessl":false,' +
  // '"bodyhtml":"html content 1","bodytext":"text content 1","server":"127.10.10.10", "attach":[],"token":"token 1"}';
  // str2 := '{"from":"info2@mail.com","sender":"Bob","port":26,"useauth":false,"usessl":true,' +
  // '"bodyhtml":"html content 2","bodytext":"text content 2","server":"127.10.10.11", "attach":[],"token":"token 2"}';
  // str3 := '{"from":"info3@mail.com","sender":"Alice","port":27,"useauth":true,"usessl":false,' +
  // '"bodyhtml":"html content 3","bodytext":"text content 3","server":"127.10.10.12", "attach":[],"token":"token 3"}';
  // jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes('[' + str1 + ',' + str2 + ',' + str3 + ']'), 0) as TJSONArray;
  // obj := Mapper.JSONArrayToObjectList<TReceptionRequest>(jo);
  // Assert.AreEqual(3, obj.Count);
  //
  // Assert.AreEqual('info1@mail.com', obj[0].from);
  // Assert.AreEqual('John', obj[0].sender);
  // Assert.IsFalse(obj[0].useauth);
  // Assert.IsFalse(obj[0].usessl);
  // Assert.AreEqual('html content 1', obj[0].html);
  // Assert.AreEqual('text content 1', obj[0].text);
  // Assert.AreEqual('127.10.10.10', obj[0].server);
  // Assert.AreEqual(0, obj[0].attachment.Count);
  // Assert.AreEqual('token 1', obj[0].token);
  //
  // Assert.AreEqual('info2@mail.com', obj[1].from);
  // Assert.AreEqual('Bob', obj[1].sender);
  // Assert.IsFalse(obj[1].useauth);
  // Assert.IsTrue(obj[1].usessl);
  // Assert.AreEqual('html content 2', obj[1].html);
  // Assert.AreEqual('text content 2', obj[1].text);
  // Assert.AreEqual('127.10.10.11', obj[1].server);
  // Assert.AreEqual(0, obj[1].attachment.Count);
  // Assert.AreEqual('token 2', obj[1].token);
  //
  // Assert.AreEqual('info3@mail.com', obj[2].from);
  // Assert.AreEqual('Alice', obj[2].sender);
  // Assert.IsTrue(obj[2].useauth);
  // Assert.IsFalse(obj[2].usessl);
  // Assert.AreEqual('html content 3', obj[2].html);
  // Assert.AreEqual('text content 3', obj[2].text);
  // Assert.AreEqual('127.10.10.12', obj[2].server);
  // Assert.AreEqual(0, obj[2].attachment.Count);
  // Assert.AreEqual('token 3', obj[2].token);

end;

initialization

TDUnitX.RegisterTestFixture(TActiveQueueControllertest);

end.
