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

    function GetRequest(): TClientRequest;
    function GetAttachments(): TObjectList<TAttachment>;

  public
    property Request: TClientRequest read GetRequest;
    property Attachments: TObjectList<TAttachment> read GetAttachments;
    property IP: String read FIP;

    constructor Create(const Request: TClientRequest; const IP: String; const Attachments: TObjectList<TAttachment>);
  end;

implementation

uses
  System.Classes;

{ TClientFullRequest }

constructor TClientFullRequest.Create(const Request: TClientRequest; const IP: String;
  const Attachments: TObjectList<TAttachment>);
var
  attachment: TAttachment;
  MemStream: TMemoryStream;
begin
  FIP := IP;
  FAttachments := TObjectList<TAttachment>.Create();
  for attachment in Attachments do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.CopyFrom(attachment.Content, attachment.Content.Size);
    FAttachments.Add(TAttachment.Create(attachment.Name, MemStream));
  end;
  FRequest := TClientRequest.Create(Request.Text, Request.Html, Request.Token);
end;

function TClientFullRequest.GetAttachments: TObjectList<TAttachment>;
var
  attachment: TAttachment;
  MemStream: TMemoryStream;
begin
  Result := TObjectList<TAttachment>.Create();
  for attachment in FAttachments do
  begin
    MemStream := TMemoryStream.Create();
    MemStream.CopyFrom(attachment.Content, attachment.Content.Size);
    Result.Add(TAttachment.Create(attachment.Name, MemStream));
  end;
end;

function TClientFullRequest.GetRequest: TClientRequest;
begin
  Result := TClientRequest.Create(FRequest.Text, FRequest.Html, FRequest.Token);
end;

end.
