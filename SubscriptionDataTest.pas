unit SubscriptionDataTest;

interface

uses
  DUnitX.TestFramework, System.JSON;

type

  [TestFixture]
  TSubscriptionDataTest = class(TObject)
  public
    [Test]
    // Test suit for creating an instance from json
    // Partition the input as follows:
    // 1. key "url": absent, "" (empty), "www.google.com"
    // 2. key "port": absent, 0, 12345
    // 3. key "path": absent, "" (empty), "/manage/notify"

    // Cover
    // 1. key "url": absent
    // 2. key "port": absent
    // 3. key "path": absent
    [TestCase('Construct from an empty json', '{}')]
    // Cover
    // 1. key "url": "www.google.com"
    // 2. key "port": 12345
    // 3. key "path": "/manage/notify"
    [TestCase('Construct from a complete json', '{"url": "www.google.com", "port": 12345, "path": "/manage/notify"}', '')]
    // Cover
    // 1. key "url": "www.google.com"
    // 2. key "port": absent
    // 3. key "path": absent
    [TestCase('Construct from the url', '{"url": "www.google.com"}')]
    // Cover
    // 1. key "url": absent
    // 2. key "port": 80
    // 3. key "path":
    [TestCase('Construct from the port', '{"port": 80}')]
    // Cover
    // 1. key "url": absent
    // 2. key "port": absent
    // 3. key "path": "/manage/notify"
    [TestCase('Construct from the path', '{"path": "/manage/notify"}')]
    procedure testCreateFromJson(const input: String);

    [Test]
    // Test suit for converting the instance into json
    // Partition the input as follows
    // 1. field "url": "" (empty), "http://www.example.com"
    // 2. field "port": 0, 53
    // 3. field "path": "" (empty), "news/"

    // Cover
    // 1. field "url": "" (empty)
    // 2. field "port": 0
    // 3. field "path": "" (empty)
    procedure testObjectToJsonFromDefault;
    [Test]
    // Cover
    // 1. field "url": "" (empty)
    // 2. field "port": 0
    // 3. field "path": "news/"
    procedure testObjectToJsonFromPath;
    [Test]
    // 1. field "url": "" (empty)
    // 2. field "port": 0
    // 3. field "path": "news/"
    procedure testObjectToJsonAllFields;

  end;

implementation

uses
  System.SysUtils, ObjectsMappers, SubscriptionData;

procedure TSubscriptionDataTest.testCreateFromJson(const input: String);
var
  jo: TJsonObject;
  obj: TSubscriptionData;
begin
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TSubscriptionData>(jo);
  Assert.IsNotNull(obj);
end;

procedure TSubscriptionDataTest.testObjectToJsonAllFields;
const
  Url = 'http://www.google.com';
  Port = 2346;
  Path = 'abc/efg';
var
  jo: TJsonObject;
  obj: TSubscriptionData;
begin
  obj := TSubscriptionData.Create(Url, Port, Path);
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.AreEqual(url, jo.GetValue('url').value);
  Assert.AreEqual(port, strtoint(jo.GetValue('port').value));
  Assert.AreEqual(path, jo.GetValue('path').value);

end;

procedure TSubscriptionDataTest.testObjectToJsonFromDefault;
var
  jo: TJsonObject;
  obj: TSubscriptionData;
begin
  obj := TSubscriptionData.Create();
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.IsNotNull(jo);
end;

procedure TSubscriptionDataTest.testObjectToJsonFromPath;
var
  jo: TJsonObject;
  obj: TSubscriptionData;
begin
  obj := TSubscriptionData.Create('', 0, 'news/');
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.IsNotNull(jo);
  Assert.AreEqual('news/', jo.GetValue('path').value, 'Path must be equal to "news/"');
end;

initialization

TDUnitX.RegisterTestFixture(TSubscriptionDataTest);

end.
