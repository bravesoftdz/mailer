unit ClientFullRequest;

interface

uses ClientRequest, Web.HTTPApp, System.Generics.Collections, Attachment;

type
  /// An immutable abstract data type that represents a client request. It contains
  /// data that the client provides directly, the IP from which the client connects
  /// to this service and files that are attached to the request.
  TClientFullRequest = class
  strict private
    FIP: String;
    FRequest: TClientRequest;
    FAttachments: TObjectList<TAttachment>;
    FText: String;
    FHtml: String;

    function GetAttachments(): TObjectList<TAttachment>;

  public
    property Attachments: TObjectList<TAttachment> read GetAttachments;
    property Html: String read FHtml;
    property Text: String read FText;

    constructor Create(const Text, Html: String; const Attachments: TObjectList<TAttachment>);
  end;

implementation

uses
  System.Classes;

{ TClientFullRequest }

constructor TClientFullRequest.Create(const Text, Html: String; const Attachments: TObjectList<TAttachment>);
var
  attachment: TAttachment;
  MemStream: TMemoryStream;
begin
  FText := Text;
  FHtml := Html;
  /// make a defencive copy
  FAttachments := TObjectList<TAttachment>.Create();
  for attachment in Attachments do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.LoadFromStream(attachment.Content);
    FAttachments.Add(TAttachment.Create(attachment.Name, MemStream));
  end;
end;

function TClientFullRequest.GetAttachments: TObjectList<TAttachment>;
var
  attachment: TAttachment;
  MemStream: TMemoryStream;
begin
  /// make a defencive copy
  Result := TObjectList<TAttachment>.Create();
  for attachment in FAttachments do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.CopyFrom(attachment.Content, attachment.Content.Size);
    Result.Add(TAttachment.Create(attachment.Name, MemStream));
  end;
end;

end.
