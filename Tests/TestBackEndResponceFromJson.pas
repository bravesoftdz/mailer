unit TestBackEndResponceFromJson;

interface

uses
  DUnitX.TestFramework, System.JSON, BackEndResponce;

type

  [TestFixture]
  TTestBackEndResponceFromJson = class(TObject)
  public
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
    [TestCase('Create with empty msgstat, status true', 'True')]
    /// Cover
    /// 1. key status: false
    /// 2. key msgstat: absent
    [TestCase('Create with empty msgstat, status false', 'False')]
    procedure createEmptyMsgstat(const status: Boolean);

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
  ObjectsMappers, System.SysUtils;

procedure TTestBackEndResponceFromJson.createAbsentMsgstat(
  const status: Boolean);
var
  obj: TBackEndResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{"status": ' + BoolToStr(status, True).ToLower + '}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TBackEndResponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createEmptyMsgstat(
  const status: Boolean);
var
  obj: TBackEndResponce;
  input: String;
  jo: TJsonObject;

begin
  input := '{"status": ' + BoolToStr(status, True).ToLower + ', "msgstat":""}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createFromNoStatusEmptyMsgstat;
var
  input: String;
  obj: TBackEndResponce;
  jo: TJsonObject;
begin
  input := '{"msgstat":""}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.IsFalse(obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createFromNoStatusMsgstat;
var
  obj: TBackEndResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{"msgstat":"some string"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.IsFalse(obj.status);
  Assert.AreEqual('some string', obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createFromNoStatusNoMsgstat;
var
  obj: TBackEndResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TBackEndresponce>(jo);
  Assert.IsNotNull(obj);
  Assert.IsFalse(obj.status);
  Assert.IsEmpty(obj.Msg);
end;

procedure TTestBackEndResponceFromJson.createNonEmptyMsgstat(
  const status: Boolean);
var
  obj: TBackEndResponce;
  input: String;
  jo: TJsonObject;
begin
  input := '{"status": ' + BoolToStr(status, True).ToLower + ', "msgstat":"a string"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TBackEndResponce>(jo);
  Assert.AreEqual(status, obj.status);
  Assert.AreEqual('a string', obj.Msg);
end;

initialization

TDUnitX.RegisterTestFixture(TTestBackEndResponceFromJson);

end.
