unit AQConfigTest;

interface

uses
  DUnitX.TestFramework, AQConfig;

type

  [TestFixture]
  TAQConfigTest = class(TObject)
  private
    procedure Test2(const AValue1, AValue2: Integer);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Test suit for creating an instance from a json
    /// It checks only one case and it is created just to see whether it works at all.
    [Test]
    procedure TestWhetherItWorks;
  end;

implementation

uses
  System.JSON, System.SysUtils, ObjectsMappers;

procedure TAQConfigTest.Setup;
begin
end;

procedure TAQConfigTest.TearDown;
begin
end;

procedure TAQConfigTest.TestWhetherItWorks;
var
  input: String;
  jo: TJsonObject;
  obj: TAQConfig;
begin
  input := '{"port": 4321, "ips":["192.111.12.1", "92.22.14.55"], "listeners": [' +
    '{"token":"abc", "path":"xxx/yyy", "port":2321, "ip":"1.1.1.1"},' +
    '{"ip":"1.2.3.4", "port":56789, "token":"qazwsx", "path":"/"}]}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TAQConfig>(jo);
  Assert.AreEqual(4321, obj.port);
  Assert.AreEqual(2, Length(obj.IPs));
  Assert.AreEqual('192.111.12.1', obj.IPs[0]);
  Assert.AreEqual('92.22.14.55', obj.IPs[1]);
  Assert.AreEqual(2, obj.Listeners.Count);
  Assert.AreEqual('abc', obj.Listeners[0].token);
  Assert.AreEqual('xxx/yyy', obj.Listeners[0].path);
  Assert.AreEqual(2321, obj.Listeners[0].port);
  Assert.AreEqual('1.1.1.1', obj.Listeners[0].ip);
  Assert.AreEqual('qazwsx', obj.Listeners[1].token);
  Assert.AreEqual('/', obj.Listeners[1].path);
  Assert.AreEqual(56789, obj.Listeners[1].port);
  Assert.AreEqual('1.2.3.4', obj.Listeners[1].ip);

end;

procedure TAQConfigTest.Test2(const AValue1: Integer; const AValue2: Integer);
begin
end;

initialization

TDUnitX.RegisterTestFixture(TAQConfigTest);

end.
