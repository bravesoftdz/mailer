unit ReceptionRequest;

interface

uses
  System.JSON, System.Generics.Collections, Attachment, ObjectsMappers,
  System.Classes;

type

  /// <summary>
  /// Object containing data to be sent to the back-end.
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TReceptionRequest = class
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
  TReceptionRequestBuilder = class
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
    function SetFrom(const AFrom: String): TReceptionRequestBuilder;
    function SetSender(const ASender: String): TReceptionRequestBuilder;
    function SetServer(const AServer: String): TReceptionRequestBuilder;
    function SetPort(const APort: Integer): TReceptionRequestBuilder;
    function SetAuthentification(const ALogin, APassword: String): TReceptionRequestBuilder;
    function SetUseSSL(const AUseSSL: Boolean): TReceptionRequestBuilder;
    function SetText(const AText: String): TReceptionRequestBuilder;
    function SetHtml(const AHtml: String): TReceptionRequestBuilder;
    function SetRecipTo(const ARecipTo: String): TReceptionRequestBuilder;
    function SetRecipCc(const ARecipCc: String): TReceptionRequestBuilder;
    function SetRecipBcc(const ARecipBcc: String): TReceptionRequestBuilder;
    function addAttach(const AnAttach: TAttachment): TReceptionRequestBuilder;
    function addAttachments(const Items: TObjectList<TAttachment>): TReceptionRequestBuilder;
    function SetSubject(const ASubject: String): TReceptionRequestBuilder;
    function setToken(const AToken: String): TReceptionRequestBuilder;
    function Build(): TReceptionRequest;
    constructor Create();
  end;

implementation

uses
  System.SysUtils;

{ TSendern

  uses
  System.Generics.Collections;nputDataBuilder }

function TReceptionRequestBuilder.addAttachments(
  const Items: TObjectList<TAttachment>): TReceptionRequestBuilder;
begin
  FAttach.AddRange(Items);
end;

function TReceptionRequestBuilder.Build: TReceptionRequest;
begin
  Result := TReceptionRequest.Create(FFrom, Fsender, Fserver, FPort, FUseAuth,
    FUser, FPassword, FUseSSL, FHtml, FText, FSubject, FRecipTo,
    FRecipCc, FRecipBcc, FAttach, FToken);
end;

constructor TReceptionRequestBuilder.Create;
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

function TReceptionRequestBuilder.addAttach(
  const AnAttach: TAttachment): TReceptionRequestBuilder;
begin
  FAttach.Add(AnAttach);
  Result := Self;
end;

function TReceptionRequestBuilder.SetAuthentification(const ALogin,
  APassword: String): TReceptionRequestBuilder;
begin
  FUseAuth := True;
  FUser := ALogin;
  FPassword := APassword;
end;

function TReceptionRequestBuilder.SetText(
  const AText: String): TReceptionRequestBuilder;
begin
  FText := AText;
  Result := Self;
end;

function TReceptionRequestBuilder.setToken(
  const AToken: String): TReceptionRequestBuilder;
begin
  FToken := AToken;
end;

function TReceptionRequestBuilder.SetFrom(
  const AFrom: String): TReceptionRequestBuilder;
begin
  FFrom := AFrom;
  Result := Self;
end;

function TReceptionRequestBuilder.SetHtml(
  const AHtml: String): TReceptionRequestBuilder;
begin
  FHtml := AHtml;
  Result := Self;
end;

function TReceptionRequestBuilder.SetPort(
  const APort: Integer): TReceptionRequestBuilder;
begin
  FPort := APort;
  Result := Self;
end;

function TReceptionRequestBuilder.SetRecipBcc(
  const ARecipBcc: String): TReceptionRequestBuilder;
begin
  FRecipBcc := ARecipBcc;
  Result := Self;
end;

function TReceptionRequestBuilder.SetRecipCc(
  const ARecipCc: String): TReceptionRequestBuilder;
begin
  FRecipCc := ARecipCc;
  Result := Self;

end;

function TReceptionRequestBuilder.SetRecipTo(
  const ARecipTo: String): TReceptionRequestBuilder;
begin
  FRecipTo := ARecipTo;
  Result := Self;
end;

function TReceptionRequestBuilder.SetSender(
  const ASender: String): TReceptionRequestBuilder;
begin
  FSender := ASender;
  Result := Self;
end;

function TReceptionRequestBuilder.SetServer(
  const AServer: String): TReceptionRequestBuilder;
begin
  FServer := AServer;
  Result := Self;
end;

function TReceptionRequestBuilder.SetSubject(
  const ASubject: String): TReceptionRequestBuilder;
begin
  FSubject := ASubject;
  Result := Self;
end;

function TReceptionRequestBuilder.SetUseSSL(
  const AUseSSL: Boolean): TReceptionRequestBuilder;
begin
  FUseSSL := AUseSSL;
  Result := Self;
end;

{ TSenderInputData }

constructor TReceptionRequest.Create(const AFrom: string; const ASender: string;
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

constructor TReceptionRequest.Create;
begin
  FAttach := TObjectList<TAttachment>.Create;
  // FData := TMemoryStream.Create();
end;

end.
