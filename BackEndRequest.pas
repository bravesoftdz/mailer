unit BackEndRequest;

interface

uses
  System.JSON, System.Generics.Collections, Attachment, ObjectsMappers,
  System.Classes;

type

  /// <summary>
  /// Object containing data to be sent to the back-end.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TBackEndRequest = class
  private
    FFRom: String;
    FSender: String;
    FServer: String;
    FPort: Integer;
    FUseAuth: Boolean;
    FUser: String;
    FPassword: String;
    FUseSSL: Boolean;
    FHtml: String;
    FText: String;
    FSubject: String;
    FRecipTo: String;
    FRecipCc: String;
    FRecipBcc: String;
    FAttach: TObjectList<TAttachment>;
    FData: TMemoryStream;
    /// <summary> Constructor. It is made private in order to discourage its
    /// usage in favour of the TBackEndRequestBuilder </summary>
    constructor Create(const aFrom: string; const aSender: string; const aServer: string; const aPort: Integer; const aUseAuth: Boolean; const aUser: string;
      const aPassword: string; const aUseSSL: Boolean; const aHtml: string; const aText: string; const aSubject: string; const aRecipTo: string; const aRecipCc: string;
      const aRecipBcc: string; const aAttach: TObjectList<TAttachment>); overload;

  public
    /// <summary> sender email, i.e: support@google.com</summary>
    property from: String read FFrom;
    /// <summary>  sender name, i.e: "Google Support Team" </summary>
    property sender: String read FSender;
    /// <summary>  Mail server, i.e. "10.341.32.21", "goo.mailer.com"  </summary>
    property server: String read FServer;
    /// <summary> port number, i.e. 25  </summary>
    property port: Integer read FPort;
    /// <summary> whether the user authentification is required  </summary>
    property useauth: Boolean read FUseAuth;
    /// <summary> user name in case the authentification is required </summary>
    property user: String read FUser;
    /// <summary> the password in case the authentification is required </summary>
    property password: String read FPassword;
    /// <summary> whether to use SSL </summary>
    property usessl: Boolean read FUseSSL;
    /// <summary> html text version of the message to send </summary>
    [MapperJSONSer('bodyhtml')]
    property html: String read FHtml;
    /// <summary> plain text version of the message to send </summary>
    [MapperJSONSer('bodytext')]
    property text: String read FText write FText;
    /// <summary> email subject, i.e. "News for you" </summary>
    property subject: String read FSubject;
    /// <summary> list of email addresses of the recipients (to) </summary>
    property recipto: String read FRecipTo;
    /// <summary> list of email addresses of the recipients (cc) </summary>
    property recipcc: String read FRecipCc;
    /// <summary> list of email addresses of the recipients (bcc) </summary>
    property recipbcc: String read FRecipBcc;
    /// <summary> list of attachment contents </summary>
    [MapperJSONSer('attach')]
    property attachment: TObjectList<TAttachment> read FAttach;
    // [MapperJSONSer('file')]
    // property data: TMemoryStream read FData write FData;
    constructor Create(); overload;

  end;

type
  { Builder for a type that collects input data for a program that sends emails }
  TBackEndRequestBuilder = class
  private
    FFRom: String;
    FSender: String;
    FServer: String;
    FPort: Integer;
    FUseAuth: Boolean;
    FSubject: String;
    FUser: String;
    FPassword: String;
    FUseSSL: Boolean;
    FHtml: String;
    FText: String;
    FRecipTo: String;
    FRecipCc: String;
    FRecipBcc: String;
    FAttach: TObjectList<TAttachment>;
  public
    function SetFrom(const aFrom: String): TBackEndRequestBuilder;
    function SetSender(const aSender: String): TBackEndRequestBuilder;
    function SetServer(const aServer: String): TBackEndRequestBuilder;
    function SetPort(const aPort: Integer): TBackEndRequestBuilder;
    function SetAuthentification(const aLogin, aPassword: String): TBackEndRequestBuilder;
    function SetUseSSL(const aUseSSL: Boolean): TBackEndRequestBuilder;
    function SetText(const aText: String): TBackEndRequestBuilder;
    function SetHtml(const aHtml: String): TBackEndRequestBuilder;
    function SetRecipTo(const aRecipTo: String): TBackEndRequestBuilder;
    function SetRecipCc(const aRecipCc: String): TBackEndRequestBuilder;
    function SetRecipBcc(const aRecipBcc: String): TBackEndRequestBuilder;
    function addAttach(const anAttach: TAttachment): TBackEndRequestBuilder;
    function addAttachments(const items: TObjectList<TAttachment>): TBackEndRequestBuilder;
    function SetSubject(const aSubject: String): TBackEndRequestBuilder;
    function Build(): TBackEndRequest;
    constructor Create();
  end;

implementation

uses
  System.SysUtils;

{ TSendern

  uses
  System.Generics.Collections;nputDataBuilder }

function TBackEndRequestBuilder.addAttachments(
  const items: TObjectList<TAttachment>): TBackEndRequestBuilder;
begin
  FAttach.AddRange(items);
end;

function TBackEndRequestBuilder.Build: TBackEndRequest;
begin
  Result := TBackEndRequest.Create(FFrom, Fsender, Fserver, FPort, FUseAuth,
    FUser, FPassword, FUseSSL, FText, FHtml, FSubject, FRecipTo,
    FRecipCc, FRecipBcc, FAttach);
end;

constructor TBackEndRequestBuilder.Create;
begin
  FUseAuth := False;
  FPort := 25; // default port number
  FFrom := '';
  FSender := '';
  FServer := '';
  FSubject := '';
  FUser := '';
  FPassword := '';
  FUseSSL := false;
  FHtml := '';
  FRecipTo := '';
  FRecipCc := '';
  FRecipBcc := '';
  FAttach := TObjectList<TAttachment>.Create;
end;

function TBackEndRequestBuilder.addAttach(
  const anAttach: TAttachment): TBackEndRequestBuilder;
begin
  FAttach.Add(anAttach);
  Result := Self;
end;

function TBackEndRequestBuilder.SetAuthentification(const aLogin,
  aPassword: String): TBackEndRequestBuilder;
begin
  FUseAuth := True;
  FUser := aLogin;
  FPassword := aPassword;
end;

function TBackEndRequestBuilder.SetText(
  const aText: String): TBackEndRequestBuilder;
begin
  FText := aText;
  Result := Self;
end;

function TBackEndRequestBuilder.SetFrom(
  const aFrom: String): TBackEndRequestBuilder;
begin
  FFrom := aFrom;
  Result := Self;
end;

function TBackEndRequestBuilder.SetHtml(
  const aHtml: String): TBackEndRequestBuilder;
begin
  FHtml := aHtml;
  Result := Self;
end;

function TBackEndRequestBuilder.SetPort(
  const aPort: Integer): TBackEndRequestBuilder;
begin
  FPort := aPort;
  Result := Self;
end;

function TBackEndRequestBuilder.SetRecipBcc(
  const aRecipBcc: String): TBackEndRequestBuilder;
var
  item: String;
begin
  FRecipBcc := aRecipBcc;
  Result := Self;
end;

function TBackEndRequestBuilder.SetRecipCc(
  const aRecipCc: String): TBackEndRequestBuilder;
var
  item: String;
begin
  FRecipCc := aRecipCc;
  Result := Self;

end;

function TBackEndRequestBuilder.SetRecipTo(
  const aRecipTo: String): TBackEndRequestBuilder;
var
  item: String;
begin
  FRecipTo := aRecipTo;
  Result := Self;
end;

function TBackEndRequestBuilder.SetSender(
  const aSender: String): TBackEndRequestBuilder;
begin
  FSender := aSender;
  Result := Self;
end;

function TBackEndRequestBuilder.SetServer(
  const aServer: String): TBackEndRequestBuilder;
begin
  FServer := aServer;
  Result := Self;
end;

function TBackEndRequestBuilder.SetSubject(
  const aSubject: String): TBackEndRequestBuilder;
begin
  FSubject := aSubject;
  Result := Self;
end;

function TBackEndRequestBuilder.SetUseSSL(
  const aUseSSL: Boolean): TBackEndRequestBuilder;
begin
  FUseSSL := aUseSSL;
  Result := Self;
end;

{ TSenderInputData }

constructor TBackEndRequest.Create(const aFrom: string; const aSender: string;
  const aServer: string; const aPort: Integer; const aUseAuth: Boolean;
  const aUser: string; const aPassword: string; const aUseSSL: Boolean;
  const aHtml: string; const aText: string; const aSubject: string;
  const aRecipTo: string; const aRecipCc: string;
  const aRecipBcc: string; const aAttach: TObjectList<TAttachment>);

begin
  FFrom := aFrom;
  FSender := aSender;
  FServer := aServer;
  FPort := aPort;
  FUseAuth := aUseAuth;
  FUser := aUser;
  FPassword := aPassword;
  FUseSSL := aUseSSL;
  FHtml := aHtml;
  FText := aText;
  FSubject := aSubject;
  FRecipTo := aRecipTo;
  FRecipCc := aRecipCc;
  FRecipBcc := aRecipBcc;
  FAttach := aAttach;
end;

constructor TBackEndRequest.Create;
begin
  FAttach := TObjectList<TAttachment>.Create;
  // FData := TMemoryStream.Create();
end;

end.
