unit SubscriptionDataTest;

interface

uses
  DUnitX.TestFramework, System.JSON;

type

  [TestFixture]
  TSubscriptionOutcomeDataTest = class(TObject)
  public
    // Test suit for creating an instance from json
    // Partition the input as follows:
    // 1. key "url": absent, "" (empty), "www.google.com"
    // 2. key "port": absent, 0, 12345
    // 3. key "path": absent, "" (empty), "/manage/notify"

    // Cover
    // 1. key "url": absent
    // 2. key "port": absent
    // 3. key "path": absent
    // 4. extra key: present, absent
    [TestCase('Construct from an empty json', '{}')]
    // Cover
    // 1. key "url": "www.google.com"
    // 2. key "port": 12345
    // 3. key "path": "/manage/notify"
    // 4. extra key: absent
    [TestCase('Construct from a complete json', '{"url": "www.google.com", "port": 12345, "path": "/manage/notify"}', '')]
    // Cover
    // 1. key "url": "www.google.com"
    // 2. key "port": absent
    // 3. key "path": absent
    // 4. extra key: absent
    [TestCase('Construct from the url', '{"url": "www.google.com"}')]
    // Cover
    // 1. key "url": absent
    // 2. key "port": 80
    // 3. key "path":
    // 4. extra key: absent
    [TestCase('Construct from the port', '{"port": 80}')]
    // Cover
    // 1. key "url": absent
    // 2. key "port": absent
    // 3. key "path": "/manage/notify"
    // 4. extra key: absent
    [TestCase('Construct from the path', '{"path": "/manage/notify"}')]
    procedure testCreateFromJson(const input: String);

    // [Test]
    // Cover
    // 1. key "url": absent
    // 2. key "port": absent
    // 3. key "path": "/manage/notify"
    // 4. extra key: presnt
    procedure testCreateFromJsonWithExtraField;

    // [Test]
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
    // [Test]
    // Cover
    // 1. field "url": "" (empty)
    // 2. field "port": 0
    // 3. field "path": "news/"
    procedure testObjectToJsonFromPath;
    // [Test]
    // 1. field "url": "" (empty)
    // 2. field "port": 0
    // 3. field "path": "news/"
    procedure testObjectToJsonAllFields;

  end;

implementation

uses
  System.SysUtils, ObjectsMappers, AQSubscriptionEntry;

procedure TSubscriptionOutcomeDataTest.testCreateFromJson(const input: String);
var
  jo: TAQSubscriptionEntry;
  obj: TAQSubscriptionEntry;
begin
  jo := TAQSubscriptionEntry.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TAQSubscriptionEntry;
  obj := Mapper.JSONObjectToObject<TAQSubscriptionEntry>(jo);
  Assert.IsNotNull(obj);
end;

procedure TAQSubscriptionEntryTest.testCreateFromJsonWithExtraField;
var
  jo: TAQSubscriptionEntry;
  obj: TAQSubscriptionEntry;
  input: String;
begin
  input := '{"url": "www.google.com", "port": 12345, "path": "/manage/notify", "extra": true}';
  jo := TAQSubscriptionEntry.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TAQSubscriptionEntry;
  obj := Mapper.JSONObjectToObject<TAQSubscriptionEntry>(jo);
  Assert.IsNotNull(obj);
end;

procedure TAQSubscriptionEntryTest.testObjectToJsonAllFields;
const
  Url = 'http://www.google.com';
  Port = 2346;
  Path = 'abc/efg';
  Ip = '123.32.11.55';
var
  jo: TAQSubscriptionEntry;
  obj: TAQSubscriptionEntry;
begin
  obj := TAQSubscriptionEntry.Create(Ip, Url, Port, Path);
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.AreEqual(Ip, jo.GetValue('ip').value);
  Assert.AreEqual(url, jo.GetValue('url').value);
  Assert.AreEqual(port, strtoint(jo.GetValue('port').value));
  Assert.AreEqual(path, jo.GetValue('path').value);

end;

procedure TAQSubscriptionEntryTest.testObjectToJsonFromDefault;
var
  jo: TAQSubscriptionEntry;
  obj: TAQSubscriptionEntry;
begin
  obj := TAQSubscriptionEntry.Create();
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.IsNotNull(jo);
end;

procedure TAQSubscriptionEntryTest.testObjectToJsonFromPath;
var
  jo: TAQSubscriptionEntry;
  obj: TAQSubscriptionEntry;
begin
  obj := TAQSubscriptionEntry.Create('111', '', 0, ' news / ');
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.IsNotNull(jo);
  Assert.AreEqual('news/', jo.GetValue('path').value, 'Path must be equal to "news/"');
end;

initialization

TDUnitX.RegisterTestFixture(TAQSubscriptionEntryTest);

end.
