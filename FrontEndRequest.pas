unit FrontEndRequest;

interface

uses
  System.JSON, System.Generics.Collections, Attachment, FrontEndData,
  Web.HTTPApp;

type

  /// <summary> It is an imutable instance that represents a request obtained
  /// by combining a textual request and an attachment-related one that arrive
  /// from the front end.
  /// </summary>
  TFrontEndRequest = class
  private
    FData: TFrontEndData;
    FAttachments: TObjectList<TAttachment>;
    procedure SetAttachments(const Value: TObjectList<TAttachment>);
  public
    /// <summary> Constructor</summary>
    constructor Create(const aData: TFrontEndData; const AttachedFiles: TAbstractWebRequestFiles);
    property Data: TFrontEndData read FData;
    property Attachments: TObjectList<TAttachment> read FAttachments;
    function ToString(): String;
  end;

implementation

uses
  System.SysUtils, System.Classes;

{ TSimpleInputData }

constructor TFrontEndRequest.Create(const aData: TFrontEndData; const AttachedFiles: TAbstractWebRequestFiles);
var
  anAttachment: TAttachment;
  Len, I: Integer;
  Stream: TStream;
  MemStream: TMemoryStream;
begin
  /// defensive copying
  FData := TFrontEndData.Create(aData.Text, aData.Html);
  FAttachments := TObjectList<TAttachment>.Create;
  Len := AttachedFiles.Count;
  for I := 0 to Len - 1 do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.CopyFrom(AttachedFiles[I].Stream, AttachedFiles[I].Stream.Size);
    FAttachments.Add(TAttachment.Create(AttachedFiles[I].FieldName, MemStream));
    // MemStream.Destroy;
  end;


  // FAttachments := Attachs;
  //
  // add a fake attachment
  // fs := TFileStream.Create('c:\Users\User\Documents\image.jpg', fmOpenRead);
  // try
  // ms := TMemoryStream.Create();
  // try
  // ms.CopyFrom(fs, fs.Size);
  // Request.Attachments.Add(TAttachment.Create('img.jpg', ms));
  // except
  // ms.Destroy;
  // raise;
  // end;
  // finally
  // fs.Destroy;
  // end;
  /// end adding the fake attachment

end;

procedure TFrontEndRequest.SetAttachments(
  const Value: TObjectList<TAttachment>);
begin
  FAttachments := Value;
end;

function TFrontEndRequest.ToString: String;
var
  Builder: TStringBuilder;
begin
  Builder := TStringBuilder.Create;
  Builder.Append(', html: ');
  Builder.Append(FData);
  Result := Builder.ToString;
  Builder.DisposeOf;
end;

end.
