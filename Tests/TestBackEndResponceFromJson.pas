unit TestBackEndResponceFromJson;

interface

uses
  DUnitX.TestFramework, System.JSON, BackEndResponce;

type

  [TestFixture]
  TTestBackEndResponceFromJson = class(TObject)
  private
    jo: TJsonObject;
    pairStatus, pairMsg: TJsonPair;

  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Test suit for constructring the instance from a json
    /// Partition the input as follows:
    /// 1. key status: absent, true, false
    /// 2. key msgstat: absent, '' (empty string), 'some string'

    /// Cover
    /// 1. key status: absent
    /// 2. key msgstat: absent
    [Test]
    procedure createFromNoStatusNoMsgstat();
    /// Cover
    /// 1. key status: absent
    /// 2. key msgstat: ''
    [Test]
    procedure createFromNoStatusEmptyMsgstat();
    /// Cover
    /// 1. key status: absent
    /// 2. key msgstat: 'some string'
    [Test]
    procedure createFromNoStatusMsgstat();

    [Test]
    /// Cover
    /// 1. key status: true
    /// 2. key msgstat: absent
    [TestCase('Create with empty msgstat', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: absent
    [TestCase('Create with empty msgstat', 'False')]
    procedure createEmptyMsgstat(const status: Boolean);

    [Test]
    /// Cover
    /// 1. key status: true
    /// 2. key msgstat: absent
    [TestCase('Create with non-empty msgstat', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: absent
    [TestCase('Create with non-empty msgstat', 'False')]
    procedure createNonEmptyMsgstat(const status: Boolean);

    [Test]
    /// Cover
    /// 1. key status: true
    /// 2. key msgstat: absent
    [TestCase('Create with absent msgstat', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: absent
    [TestCase('Create with absent msgstat', 'False')]
    procedure createAbsentMsgstat(const status: Boolean);

  end;

implementation

uses
  ObjectsMappers;

procedure TTestBackEndResponceFromJson.createAbsentMsgstat(
  const status: Boolean);

begin
end;

procedure TTestBackEndResponceFromJson.createEmptyMsgstat(
  const status: Boolean);
var
  obj: TBackEndResponce;
begin
  jo.AddPair(TJsonPair.Create('msgstat', ''));
  jo.AddPair(TJsonPair.Create('status', TJSONBool.Create(status)));
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createFromNoStatusEmptyMsgstat;
var
  obj: TBackEndResponce;
begin
  jo.AddPair(TJsonPair.Create('msgstat', ''));
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.IsFalse(obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createFromNoStatusMsgstat;
var
  obj: TBackEndResponce;
begin
  jo.AddPair(TJsonPair.Create('msgstat', 'some string'));
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.IsFalse(obj.status);
  Assert.AreEqual(obj.Msg, 'some string');
end;

procedure TTestBackEndResponceFromJson.createFromNoStatusNoMsgstat;
var
  obj: TBackEndResponce;
begin
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.IsNotNull(obj);
  Assert.IsFalse(obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createNonEmptyMsgstat(
  const status: Boolean);
var
  obj: TBackEndResponce;
begin
  jo.AddPair(TJsonPair.Create('msgstat', 'a string'));
  jo.AddPair(TJsonPair.Create('status', TJSONBool.Create(status)));
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.AreEqual(obj.status, status);
  Assert.AreEqual(obj.Msg, 'a string');
end;

procedure TTestBackEndResponceFromJson.Setup;
begin
  jo := TJsonObject.Create;
  // pairStatus := TJsonPair.Create('status', TJsonTrue);
  pairMsg := TJsonPair.Create('text', 'a text content');

end;

procedure TTestBackEndResponceFromJson.TearDown;
begin
  jo := nil;
  pairStatus := nil;
  pairMsg := nil;
end;

initialization

TDUnitX.RegisterTestFixture(TTestBackEndResponceFromJson);

end.
