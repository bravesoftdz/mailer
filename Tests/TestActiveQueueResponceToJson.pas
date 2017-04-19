unit TestActiveQueueResponceToJson;

interface

uses
  DUnitX.TestFramework, ActiveQueueResponce;

type

  [TestFixture]
  TTestActiveQueueResponceToJson = class(TObject)
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
    procedure SerializeNonEmptyMsg(const status: Boolean; const msg: String; const token: String);

    // procedure SerializeJustMessageIsSetToEmpty(const status: Boolean);

  end;

implementation

uses
  ObjectsMappers, System.JSON;

procedure TTestActiveQueueResponceToJson.SerializeNonEmptyMsg(
  const status: Boolean; const msg: String; const Token: String);
var
  obj: TActiveQueueResponce;
  jo: TJsonObject;
  val1, val2: TJsonValue;
begin
  obj := TActiveQueueResponce.Create(Status, msg, Token);
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

initialization

TDUnitX.RegisterTestFixture(TTestActiveQueueResponceToJson);

end.
