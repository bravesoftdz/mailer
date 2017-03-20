unit TestBackEndResponceToJson;

interface

uses
  DUnitX.TestFramework, ActiveQueueResponce;

type

  [TestFixture]
  TTestBackEndResponceToJson = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // Test suit for the serialization
    // Partition the input as follows
    // 1. status: true, false
    // 2. message length: 0, > 0
    [Test]
    // Cover
    // 1. status: true
    // 2. message length: > 0
    [TestCase('Serialize with True and non-empty msg', 'True,a message')]
    // Cover
    // 1. status: false
    // 2. message length: > 0
    [TestCase('Serialize with False and non-empty msg', 'False, some message')]
    procedure SerializeNonEmptyMsg(const status: Boolean; const msg: String);
    [Test]
    // Cover
    // 1. status: true
    // 2. message length: 0
    [TestCase('Serialize with True and empty msg', 'True')]
    // Cover
    // 1. status: false
    // 2. message length:  0
    [TestCase('Serialize with False and empty msg', 'False')]
    procedure SerializeJustMessageIsSetToEmpty(const status: Boolean);

  end;

implementation

uses
  ObjectsMappers, System.JSON;

procedure TTestBackEndResponceToJson.SerializeNonEmptyMsg(
  const status: Boolean; const msg: String);
var
  obj: TActiveQueueResponce;
  jo: TJsonObject;
begin
  obj := TActiveQueueResponce.Create(Status, msg);
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.AreEqual((jo.GetValue('status') as TJsonBool).asBoolean, Status);
  Assert.AreEqual(jo.GetValue('msgstat').value, msg);
end;

procedure TTestBackEndResponceToJson.Setup;
begin
end;

procedure TTestBackEndResponceToJson.TearDown;
begin
end;

procedure TTestBackEndResponceToJson.SerializeJustMessageIsSetToEmpty(const status: Boolean);
var
  obj: TActiveQueueResponce;
  jo: TJsonObject;
  value: TJsonValue;
begin
  obj := TActiveQueueResponce.Create(Status, '');
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.AreEqual((jo.GetValue('status') as TJsonBool).asBoolean, Status);
  value := jo.GetValue('msgstat');
  Assert.IsTrue((value = nil) OR (value.Value = ''));
end;


initialization

TDUnitX.RegisterTestFixture(TTestBackEndResponceToJson);

end.
