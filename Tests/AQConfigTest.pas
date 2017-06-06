unit AQConfigTest;

interface

uses
  DUnitX.TestFramework, AQConfig, ListenerInfo;

type

  [TestFixture]
  TAQConfigTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Test suit for creating an instance from a json
    /// It checks only one case and it is created just to see whether it works at all.
    [Test]
    procedure TestWhetherItWorks;

    /// Test suit to check how a TAQConfig instance is converted to a josn.
    /// partition the input as follows:
    /// 1. port value; 0, > 0
    /// 2. # of allowed listeners: 0, 1, > 1
    /// 3. # of allowed providers: 0, 1, > 1
    /// 4. # of listeners: 0, 1, > 1

    /// Cover:
    /// 1. port value; 0
    /// 2. # of allowed listeners: 0
    /// 3. # of allowed providers: 0
    /// 4. # of listeners: 0
    [Test]
    procedure ConvertEmpty;

    /// Cover:
    /// 1. port value; > 0
    /// 2. # of allowed listeners: > 1
    /// 3. # of allowed providers: > 1
    /// 4. # of listeners: > 1
    [Test]
    procedure ConvertPort5Listeners2Providers3Listeners2;

  end;

implementation

uses
  System.JSON, System.SysUtils, ObjectsMappers, System.Generics.Collections;

procedure TAQConfigTest.ConvertEmpty;
var
  jo: TJsonObject;
begin
  jo := TAQConfig.Create().ToJson;
  Assert.AreEqual(0, strtoint(jo.GetValue('port').value));
  Assert.AreEqual('', jo.GetValue('listeners-allowed-ips').value);
  Assert.AreEqual('', jo.GetValue('providers-allowed-ips').value);
  Assert.AreEqual(0, (jo.GetValue('listeners') as TJsonArray).Count);
end;

procedure TAQConfigTest.ConvertPort5Listeners2Providers3Listeners2;
var
  jo: TJsonObject;
  listeners: TObjectList<TListenerInfo>;
  arr: TJsonArray;
begin
  listeners := TObjectList<TListenerInfo>.Create();
  listeners.AddRange([TListenerInfoBuilder.Create().SetToken('token1').SetIP('13.14.1.5').SetPort(333).Build(),
    TListenerInfoBuilder.Create().SetToken('token2').SetIP('23.34.56.78').SetPort(1010).Build()]);
  jo := TAQConfigBuilder.Create()
    .SetPort(5)
    .SetListenerIPs(['2.2.1.3', '11.44.55.66'])
    .SetProviderIPs(['33.22.2.1', '10.12.12.13', '14.15.16.17'])
    .SetListeners(listeners).Build().ToJson;
  Assert.AreEqual(5, strtoint(jo.GetValue('port').value));
  Assert.AreEqual('2.2.1.3,11.44.55.66', jo.GetValue('listeners-allowed-ips').value);
  Assert.AreEqual('33.22.2.1,10.12.12.13,14.15.16.17', jo.GetValue('providers-allowed-ips').value);
  arr := jo.GetValue('listeners') as TJsonArray;
  Assert.AreEqual(2, arr.Count);
  Assert.AreEqual('token1', arr.Items[0].getValue<String>('token'));
  Assert.AreEqual('13.14.1.5', arr.Items[0].getValue<String>('ip'));
  Assert.AreEqual(333, arr.Items[0].getValue<Integer>('port'));
  Assert.AreEqual('token2', arr.Items[1].getValue<String>('token'));
  Assert.AreEqual('23.34.56.78', arr.Items[1].getValue<String>('ip'));
  Assert.AreEqual(1010, arr.Items[1].getValue<Integer>('port'));

end;

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
  arr1, arr2: TArray<String>;
begin
  input := '{"port": 4321, "listeners-allowed-ips":"192.111.12.1, 92.22.14.55", "listeners": [' +
    '{"token":"abc", "path":"xxx/yyy", "port":2321, "ip":"1.1.1.1"},' +
    '{"ip":"1.2.3.4", "port":56789, "token":"qazwsx", "path":"/"}],' +
    ' "providers-allowed-ips": "127.0.0.10, 187.234.22.11, 1.1.1.1"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TAQConfig>(jo);
  Assert.AreEqual(4321, obj.port);
  arr1 := obj.GetListenersIps;
  Assert.AreEqual(2, Length(arr1));
  Assert.AreEqual('192.111.12.1', arr1[0]);
  Assert.AreEqual('92.22.14.55', arr1[1]);
  arr2 := obj.GetProvidersIps;
  Assert.AreEqual(3, Length(arr2));
  Assert.AreEqual('127.0.0.10', arr2[0]);
  Assert.AreEqual('187.234.22.11', arr2[1]);
  Assert.AreEqual('1.1.1.1', arr2[2]);

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

initialization

TDUnitX.RegisterTestFixture(TAQConfigTest);

end.
