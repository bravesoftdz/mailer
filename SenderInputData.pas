unit SenderInputData;

interface

type
  TMsgTypes = (text, html);

type

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
    FRecipTo: array of String;
    FRecipCc: array of String;
    FRecipBcc: array of String;
    FAttach: array of String;
    constructor Create(const From, Sender, Server: String; const Port: Integer;
      const FUseAuth: Boolean;
      const FUser, FPassword: String;
      const FUseSSL: Boolean;
      const FMsgType: TMsgTypes;
      const FBody: String;
      const FRecipTo, FRecipCc, FRecipBcc, FAttach: array of String
      );
  public
    property From: String read FFrom;
    property Sender: String read FSender;
    property Server: String read FServer;
    property Port: Integer read FPort;
    property UseAuth: Boolean read FUseAuth;
    property User: String read FUser;
    property Password: String read FPassword;
    property UseSSL: Boolean read FUseSSL;
    property MsgType: TMsgTypes read FMsgType;
    property Body: String read FBody;
    property RecipTo: array of String read FRecipTo;
    property RecipCc: array of String read FRecipCc;
    property RecipBcc: array of String read FRecipBcc;
    property Attach: array of String read FAttach;
  end;

implementation

end.
