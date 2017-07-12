unit AQConfigTest;

interface

uses
  DUnitX.TestFramework, AQConfig, Consumer;

type

  [TestFixture]
  TAQConfigTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

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
    [Ignore]
    procedure ConvertEmpty;

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

procedure TAQConfigTest.Setup;
begin
end;

procedure TAQConfigTest.TearDown;
begin
end;

initialization

TDUnitX.RegisterTestFixture(TAQConfigTest);

end.
