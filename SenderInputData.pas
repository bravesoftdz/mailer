unit SenderInputData;

interface

uses
  System.Classes;

type
  TMsgTypes = (text, html);

type

  { Information that the sender program requires }
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
    property Port: Integer read FPort;
    property UseAuth: Boolean read FUseAuth;
    property User: String read FUser;
    property Password: String read FPassword;
    property UseSSL: Boolean read FUseSSL;
    property MsgType: TMsgTypes read FMsgType;
    property Body: String read FBody;
    property RecipTo: TStringList read FRecipTo;
    property RecipCc: TStringList read FRecipCc;
    property RecipBcc: TStringList read FRecipBcc;
    property Attach: TStringList read FAttach;

  end;

type
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
    function SetUseAuth(const aUseAuth: Boolean): TSenderInputDataBuilder;
    function SetUser(const aUser: String): TSenderInputDataBuilder;
    function SetPassword(const aPassword: String): TSenderInputDataBuilder;
    function SetUseSSL(const aUseSSL: Boolean): TSenderInputDataBuilder;
    function SetMsgType(const aMsgType: TMsgTypes): TSenderInputDataBuilder;
    function SetBody(const aBody: String): TSenderInputDataBuilder;
    function SetRecipTo(const aRecipTo: TStringList): TSenderInputDataBuilder;
    function SetRecipCc(const aRecipCc: TStringList): TSenderInputDataBuilder;
    function SetRecipBcc(const aRecipBcc: TStringList): TSenderInputDataBuilder;
    function SetAttach(const aAttach: TStringList): TSenderInputDataBuilder;
    function Build(): TSenderInputData;
  end;

implementation

{ TSenderInputDataBuilder }

function TSenderInputDataBuilder.Build: TSenderInputData;
begin
  Result := TSenderInputData.Create(FFrom, Fsender, Fserver,
    FPort, FUseAuth, FUser, FPassword, FUseSSL, FMsgType, FBody,
    FRecipTo, FRecipCc, FRecipBcc, FAttach);
end;

function TSenderInputDataBuilder.SetAttach(
  const aAttach: TStringList): TSenderInputDataBuilder;
begin
  FAttach := aAttach;
  Result := Self;
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

function TSenderInputDataBuilder.SetPassword(
  const aPassword: String): TSenderInputDataBuilder;
begin
  FPassword := aPassword;
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

function TSenderInputDataBuilder.SetUseAuth(
  const aUseAuth: Boolean): TSenderInputDataBuilder;
begin
  FUseAuth := aUseAuth;
  Result := Self;

end;

function TSenderInputDataBuilder.SetUser(
  const aUser: String): TSenderInputDataBuilder;
begin
  FUser := aUser;
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
