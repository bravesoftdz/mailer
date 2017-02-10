unit OutputData;

interface

uses
  System.Classes;

type
  TMsgTypes = (text, html);

type

  { Input data for a program that sends emails }
  [MapperJSONNaming(JSONNameLowerCase)]
  TOutputData = class
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
  TOutputDataBuilder = class
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
    function SetFrom(const aFrom: String): TOutputDataBuilder;
    function SetSender(const aSender: String): TOutputDataBuilder;
    function SetServer(const aServer: String): TOutputDataBuilder;
    function SetPort(const aPort: Integer): TOutputDataBuilder;
    function SetAuthentification(const aLogin, aPassword: String): TOutputDataBuilder;
    function SetUseSSL(const aUseSSL: Boolean): TOutputDataBuilder;
    function SetMsgType(const aMsgType: TMsgTypes): TOutputDataBuilder;
    function SetBody(const aBody: String): TOutputDataBuilder;
    function SetRecipTo(const aRecipTo: TStringList): TOutputDataBuilder;
    function SetRecipCc(const aRecipCc: TStringList): TOutputDataBuilder;
    function SetRecipBcc(const aRecipBcc: TStringList): TOutputDataBuilder;
    function SetAttach(const aAttach: TStringList): TOutputDataBuilder;
    function Build(): TOutputData;
    constructor Create();
  end;

implementation

{ TSenderInputDataBuilder }

function TOutputDataBuilder.Build: TOutputData;
begin
  Result := TOutputData.Create(FFrom, Fsender, Fserver,
    FPort, FUseAuth, FUser, FPassword, FUseSSL, FMsgType, FBody,
    FRecipTo, FRecipCc, FRecipBcc, FAttach);
end;

constructor TOutputDataBuilder.Create;
begin
  FUseAuth := False;
end;

function TOutputDataBuilder.SetAttach(
  const aAttach: TStringList): TOutputDataBuilder;
begin
  FAttach := aAttach;
  Result := Self;
end;

function TOutputDataBuilder.SetAuthentification(const aLogin,
  aPassword: String): TOutputDataBuilder;
begin
  FUseAuth := True;
  FUser := aLogin;
  FPassword := aPassword;
end;

function TOutputDataBuilder.SetBody(
  const aBody: String): TOutputDataBuilder;
begin
  FBody := aBody;
  Result := Self;
end;

function TOutputDataBuilder.SetFrom(
  const aFrom: String): TOutputDataBuilder;
begin
  FFrom := aFrom;
  Result := Self;
end;

function TOutputDataBuilder.SetMsgType(
  const aMsgType: TMsgTypes): TOutputDataBuilder;
begin
  FMsgType := aMsgType;
  Result := Self;
end;

function TOutputDataBuilder.SetPort(
  const aPort: Integer): TOutputDataBuilder;
begin
  FPort := aPort;
  Result := Self;
end;

function TOutputDataBuilder.SetRecipBcc(
  const aRecipBcc: TStringList): TOutputDataBuilder;
begin
  FRecipBcc := aRecipBcc;
  Result := Self;
end;

function TOutputDataBuilder.SetRecipCc(
  const aRecipCc: TStringList): TOutputDataBuilder;
begin
  FRecipCc := aRecipCc;
  Result := Self;

end;

function TOutputDataBuilder.SetRecipTo(
  const aRecipTo: TStringList): TOutputDataBuilder;
begin
  FRecipTo := aRecipTo;
  Result := Self;
end;

function TOutputDataBuilder.SetSender(
  const aSender: String): TOutputDataBuilder;
begin
  FSender := aSender;
  Result := Self;
end;

function TOutputDataBuilder.SetServer(
  const aServer: String): TOutputDataBuilder;
begin
  FServer := aServer;
  Result := Self;
end;

function TOutputDataBuilder.SetUseSSL(
  const aUseSSL: Boolean): TOutputDataBuilder;
begin
  FUseSSL := aUseSSL;
  Result := Self;
end;

{ TSenderInputData }

constructor TOutputData.Create(const aFrom, aSender, aServer: String;
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
