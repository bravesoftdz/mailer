unit TestFrontEndRequestFromJson;

interface

uses
  DUnitX.TestFramework, FrontEndRequest, System.JSON,
  System.Generics.Collections;

type

  [TestFixture]
  TTestFrontEndRequestFromJson = class(TObject)
  private
    json: TJsonObject;
    pairHtml, pairText, pairAttachs, pairAttach1, pairAttach2: TJsonPair;
    attach1, attach2: TJsonObject;

  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    /// A test suite for instantiation of FrontEndRequest class from a json object
    /// Partition the input as follows:
    /// 1. key "html" is present: true, false
    /// 2. key "text" is present: true, false
    /// 3. key "attachemnts" is present: true, false

    /// cover:
    /// 1. key "html" is present: false
    /// 2. key "text" is present: false
    /// 3. key "attachemnts" is present: false
    [Test]
    procedure createFromEmpty;

    /// cover:
    /// 1. key "html" is present: true
    /// 2. key "text" is present: false
    /// 3. key "attachemnts" is present: false
    [Test]
    procedure createOnlyFromHtml;

    /// cover:
    /// 1. key "html" is present: true
    /// 2. key "text" is present: true
    /// 3. key "attachemnts" is present: false
    [Test]
    procedure createFromHtmlAndText;

    /// cover:
    /// 1. key "html" is present: true
    /// 2. key "text" is present: true
    /// 3. key "attachemnts" is present: true
    [Test]
    procedure createFromHtmlTextAndAttachs;

    /// cover:
    /// 1. key "html" is present: false
    /// 2. key "text" is present: true
    /// 3. key "attachemnts" is present: false
    [Test]
    procedure createOnlyFromText;

    /// cover:
    /// 1. key "html" is present: false
    /// 2. key "text" is present: false
    /// 3. key "attachemnts" is present: true
    [Test]
    procedure createOnlyFromAttachs;

  end;

implementation

uses
  Attachment, ObjectsMappers;

procedure TTestFrontEndRequestFromJson.Setup;
begin
  json := TJsonObject.Create;
  pairHtml := TJsonPair.Create('html', 'an html content');
  pairText := TJsonPair.Create('text', 'a text content');
  pairAttach1 := TJSONPair.Create('name', 'attachment 1');
  pairAttach2 := TJSONPair.Create('name', 'attachment 2');

  attach1 := TJsonObject.Create();
  attach1.AddPair(pairAttach1);
  attach2 := TJsonObject.Create();
  attach2.AddPair(pairAttach2);

end;

procedure TTestFrontEndRequestFromJson.TearDown;
begin
  pairHtml := nil;
  pairText := nil;
  pairAttach1 := nil;
  pairAttach2 := nil;
  json := nil;
end;

procedure TTestFrontEndRequestFromJson.createFromEmpty;
var
  request: TFrontEndRequest;
begin
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(json);
  Assert.AreEqual(request.Data.Html, '');
  Assert.AreEqual(request.Data.Text, '');
  Assert.AreEqual(request.Attachments.Count, 0);
end;

procedure TTestFrontEndRequestFromJson.createFromHtmlAndText;
var
  request: TFrontEndRequest;
begin
  json.AddPair(pairHtml);
  json.AddPair(pairText);
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(json);
  Assert.AreEqual(request.Data.Html, 'an html content');
  Assert.AreEqual(request.Data.Text, 'a text content');
  Assert.AreEqual(request.Attachments.Count, 0);
end;

procedure TTestFrontEndRequestFromJson.createFromHtmlTextAndAttachs;
var
  request: TFrontEndRequest;
  arr: TJSonArray;
begin
  json.AddPair(pairHtml);
  json.AddPair(pairText);
  arr := TJSONArray.Create;
  arr.AddElement(attach1);
  arr.AddElement(attach2);
  json.AddPair(TJSONPair.Create('attachments', arr));
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(json);
  Assert.AreEqual(request.Data.Html, 'an html content');
  Assert.AreEqual(request.Data.text, 'a text content');
  Assert.AreEqual(request.Attachments.Count, 2);
end;

procedure TTestFrontEndRequestFromJson.createOnlyFromAttachs;
var
  request: TFrontEndRequest;
  arr: TJSonArray;
begin
  arr := TJSONArray.Create;
  arr.AddElement(attach2);
  json.AddPair(TJSONPair.Create('attachments', arr));
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(json);
  Assert.AreEqual(request.Data.Html, '');
  Assert.AreEqual(request.Data.text, '');
  Assert.AreEqual(request.Attachments.Count, 1);
  Assert.AreEqual(request.Attachments.Items[0].name, 'attachment 2');
end;

procedure TTestFrontEndRequestFromJson.createOnlyFromHtml;
var
  request: TFrontEndRequest;
begin
  json.AddPair(pairHtml);
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(json);
  Assert.AreEqual(request.Data.Html, 'an html content');
  Assert.AreEqual(request.Data.Text, '');
  Assert.AreEqual(request.Attachments.Count, 0);
end;

procedure TTestFrontEndRequestFromJson.createOnlyFromText;
var
  request: TFrontEndRequest;
begin
  json.AddPair(pairText);
  request := Mapper.JSONObjectToObject<TFrontEndRequest>(json);
  Assert.AreEqual(request.Data.Html, '');
  Assert.AreEqual(request.Data.Text, 'a text content');
  Assert.AreEqual(request.Attachments.Count, 0);
end;

initialization

TDUnitX.RegisterTestFixture(TTestFrontEndRequestFromJson);

end.
