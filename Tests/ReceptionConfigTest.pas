unit ReceptionConfigTest;

interface

uses
  DUnitX.TestFramework, ReceptionConfig;

type

  [TestFixture]
  TReceptionConfigTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Test suit for converting a json object into a TReceptionConfig one.
    /// Partition the input as follows:
    /// 1. key "port" is present: true, false
    /// 2. key "backend-port" is present: true, false
    /// 3. key "backend-url" is present: true, false
    /// 4. key "clients" is present: true, false
    /// 5. # of clients: 0, 1, > 1

    /// Cover:
    /// 1. key "port" is present: false
    /// 2. key "backend-port" is present: false
    /// 3. key "backend-url" is present: false
    /// 4. key "clients" is present: false
    /// 5. # of clients: 0
    [Test]
    procedure ConstructFromEmpty;

    /// Cover
    /// 1. key "port" is present: true
    /// 2. key "backend-port" is present: true
    /// 3. key "backend-url" is present: true
    /// 4. key "clients" is present: true
    /// 5. # of clients: 0
    [Test]
    procedure ConstructFromAllKeysArePresentZeroClients;

    /// Cover
    /// 1. key "port" is present: true
    /// 2. key "backend-port" is present: true
    /// 3. key "backend-url" is present: true
    /// 4. key "clients" is present: true
    /// 5. # of clients: > 1
    [Test]
    procedure ConstructFromAllKeysArePresentThreeClients;

  end;

implementation

uses
  System.JSON, System.SysUtils, ObjectsMappers;

procedure TReceptionConfigTest.ConstructFromAllKeysArePresentThreeClients;
var
  input: String;
  jo: TJsonObject;
  obj: TReceptionConfig;
begin
  input := '{"port": 4321, "backend-port":21, "backend-url":"www.back.end.url", "clients": [' +
    '{"token":"abc", "ip":"192.11.12.21"},{"ip":"1.2.3.4", "token":"qazwsx"}]}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TReceptionConfig>(jo);
  Assert.AreEqual(4321, obj.port);
  Assert.AreEqual(21, obj.BackEndPort);
  Assert.AreEqual('www.back.end.url', obj.BackEndUrl);
  Assert.AreEqual(2, obj.clients.count);
  Assert.AreEqual('abc', obj.clients[0].Token);
  Assert.AreEqual('192.11.12.21', obj.clients[0].Ip);
  Assert.AreEqual('qazwsx', obj.clients[1].Token);
  Assert.AreEqual('1.2.3.4', obj.clients[1].Ip);
end;

procedure TReceptionConfigTest.ConstructFromAllKeysArePresentZeroClients;
var
  input: String;
  jo: TJsonObject;
  obj: TReceptionConfig;
begin
  input := '{"port": 9, "backend-port": 85, "backend-url": "some-url", "clients": []}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TReceptionConfig>(jo);
  Assert.AreEqual(9, obj.port);
  Assert.AreEqual(85, obj.BackEndPort);
  Assert.AreEqual('some-url', obj.BackEndUrl);
  Assert.AreEqual(0, obj.clients.count);
end;

procedure TReceptionConfigTest.ConstructFromEmpty;
var
  input: String;
  jo: TJsonObject;
  obj: TReceptionConfig;
begin
  input := '{}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TReceptionConfig>(jo);
  Assert.AreEqual(0, obj.port);
  Assert.AreEqual(0, obj.BackEndPort);
  Assert.AreEqual('', obj.BackEndUrl);
  Assert.AreEqual(0, obj.clients.count);
end;

procedure TReceptionConfigTest.Setup;
begin
end;

procedure TReceptionConfigTest.TearDown;
begin
end;

initialization

TDUnitX.RegisterTestFixture(TReceptionConfigTest);

end.
