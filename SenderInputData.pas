unit SenderInputData;

interface

uses
  System.Classes;

type
  TMsgTypes = (text, html);

type

  { Input data for a program that sends emails }
  [MapperJSONNaming(JSONNameLowerCase)]
  TSenderInputData = class
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
    FRecipTo: TStringList;
    FRecipCc: TStringList;
    FRecipBcc: TStringList;
    FAttach: TStringList;
    { Make the constructor private in order to discourage its usage in favour of
      the TSenderInputDataBuilder }
    constructor Create(const aFrom, aSender, aServer: String; const aPort: Integer;
      const aUseAuth: Boolean;
      const aUser, aPassword: String;
      const aUseSSL: Boolean;
      const aMsgType: TMsgTypes;
      const aBody: String;
      const aRecipTo, aRecipCc, aRecipBcc, aAttach: TStringList
      );

  public
    // sender email, i.e: support@google.com
    property From: String read FFrom;
    // sender name, i.e: "Google Support Team"
    property Sender: String read FSender;
    // Mail server, i.e. "10.341.32.21", "goo.mailer.com"
    property Server: String read FServer;
    // port number, i.e. 25
    property Port: Integer read FPort;
    // whether the user authentification is required
    property UseAuth: Boolean read FUseAuth;
    // user name in case the authentification is required
    property User: String read FUser;
    // the password in case the authentification is required
    property Password: String read FPassword;
    // whether to use SSL
    property UseSSL: Boolean read FUseSSL;
    // type of the message to send: there are two different options for sending
    // emails: a plain text and an html
    property MsgType: TMsgTypes read FMsgType;
    // email content
    property Body: String read FBody;
    // list of email addresses of the recipients (to)
    property RecipTo: TStringList read FRecipTo;
    // list of email addresses of the recipients (cc)
    property RecipCc: TStringList read FRecipCc;
    // list of email addresses of the recipients (bcc)
    property RecipBcc: TStringList read FRecipBcc;
    // list of attachment contents
    property Attach: TStringList read FAttach;

  end;

type
  { Builder for a type that collects input data for a program that sends emails }
  TSenderInputDataBuilder = class
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
    FRecipTo: TStringList;
    FRecipCc: TStringList;
    FRecipBcc: TStringList;
    FAttach: TStringList;
  public
    function SetFrom(const aFrom: String): TSenderInputDataBuilder;
    function SetSender(const aSender: String): TSenderInputDataBuilder;
    function SetServer(const aServer: String): TSenderInputDataBuilder;
    function SetPort(const aPort: Integer): TSenderInputDataBuilder;
    function SetAuthentification(const aLogin, aPassword: String): TSenderInputDataBuilder;
    function SetUseSSL(const aUseSSL: Boolean): TSenderInputDataBuilder;
    function SetMsgType(const aMsgType: TMsgTypes): TSenderInputDataBuilder;
    function SetBody(const aBody: String): TSenderInputDataBuilder;
    function SetRecipTo(const aRecipTo: TStringList): TSenderInputDataBuilder;
    function SetRecipCc(const aRecipCc: TStringList): TSenderInputDataBuilder;
    function SetRecipBcc(const aRecipBcc: TStringList): TSenderInputDataBuilder;
    function SetAttach(const aAttach: TStringList): TSenderInputDataBuilder;
    function Build(): TSenderInputData;
    constructor Create();
  end;

implementation

{ TSenderInputDataBuilder }

function TSenderInputDataBuilder.Build: TSenderInputData;
begin
  Result := TSenderInputData.Create(FFrom, Fsender, Fserver,
    FPort, FUseAuth, FUser, FPassword, FUseSSL, FMsgType, FBody,
    FRecipTo, FRecipCc, FRecipBcc, FAttach);
end;

constructor TSenderInputDataBuilder.Create;
begin
  FUseAuth := False;
end;

function TSenderInputDataBuilder.SetAttach(
  const aAttach: TStringList): TSenderInputDataBuilder;
begin
  FAttach := aAttach;
  Result := Self;
end;

function TSenderInputDataBuilder.SetAuthentification(const aLogin,
  aPassword: String): TSenderInputDataBuilder;
begin
  FUseAuth := True;
  FUser := aLogin;
  FPassword := aPassword;
end;

function TSenderInputDataBuilder.SetBody(
  const aBody: String): TSenderInputDataBuilder;
begin
  FBody := aBody;
  Result := Self;
end;

function TSenderInputDataBuilder.SetFrom(
  const aFrom: String): TSenderInputDataBuilder;
begin
  FFrom := aFrom;
  Result := Self;
end;

function TSenderInputDataBuilder.SetMsgType(
  const aMsgType: TMsgTypes): TSenderInputDataBuilder;
begin
  FMsgType := aMsgType;
  Result := Self;
end;

function TSenderInputDataBuilder.SetPort(
  const aPort: Integer): TSenderInputDataBuilder;
begin
  FPort := aPort;
  Result := Self;
end;

function TSenderInputDataBuilder.SetRecipBcc(
  const aRecipBcc: TStringList): TSenderInputDataBuilder;
begin
  FRecipBcc := aRecipBcc;
  Result := Self;
end;

function TSenderInputDataBuilder.SetRecipCc(
  const aRecipCc: TStringList): TSenderInputDataBuilder;
begin
  FRecipCc := aRecipCc;
  Result := Self;

end;

function TSenderInputDataBuilder.SetRecipTo(
  const aRecipTo: TStringList): TSenderInputDataBuilder;
begin
  FRecipTo := aRecipTo;
  Result := Self;
end;

function TSenderInputDataBuilder.SetSender(
  const aSender: String): TSenderInputDataBuilder;
begin
  FSender := aSender;
  Result := Self;
end;

function TSenderInputDataBuilder.SetServer(
  const aServer: String): TSenderInputDataBuilder;
begin
  FServer := aServer;
  Result := Self;
end;

function TSenderInputDataBuilder.SetUseSSL(
  const aUseSSL: Boolean): TSenderInputDataBuilder;
begin
  FUseSSL := aUseSSL;
  Result := Self;
end;

{ TSenderInputData }

constructor TSenderInputData.Create(const aFrom, aSender, aServer: String;
  const aPort: Integer; const aUseAuth: Boolean; const aUser, aPassword: String;
  const aUseSSL: Boolean; const aMsgType: TMsgTypes; const aBody: String;
  const aRecipTo, aRecipCc, aRecipBcc, aAttach: TStringList);
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
  FRecipTo := aRecipTo;
  FRecipCc := aRecipCc;
  FRecipBcc := aRecipBcc;
  FAttach := aAttach;
end;

end.
