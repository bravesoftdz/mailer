unit ActiveQueueResponceTest;

interface

uses
  DUnitX.TestFramework, ActiveQueueResponce;

type

  [TestFixture]
  TActiveQueueResponceTest = class(TObject)
  public
    // Test suit for the serialization
    // Partition the input as follows
    // 1. status: true, false
    // 2. message length: 0, > 0
    // 3. token length: 0, > 0
    [Test]
    // Cover
    // 1. status: true
    // 2. message length: > 0
    // 3. token length: > 0
    [TestCase('Serialize with True and non-empty msg and token', 'True,a message,token')]
    // Cover
    // 1. status: false
    // 2. message length: > 0
    // 3. token length: > 0
    [TestCase('Serialize with False and non-empty msg and token', 'False, some message, a token')]
    // Cover
    // 1. status: true
    // 2. message length: 0
    // 3. token length:  0
    [TestCase('Serialize with True and empty msg and token', 'True,,')]
    // Cover
    // 1. status: false
    // 2. message length:  0
    // 3. token length:  0
    [TestCase('Serialize with False and empty msg and token', 'False,,')]
    // Cover
    // 1. status: true
    // 2. message length: > 0
    // 3. token length:  0
    [TestCase('Serialize with True and non-empty msg and empty token', 'True,some message,')]
    // Cover
    // 1. status: false
    // 2. message length:  0
    // 3. token length:  > 0
    [TestCase('Serialize with False and empty msg and non-empty token', 'False,,some token')]
    [Ignore]
    procedure SerializeNonEmptyMsg(const status: Boolean; const msg: String; const token: String);

    /// Test suit for constructring the instance from a json
    /// Partition the input as follows:
    /// 1. key status: absent, true, false
    /// 2. key msgstat: absent, '' (empty string), 'some string'
    /// 3. key token: absent, '' (empty string), 'a token' (non empty string)

    /// Cover
    /// 1. key status: absent
    /// 2. key msgstat: absent
    /// 3. key token: absent
    [Test]
    procedure createFromNoStatusNoMsgstatNoToken();
    /// Cover
    /// 1. key status: absent
    /// 2. key msgstat: ''
    /// 3. key token: ''
    [Test]
    procedure createFromNoStatusEmptyMsgstatEmptyToken();
    /// Cover
    /// 1. key status: absent
    /// 2. key msgstat: 'some string'
    /// 3. key token: absent
    [Test]
    procedure createFromNoStatusMsgstatNoToken();

    [Test]
    /// Cover
    /// 1. key status: true
    /// 2. key msgstat: ''
    /// 3. key token: ''
    [TestCase('Create with empty msgstat, status true', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: ''
    /// 3. key token: ''
    [TestCase('Create with empty msgstat, status false', 'False')]
    procedure createEmptyMsgstatEmptyToken(const status: Boolean);

    [Test]
    /// Cover
    /// 1. key status: true
    /// 2. key msgstat: absent
    [TestCase('Create with msgstat="a string", status=true', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: absent
    [TestCase('Create with msgstat="a string", status=false', 'False')]
    procedure createNonEmptyMsgstat(const status: Boolean);

    [Test]
    /// Cover
    /// 1. key status: true
    /// 2. key msgstat: absent
    [TestCase('Create with absent msgstat, status=true', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: absent
    [TestCase('Create with absent msgstat, status=false', 'False')]
    procedure createAbsentMsgstat(const status: Boolean);
  end;

implementation

uses
  ObjectsMappers, System.JSON, System.SysUtils;

procedure TActiveQueueResponceTest.SerializeNonEmptyMsg(
  const status: Boolean; const msg: String; const Token: String);
var
  obj: TActiveQueueResponce;
  jo: TJsonObject;
  val1, val2: TJsonValue;
begin
  obj := TActiveQueueResponce.Create(Status, msg);
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.AreEqual((jo.GetValue('status') as TJsonBool).asBoolean, Status);
  val1 := jo.GetValue('msgstat');
  val2 := jo.GetValue('token');
  if msg = '' then
    Assert.IsTrue((val1 = nil) OR (val1.Value = ''))
  else
    Assert.AreEqual(val1.value, msg);

  if Token = '' then
    Assert.IsTrue((val2 = nil) OR (val2.Value = ''))
  else
    Assert.AreEqual(val2.value, Token);
end;

procedure TActiveQueueResponceTest.createAbsentMsgstat(
  const status: Boolean);
var
  obj: TActiveQueueResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{"status": ' + BoolToStr(status, True).ToLower + '}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TActiveQueueResponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TActiveQueueResponceTest.createEmptyMsgstatEmptyToken(
  const status: Boolean);
var
  obj: TActiveQueueResponce;
  input: String;
  jo: TJsonObject;

begin
  input := '{"status": ' + BoolToStr(status, True).ToLower + ', "msgstat":"", "token":""}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TActiveQueueResponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.IsEmpty(obj.Msg);
  Assert.IsEmpty(obj.Token);
end;

procedure TActiveQueueResponceTest.createFromNoStatusEmptyMsgstatEmptyToken;
var
  input: String;
  obj: TActiveQueueResponce;
  jo: TJsonObject;
begin
  input := '{"msgstat":"", "token":""}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TActiveQueueResponce>(jo);
  Assert.IsFalse(obj.status);
  Assert.IsEmpty(obj.Msg);
  Assert.IsEmpty(obj.Token);
end;

procedure TActiveQueueResponceTest.createFromNoStatusMsgstatNoToken;
var
  obj: TActiveQueueResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{"msgstat":"some string"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TActiveQueueResponce>(jo);
  Assert.IsFalse(obj.status);
  Assert.AreEqual('some string', obj.Msg);
end;

procedure TActiveQueueResponceTest.createFromNoStatusNoMsgstatNoToken;
var
  obj: TActiveQueueResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TActiveQueueResponce>(jo);
  Assert.IsNotNull(obj);
  Assert.IsFalse(obj.status);
  Assert.IsEmpty(obj.Msg);
  Assert.IsEmpty(obj.Token);
end;

procedure TActiveQueueResponceTest.createNonEmptyMsgstat(
  const status: Boolean);
var
  obj: TActiveQueueResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{"status": ' + BoolToStr(status, True).ToLower + ', "msgstat":"a string"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TActiveQueueResponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.AreEqual('a string', obj.Msg);
end;

initialization

TDUnitX.RegisterTestFixture(TActiveQueueResponceTest);

end.
