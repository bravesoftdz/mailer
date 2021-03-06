unit ClientRequestTest;

interface

uses
  DUnitX.TestFramework, System.JSON, ClientRequest;

type

  [TestFixture]
  TClientRequestTest = class(TObject)
  private
    json: TJsonObject;
    pairHtml, pairText: TJsonPair;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    /// A test suite for instantiation of FrontEndRequest class from a json object
    /// Partition the input as follows:
    /// 1. key "html" is present: true, false
    /// 2. key "text" is present: true, false

    /// cover:
    /// 1. key "html" is present: false
    /// 2. key "text" is present: false
    [Test]
    procedure createFromEmpty;

    /// cover:
    /// 1. key "html" is present: true
    /// 2. key "text" is present: false
    [Test]
    procedure createOnlyFromHtml;

    /// cover:
    /// 1. key "html" is present: true
    /// 2. key "text" is present: true
    [Test]
    procedure createFromHtmlAndText;

    /// cover:
    /// 1. key "html" is present: false
    /// 2. key "text" is present: true
    [Test]
    procedure createOnlyFromText;

  end;

implementation

uses
  ObjectsMappers;

procedure TClientRequestTest.createFromEmpty;
var
  request: TClientRequest;
begin
  request := Mapper.JSONObjectToObject<TClientRequest>(json);
  Assert.AreEqual(request.Html, '');
  Assert.AreEqual(request.Text, '');
end;

procedure TClientRequestTest.createFromHtmlAndText;
var
  request: TClientRequest;
begin
  json.AddPair(pairHtml);
  json.AddPair(pairText);
  request := Mapper.JSONObjectToObject<TClientRequest>(json);
  Assert.AreEqual(request.Html, 'an html content');
  Assert.AreEqual(request.text, 'a text content');
end;

procedure TClientRequestTest.createOnlyFromHtml;
var
  request: TClientRequest;
begin
  json.AddPair(pairHtml);
  request := Mapper.JSONObjectToObject<TClientRequest>(json);
  Assert.AreEqual(request.Html, 'an html content');
  Assert.AreEqual(request.Text, '');
end;

procedure TClientRequestTest.createOnlyFromText;
var
  request: TClientRequest;
begin
  json.AddPair(pairText);
  request := Mapper.JSONObjectToObject<TClientRequest>(json);
  Assert.AreEqual(request.Html, '');
  Assert.AreEqual(request.Text, 'a text content');
end;

procedure TClientRequestTest.Setup;
begin
  json := TJsonObject.Create;
  pairHtml := TJsonPair.Create('html', 'an html content');
  pairText := TJsonPair.Create('text', 'a text content');
end;

procedure TClientRequestTest.TearDown;
begin
  pairHtml := nil;
  pairText := nil;
  json := nil;
end;

initialization

TDUnitX.RegisterTestFixture(TClientRequestTest);

end.
