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
  strict private
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
    FToken: String;
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
    [MapperJSONSer('token')]
    property token: String read FToken;

    /// <summary> Multi argument constructor. It is recommended to use
    /// the TBackEndRequestBuilder. </summary>
    constructor Create(const AFrom: string; const ASender: string; const AServer: string; const APort: Integer; const AUseAuth: Boolean; const aUser: string;
      const APassword: string; const AUseSSL: Boolean; const AnHtml: string; const AText: string; const ASubject: string; const ARecipTo: string; const aRecipCc: string;
      const ARecipBcc: string; const AnAttach: TObjectList<TAttachment>; const AToken: String); overload;
    /// <summary> No argument constructor. It is needed for serialization.</summary>
    constructor Create(); overload;

  end;

type
  { Builder for a type that collects input data for a program that sends emails }
  TBackEndRequestBuilder = class
  strict private
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
    FToken: String;
  public
    function SetFrom(const AFrom: String): TBackEndRequestBuilder;
    function SetSender(const ASender: String): TBackEndRequestBuilder;
    function SetServer(const AServer: String): TBackEndRequestBuilder;
    function SetPort(const APort: Integer): TBackEndRequestBuilder;
    function SetAuthentification(const ALogin, APassword: String): TBackEndRequestBuilder;
    function SetUseSSL(const AUseSSL: Boolean): TBackEndRequestBuilder;
    function SetText(const AText: String): TBackEndRequestBuilder;
    function SetHtml(const AHtml: String): TBackEndRequestBuilder;
    function SetRecipTo(const ARecipTo: String): TBackEndRequestBuilder;
    function SetRecipCc(const ARecipCc: String): TBackEndRequestBuilder;
    function SetRecipBcc(const ARecipBcc: String): TBackEndRequestBuilder;
    function addAttach(const AnAttach: TAttachment): TBackEndRequestBuilder;
    function addAttachments(const Items: TObjectList<TAttachment>): TBackEndRequestBuilder;
    function SetSubject(const ASubject: String): TBackEndRequestBuilder;
    function setToken(const AToken: String): TBackEndRequestBuilder;
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
  const Items: TObjectList<TAttachment>): TBackEndRequestBuilder;
begin
  FAttach.AddRange(Items);
end;

function TBackEndRequestBuilder.Build: TBackEndRequest;
begin
  Result := TBackEndRequest.Create(FFrom, Fsender, Fserver, FPort, FUseAuth,
    FUser, FPassword, FUseSSL, FHtml, FText, FSubject, FRecipTo,
    FRecipCc, FRecipBcc, FAttach, FToken);
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
  FToken := '';
  FAttach := TObjectList<TAttachment>.Create;
end;

function TBackEndRequestBuilder.addAttach(
  const AnAttach: TAttachment): TBackEndRequestBuilder;
begin
  FAttach.Add(AnAttach);
  Result := Self;
end;

function TBackEndRequestBuilder.SetAuthentification(const ALogin,
  APassword: String): TBackEndRequestBuilder;
begin
  FUseAuth := True;
  FUser := ALogin;
  FPassword := APassword;
end;

function TBackEndRequestBuilder.SetText(
  const AText: String): TBackEndRequestBuilder;
begin
  FText := AText;
  Result := Self;
end;

function TBackEndRequestBuilder.setToken(
  const AToken: String): TBackEndRequestBuilder;
begin
  FToken := AToken;
end;

function TBackEndRequestBuilder.SetFrom(
  const AFrom: String): TBackEndRequestBuilder;
begin
  FFrom := AFrom;
  Result := Self;
end;

function TBackEndRequestBuilder.SetHtml(
  const AHtml: String): TBackEndRequestBuilder;
begin
  FHtml := AHtml;
  Result := Self;
end;

function TBackEndRequestBuilder.SetPort(
  const APort: Integer): TBackEndRequestBuilder;
begin
  FPort := APort;
  Result := Self;
end;

function TBackEndRequestBuilder.SetRecipBcc(
  const ARecipBcc: String): TBackEndRequestBuilder;
begin
  FRecipBcc := ARecipBcc;
  Result := Self;
end;

function TBackEndRequestBuilder.SetRecipCc(
  const ARecipCc: String): TBackEndRequestBuilder;
begin
  FRecipCc := ARecipCc;
  Result := Self;

end;

function TBackEndRequestBuilder.SetRecipTo(
  const ARecipTo: String): TBackEndRequestBuilder;
begin
  FRecipTo := ARecipTo;
  Result := Self;
end;

function TBackEndRequestBuilder.SetSender(
  const ASender: String): TBackEndRequestBuilder;
begin
  FSender := ASender;
  Result := Self;
end;

function TBackEndRequestBuilder.SetServer(
  const AServer: String): TBackEndRequestBuilder;
begin
  FServer := AServer;
  Result := Self;
end;

function TBackEndRequestBuilder.SetSubject(
  const ASubject: String): TBackEndRequestBuilder;
begin
  FSubject := ASubject;
  Result := Self;
end;

function TBackEndRequestBuilder.SetUseSSL(
  const AUseSSL: Boolean): TBackEndRequestBuilder;
begin
  FUseSSL := AUseSSL;
  Result := Self;
end;

{ TSenderInputData }

constructor TBackEndRequest.Create(const AFrom: string; const ASender: string;
  const AServer: string; const APort: Integer; const AUseAuth: Boolean;
  const aUser: string; const APassword: string; const AUseSSL: Boolean;
  const AnHtml: string; const AText: string; const ASubject: string;
  const ARecipTo: string; const aRecipCc: string;
  const ARecipBcc: string; const AnAttach: TObjectList<TAttachment>; const AToken: String);

begin
  FFrom := AFrom;
  FSender := ASender;
  FServer := AServer;
  FPort := APort;
  FUseAuth := AUseAuth;
  FUser := aUser;
  FPassword := APassword;
  FUseSSL := AUseSSL;
  FHtml := AnHtml;
  FText := AText;
  FSubject := ASubject;
  FRecipTo := ARecipTo;
  FRecipCc := aRecipCc;
  FRecipBcc := ARecipBcc;
  FAttach := AnAttach;
  FToken := AToken
end;

constructor TBackEndRequest.Create;
begin
  FAttach := TObjectList<TAttachment>.Create;
  // FData := TMemoryStream.Create();
end;

end.
