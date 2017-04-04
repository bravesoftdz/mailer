unit SubscriptionOutcomeDataTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TSubscriptionOutcomeDataTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Test suit for the constructing of the instance from a json
    /// Partition input as follows
    /// 1. token key: missing, present
    /// 2. token length: 0, 1, 1 < N < 10, 256

    /// Cover
    /// 1. token key: present
    /// 2. token length: 0
    [Test]
    procedure TestFromJsonLength0;

    /// Cover
    /// 1. token key: present
    /// 2. token length: 1
    [Test]
    procedure TestFromJsonLength1;

    /// Cover
    /// 1. token key: present
    /// 2. token length: 1 < N < 6
    [Test]
    procedure TestFromJsonLength6;

    /// Cover
    /// 1. token key: present
    /// 2. token length: 256
    [Test]
    procedure TestFromJsonLength256;
  end;

implementation

uses
  System.JSON, ObjectsMappers, SubscriptionOutcomeData;

procedure TSubscriptionOutcomeDataTest.Setup;
begin
end;

procedure TSubscriptionOutcomeDataTest.TearDown;
begin
end;

procedure TSubscriptionOutcomeDataTest.TestFromJsonLength0;
var
  jo: TJsonObject;
  obj: TSubscriptionOutcomeData;
begin
  jo := TJSONObject.Create();
  jo.AddPair(TJsonPair.Create('token', ''));
  obj := Mapper.JSONObjectToObject<TSubscriptionOutcomeData>(jo);
  Assert.AreEqual('', obj.token);
end;

procedure TSubscriptionOutcomeDataTest.TestFromJsonLength1;
var
  jo: TJsonObject;
  obj: TSubscriptionOutcomeData;
begin
  jo := TJSONObject.Create();
  jo.AddPair(TJsonPair.Create('token', 'a'));
  obj := Mapper.JSONObjectToObject<TSubscriptionOutcomeData>(jo);
  Assert.AreEqual('a', obj.token);
end;

procedure TSubscriptionOutcomeDataTest.TestFromJsonLength256;
var
  jo: TJsonObject;
  obj: TSubscriptionOutcomeData;
  token: String;
  I: Integer;
begin
  token := '';
  for I := 0 to 255 do
    token := token + Char(I);
  jo := TJSONObject.Create();
  jo.AddPair(TJsonPair.Create('token', token));
  Assert.AreEqual(256, Length(token));
  obj := Mapper.JSONObjectToObject<TSubscriptionOutcomeData>(jo);
  Assert.AreEqual(token, obj.token);
end;

procedure TSubscriptionOutcomeDataTest.TestFromJsonLength6;
var
  jo: TJsonObject;
  obj: TSubscriptionOutcomeData;
begin
  jo := TJSONObject.Create();
  jo.AddPair(TJsonPair.Create('token', '123456789'));
  obj := Mapper.JSONObjectToObject<TSubscriptionOutcomeData>(jo);
  Assert.AreEqual('123456789', obj.token);
end;

initialization

TDUnitX.RegisterTestFixture(TSubscriptionOutcomeDataTest);

end.
