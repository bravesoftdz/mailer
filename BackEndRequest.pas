unit BackEndRequest;

interface

uses
  System.Classes, System.JSON,
  System.Generics.Collections;

type
  TMsgTypes = (text, html);

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
    FMsgType: TMsgTypes;
    FBody: String;
    FSubject: String;
    FRecipTo: String;
    FRecipCc: String;
    FRecipBcc: String;
    FAttach: String;
    /// <summary> Constructor. It is made private in order to discourage its
    /// usage in favour of the TBackEndRequestBuilder </summary>
    constructor Create(const aFrom, aSender, aServer: String; const aPort: Integer;
      const aUseAuth: Boolean;
      const aUser, aPassword: String;
      const aUseSSL: Boolean;
      const aMsgType: TMsgTypes;
      const aBody, aSubject: String;
      const aRecipTo, aRecipCc, aRecipBcc, aAttach: String
      );

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
    /// <summary> whether to use SSL       </summary>
    property usessl: Boolean read FUseSSL;
    /// <summary> html version of the message to send </summary>
    property html: TMsgTypes read FMsgType;
    /// <summary> plain text version of the message to send </summary>
    property text: String read FBody;
    /// <summary>email subject, i.e. "News for you" </summary>
    property subject: String read FSubject;
    /// <summary> list of email addresses of the recipients (to) </summary>
    property recipto: String read FRecipTo;
    /// <summary> list of email addresses of the recipients (cc) </summary>
    property recipcc: String read FRecipCc;
    /// <summary> list of email addresses of the recipients (bcc) </summary>
    property recipbcc: String read FRecipBcc;
    /// <summary> list of attachment contents </summary>
    property attach: String read FAttach;

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
    FMsgType: TMsgTypes;
    FBody: String;
    FRecipTo: String;
    FRecipCc: String;
    FRecipBcc: String;
    FAttach: String;
  public
    function SetFrom(const aFrom: String): TBackEndRequestBuilder;
    function SetSender(const aSender: String): TBackEndRequestBuilder;
    function SetServer(const aServer: String): TBackEndRequestBuilder;
    function SetPort(const aPort: Integer): TBackEndRequestBuilder;
    function SetAuthentification(const aLogin, aPassword: String): TBackEndRequestBuilder;
    function SetUseSSL(const aUseSSL: Boolean): TBackEndRequestBuilder;
    function SetMsgType(const aMsgType: TMsgTypes): TBackEndRequestBuilder;
    function SetBody(const aBody: String): TBackEndRequestBuilder;
    function SetRecipTo(const aRecipTo: String): TBackEndRequestBuilder;
    function SetRecipCc(const aRecipCc: String): TBackEndRequestBuilder;
    function SetRecipBcc(const aRecipBcc: String): TBackEndRequestBuilder;
    function SetAttach(const aAttach: String): TBackEndRequestBuilder;
    function SetSubject(const aSubject: String): TBackEndRequestBuilder;
    function Build(): TBackEndRequest;
    constructor Create();
  end;

implementation

{ TSenderInputDataBuilder }

function TBackEndRequestBuilder.Build: TBackEndRequest;
begin
  Result := TBackEndRequest.Create(FFrom, Fsender, Fserver,
    FPort, FUseAuth, FUser, FPassword, FUseSSL, FMsgType, FBody, FSubject,
    FRecipTo, FRecipCc, FRecipBcc, FAttach);
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
  FMsgType := TMsgTypes.text;
  FBody := '';
  FRecipTo := '';
  FRecipCc := '';
  FRecipBcc := '';
  FAttach := '';

end;

function TBackEndRequestBuilder.SetAttach(
  const aAttach: String): TBackEndRequestBuilder;
var
  item: String;
begin
  FAttach := aAttach;
  Result := Self;
end;

function TBackEndRequestBuilder.SetAuthentification(const aLogin,
  aPassword: String): TBackEndRequestBuilder;
begin
  FUseAuth := True;
  FUser := aLogin;
  FPassword := aPassword;
end;

function TBackEndRequestBuilder.SetBody(
  const aBody: String): TBackEndRequestBuilder;
begin
  FBody := aBody;
  Result := Self;
end;

function TBackEndRequestBuilder.SetFrom(
  const aFrom: String): TBackEndRequestBuilder;
begin
  FFrom := aFrom;
  Result := Self;
end;

function TBackEndRequestBuilder.SetMsgType(
  const aMsgType: TMsgTypes): TBackEndRequestBuilder;
begin
  FMsgType := aMsgType;
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

constructor TBackEndRequest.Create(const aFrom, aSender, aServer: String;
  const aPort: Integer; const aUseAuth: Boolean; const aUser, aPassword: String;
  const aUseSSL: Boolean; const aMsgType: TMsgTypes; const aBody, aSubject: String;
  const aRecipTo, aRecipCc, aRecipBcc, aAttach: String);
begin
  FFrom := aFrom;
  FSender := aSender;
  FServer := aServer;
  FPort := aPort;
  FUseAuth := aUseAuth;
  FUser := aUser;
  FPassword := aPassword;
  FUseSSL := aUseSSL;
  FMsgType := aMsgType;
  FBody := aBody;
  FSubject := aSubject;
  FRecipTo := aRecipTo;
  FRecipCc := aRecipCc;
  FRecipBcc := aRecipBcc;
  FAttach := aAttach;
end;

end.
