unit FrontEndRequestTest;

interface

uses
  DUnitX.TestFramework, FrontEndRequest, System.JSON,
  System.Generics.Collections;

type

  [TestFixture]
  TFrontEndRequestTest = class(TObject)
  private
    Root, DataNode: TJsonObject;
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
  Attachment, ObjectsMappers;

procedure TFrontEndRequestTest.Setup;
begin
  Root := TJsonObject.Create;
  DataNode := TJsonObject.Create;
  Root.addPair('data', DataNode);
  pairHtml := TJsonPair.Create('html', 'an html content');
  pairText := TJsonPair.Create('text', 'a text content');
end;

procedure TFrontEndRequestTest.TearDown;
begin
  pairHtml := nil;
  pairText := nil;
  Root := nil;
end;

procedure TFrontEndRequestTest.createFromEmpty;
var
  request: TFrontEndRequest;
begin
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(root);
  Assert.AreEqual(request.Data.Html, '');
  Assert.AreEqual(request.Data.Text, '');
end;

procedure TFrontEndRequestTest.createFromHtmlAndText;
var
  request: TFrontEndRequest;
begin
  DataNode.AddPair(pairHtml);
  DataNode.AddPair(pairText);
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(Root);
  Assert.AreEqual(request.Data.Html, 'an html content');
  Assert.AreEqual(request.Data.Text, 'a text content');
end;

procedure TFrontEndRequestTest.createOnlyFromHtml;
var
  request: TFrontEndRequest;
begin
  DataNode.AddPair(pairHtml);
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(Root);
  Assert.AreEqual(request.Data.Html, 'an html content');
  Assert.AreEqual(request.Data.Text, '');
end;

procedure TFrontEndRequestTest.createOnlyFromText;
var
  request: TFrontEndRequest;
begin
  DataNode.AddPair(pairText);
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(Root);
  Assert.AreEqual(request.Data.Html, '');
  Assert.AreEqual(request.Data.Text, 'a text content');
end;

initialization

TDUnitX.RegisterTestFixture(TFrontEndRequestTest);

end.
