unit DispatcherEntryTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TDispatcherEntrytest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    /// Just to see whether the framework constructs a DispatcherEntry object from a json one.
    [Test]
    procedure CreateObjFromJson;

    /// Just to see whether the framework constructs a json object from a DispatcherEntry  one.
    [Test]
    procedure CreateJsonFromDefault;

  end;

implementation

uses
  System.JSON, DispatcherEntry, System.SysUtils, ObjectsMappers;

procedure TDispatcherEntrytest.Setup;
begin
end;

procedure TDispatcherEntrytest.TearDown;
begin
end;

procedure TDispatcherEntrytest.CreateJsonFromDefault;
var
  jo: TJsonObject;
  obj: TDispatcherEntry;
begin
  obj := TDispatcherEntry.Create();
  jo := Mapper.ObjectToJSONObject(obj);
  Assert.IsNotNull(jo);
end;

procedure TDispatcherEntrytest.CreateObjFromJson;
var
  input: String;
  jo: TJsonObject;
  obj: TDispatcherEntry;
  arr1, arr2: TArray<String>;
begin
  input := '{"origin": "external" "action":"register", "token": "abcdefgh", "content":"[ddd]"}';
  jo := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(input), 0) as TJSONObject;
  obj := Mapper.JSONObjectToObject<TDispatcherEntry>(jo);
  Assert.AreEqual('external', obj.Origin);
  Assert.AreEqual('register', obj.Action);
  Assert.AreEqual('abcdefgh', obj.Token);
  Assert.AreEqual(0, obj.Attachments.Count);
  Assert.AreEqual('[ddd]', obj.Content);
end;

initialization

TDUnitX.RegisterTestFixture(TDispatcherEntrytest);

end.
