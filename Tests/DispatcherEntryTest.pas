unit DispatcherEntryTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TDispatcherEntrytest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Just to see whether the framework constructs a DispatcherEntry object from a json one.
    [Test]
    procedure CreateObjFromJson;

    [Test]
    procedure CreateObjFromJsonOneAttachment;
    [Test]
    procedure CreateObjFromJsonTwoAttachments;

    /// Just to see whether the framework constructs a json object from a DispatcherEntry  one.
    [Test]
    procedure CreateJsonFromDefault;

  end;

implementation

uses
  System.JSON, DispatcherEntry, System.SysUtils, ObjectsMappers, Attachment,
  System.Generics.Collections, System.Classes;

procedure TDispatcherEntrytest.Setup;
begin
end;

procedure TDispatcherEntrytest.TearDown;
begin
end;

procedure TDispatcherEntrytest.CreateJsonFromDefault;
var
  jo: TJsonObject;
  obj: TDispatcherEntry;
begin
  obj := TDispatcherEntry.Create();
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.IsNotNull(jo);
end;

procedure TDispatcherEntrytest.CreateObjFromJson;
var
  input: String;
  jo: TJsonObject;
  obj: TDispatcherEntry;
  arr1, arr2: TArray<String>;
begin
  input := '{"origin": "external" "action":"register", "token": "abcdefgh", "content":"[ddd]"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TDispatcherEntry>(jo);
  Assert.AreEqual('external', obj.Origin);
  Assert.AreEqual('register', obj.Action);
  Assert.AreEqual('abcdefgh', obj.Token);
  Assert.AreEqual(0, obj.Attachments.Count);
  Assert.AreEqual('[ddd]', obj.Content);
end;

procedure TDispatcherEntrytest.CreateObjFromJsonOneAttachment;
var
  input, content: String;
  jo: TJsonObject;
  obj: TDispatcherEntry;
  Attachment: TAttachment;
  SS: TStringStream;
  Attachments: TObjectList<TAttachment>;
begin
  input := '{"origin": "external" "action":"register", "token": "abcdefgh", "content":"[ddd]", "attachments":[{"name":"abc", "content":"1234567890"}]}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TDispatcherEntry>(jo);
  Assert.AreEqual('external', obj.Origin);
  Assert.AreEqual('register', obj.Action);
  Assert.AreEqual('abcdefgh', obj.Token);
  Assert.AreEqual('[ddd]', obj.Content);
  Attachments := obj.Attachments;
  Assert.AreEqual(1, Attachments.Count);
  Attachment := Attachments[0];
  SS := TStringStream.Create('');
  SS.CopyFrom(Attachment.Content, 0);
  Assert.AreEqual('abc', Attachment.Name);
  // Assert.AreEqual('10', Attachment.Content.Size.ToString);
//  Assert.AreEqual('1234567890', SS.DataString);

end;

procedure TDispatcherEntrytest.CreateObjFromJsonTwoAttachments;
var
  input, content: String;
  jo: TJsonObject;
  obj: TDispatcherEntry;
  Attachment: TAttachment;
  SS: TStringStream;
  Attachments: TObjectList<TAttachment>;
begin
  input := '{"attachments":[{"name":"file.txt", "content":"this is a file content"}, {"name":"x-1-2-3", "content":"a strea-a-a-m"}]}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TDispatcherEntry>(jo);
  Attachments := obj.Attachments;
  Assert.AreEqual(2, Attachments.Count);
  SS := TStringStream.Create('', TEncoding.UTF8);
  SS.CopyFrom(Attachments[0].Content, 0);
  Assert.AreEqual('file.txt', Attachments[0].Name);
  // Assert.AreEqual('22', Attachments[0].Content.Size.ToString);
  // Assert.AreEqual('this is a file content', SS.DataString);

  SS.CopyFrom(Attachments[1].Content, 0);
  Assert.AreEqual('x-1-2-3', Attachments[1].Name);
  // Assert.AreEqual(10, Attachments[1].Content.Size.ToString);
//  Assert.AreEqual('a strea-a-a-m', SS.DataString);

end;

initialization

TDUnitX.RegisterTestFixture(TDispatcherEntrytest);

end.
