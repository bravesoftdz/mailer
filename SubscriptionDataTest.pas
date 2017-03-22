unit SubscriptionDataTest;

interface

uses
  DUnitX.TestFramework, System.JSON;

type

  [TestFixture]
  TSubscriptionDataTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
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
    [TestCase('Construct from a complete json', '{"url": "www.google.com", "port": 12345, "path": "/manage/notify"}')]
    // Cover
    // 1. key "url": "www.google.com"
    // 2. key "port": absent
    // 3. key "path": absent
    [TestCase('Construct from the url', '{"url": "www.google.com"}')]
    // Cover
    // 1. key "url": absent
    // 2. key "port": 80
    // 3. key "path":
    [TestCase('Construct from the url', '{"port": 80}')]
    // Cover
    // 1. key "url": absent
    // 2. key "port": absent
    // 3. key "path": "/manage/notify"
    [TestCase('Construct from the url', '{"path": "/manage/notify"}')]
    procedure testCreateFromJson(const input: String);
  end;

implementation

uses
  System.SysUtils, ObjectsMappers, SubscriptionData;

procedure TSubscriptionDataTest.Setup;
begin
end;

procedure TSubscriptionDataTest.TearDown;
begin
end;

procedure TSubscriptionDataTest.testCreateFromJson(const input: String);
var
  jo: TJsonObject;
  obj: TSubscriptionData;
begin
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TSubscriptionData>(jo);
  Assert.IsNotNull(obj.url);
  Assert.IsNotNull(obj.port);
  Assert.IsEmpty(obj.path);

end;

initialization

TDUnitX.RegisterTestFixture(TSubscriptionDataTest);

end.
