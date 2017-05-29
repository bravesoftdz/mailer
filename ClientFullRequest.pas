unit ClientFullRequest;

interface

uses ClientRequest, Web.HTTPApp, System.Generics.Collections, Attachment;

type
  TClientFullRequest = class

  public
    { TODO 3 :
      This is a temporary class, it is supposed to be merged with TClientRequest.
      This is a reason why the properties are made public. }
    FAttachments: TObjectList<TAttachment>;
    FRequest: TClientRequest;

    constructor Create(const Request: TClientRequest; const Attachments: TObjectList<TAttachment>);
  end;

implementation

{ TClientFullRequest }

constructor TClientFullRequest.Create;
begin
  FAttachments := Attachments;
  FRequest := Request;
end;

end.
