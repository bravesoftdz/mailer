unit SendDataTemplate;

interface

uses
  System.JSON, ObjectsMappers,
  System.Classes, JsonableInterface, System.Generics.Collections, Attachment;

type

  /// <summary>
  /// A request that a Reception instance performs to a back-end server.
  ///  It is a depricated class in favour of DispatcherEntry
  /// </summary>
  [MapperJSONNaming(JSONNameLowerCase)]
  TSendDataTemplate = class(TInterfacedObject, Jsonable)
  strict private
  const
    TOKEN_HTML = 'bodyhtml';
    TOKEN_TEXT = 'bodytext';
    TOKEN_ATTACH = 'attach';
    TOKEN_TOKEN = 'token';
    TOKEN_SUBJECT = 'subject';
    TOKEN_RECIPTO = 'recipto';
    TOKEN_RECIPBCC = 'recipbcc';
    TOKEN_RECIPCC = 'recipcc';

  var
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
    property from: String read FFrom write FFrom;
    /// <summary>  sender name, i.e: "Google Support Team" </summary>
    property sender: String read FSender write FSender;
    /// <summary>  Mail server, i.e. "10.341.32.21", "goo.mailer.com"  </summary>
    property server: String read FServer write FServer;
    /// <summary> port number, i.e. 25  </summary>
    property port: Integer read FPort write FPort;
    /// <summary> whether the user authentification is required  </summary>
    property useauth: Boolean read FUseAuth write FUseAuth;
    /// <summary> user name in case the authentification is required </summary>
    property user: String read FUser write FUser;
    /// <summary> the password in case the authentification is required </summary>
    property password: String read FPassword write FPassword;
    /// <summary> whether to use SSL </summary>
    property usessl: Boolean read FUseSSL write FUseSSL;
    /// <summary> html text version of the message to send </summary>
    [MapperJSONSer(TOKEN_HTML)]
    property html: String read FHtml write FHtml;
    /// <summary> plain text version of the message to send </summary>
    [MapperJSONSer(TOKEN_TEXT)]
    property text: String read FText write FText;
    /// <summary> email subject, i.e. "News for you" </summary>
    [MapperJSONSer(TOKEN_SUBJECT)]
    property subject: String read FSubject write FSubject;
    /// <summary> list of email addresses of the recipients (to) </summary>
    [MapperJSONSer(TOKEN_RECIPTO)]
    property recipto: String read FRecipTo write FRecipTo;
    /// <summary> list of email addresses of the recipients (cc) </summary>
    [MapperJSONSer(TOKEN_RECIPCC)]
    property recipcc: String read FRecipCc write FRecipCc;
    /// <summary> list of email addresses of the recipients (bcc) </summary>
    [MapperJSONSer(TOKEN_RECIPBCC)]
    property recipbcc: String read FRecipBcc write FRecipBcc;
    /// <summary> list of attachment contents </summary>
    [MapperJSONSer(TOKEN_ATTACH)]
    property attachment: TObjectList<TAttachment> read FAttach write FAttach;
    [MapperJSONSer(TOKEN_TOKEN)]
    property token: String read FToken write FToken;

    /// <summary> Multi argument constructor. It is recommended to use
    /// the TBackEndRequestBuilder. </summary>
    constructor Create(const AFrom: string; const ASender: string; const AServer: string; const APort: Integer; const AUseAuth: Boolean; const aUser: string;
      const APassword: string; const AUseSSL: Boolean; const AnHtml: string; const AText: string; const ASubject: string; const ARecipTo: string; const aRecipCc: string;
      const ARecipBcc: string; const Attachments: TObjectList<TAttachment>; const AToken: String); overload;
    /// <summary> No argument constructor. It is needed for serialization.</summary>
    constructor Create(); overload;

    destructor Destroy(); override;

    function ToJson(): TJsonObject;

  end;

type
  { Builder for a type that collects input data for a program that sends emails }
  TSendDataTemplateBuilder = class(TObject)
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
    function SetFrom(const AFrom: String): TSendDataTemplateBuilder;
    function SetSender(const ASender: String): TSendDataTemplateBuilder;
    function SetServer(const AServer: String): TSendDataTemplateBuilder;
    function SetPort(const APort: Integer): TSendDataTemplateBuilder;
    function SetAuthentification(const ALogin, APassword: String): TSendDataTemplateBuilder;
    function SetUseSSL(const AUseSSL: Boolean): TSendDataTemplateBuilder;
    function SetText(const AText: String): TSendDataTemplateBuilder;
    function SetHtml(const AHtml: String): TSendDataTemplateBuilder;
    function SetRecipTo(const ARecipTo: String): TSendDataTemplateBuilder;
    function SetRecipCc(const ARecipCc: String): TSendDataTemplateBuilder;
    function SetRecipBcc(const ARecipBcc: String): TSendDataTemplateBuilder;
    function addAttach(const AnAttach: TAttachment): TSendDataTemplateBuilder;
    function addAttachments(const Items: TObjectList<TAttachment>): TSendDataTemplateBuilder;
    function SetSubject(const ASubject: String): TSendDataTemplateBuilder;
    function setToken(const AToken: String): TSendDataTemplateBuilder;
    function Build(): TSendDataTemplate;
    constructor Create();
    destructor Destroy(); override;
  end;

type
  TReceptionRequests = class(TObject)
  strict private
  var
    FItems: TObjectList<TSendDataTemplate>;

  public
    constructor Create;
    destructor Destroy; override;
    procedure SetItems(Items: TObjectList<TSendDataTemplate>);

    [MapperListOf(TSendDataTemplate)]
    property Items: TObjectList<TSendDataTemplate> read FItems write SetItems;

  end;

implementation

uses
  System.SysUtils;


function TSendDataTemplateBuilder.addAttachments(
  const Items: TObjectList<TAttachment>): TSendDataTemplateBuilder;
var
  Item: TAttachment;
begin
  for Item in Items do
    addAttach(Item);
  Result := Self;
end;

function TSendDataTemplateBuilder.Build: TSendDataTemplate;
begin
  Result := TSendDataTemplate.Create(FFrom, Fsender, Fserver, FPort, FUseAuth,
    FUser, FPassword, FUseSSL, FHtml, FText, FSubject, FRecipTo,
    FRecipCc, FRecipBcc, FAttach, FToken);
end;

constructor TSendDataTemplateBuilder.Create;
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

destructor TSendDataTemplateBuilder.Destroy;
begin
  FAttach.Clear;
  FAttach.DisposeOf;
  inherited;
end;

function TSendDataTemplateBuilder.addAttach(const AnAttach: TAttachment): TSendDataTemplateBuilder;
begin
  FAttach.Add(TAttachment.Create(AnAttach.Name, AnAttach.Content));
  Result := Self;
end;

function TSendDataTemplateBuilder.SetAuthentification(const ALogin,
  APassword: String): TSendDataTemplateBuilder;
begin
  FUseAuth := True;
  FUser := ALogin;
  FPassword := APassword;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetText(
  const AText: String): TSendDataTemplateBuilder;
begin
  FText := AText;
  Result := Self;
end;

function TSendDataTemplateBuilder.setToken(
  const AToken: String): TSendDataTemplateBuilder;
begin
  FToken := AToken;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetFrom(
  const AFrom: String): TSendDataTemplateBuilder;
begin
  FFrom := AFrom;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetHtml(
  const AHtml: String): TSendDataTemplateBuilder;
begin
  FHtml := AHtml;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetPort(
  const APort: Integer): TSendDataTemplateBuilder;
begin
  FPort := APort;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetRecipBcc(
  const ARecipBcc: String): TSendDataTemplateBuilder;
begin
  FRecipBcc := ARecipBcc;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetRecipCc(
  const ARecipCc: String): TSendDataTemplateBuilder;
begin
  FRecipCc := ARecipCc;
  Result := Self;

end;

function TSendDataTemplateBuilder.SetRecipTo(
  const ARecipTo: String): TSendDataTemplateBuilder;
begin
  FRecipTo := ARecipTo;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetSender(
  const ASender: String): TSendDataTemplateBuilder;
begin
  FSender := ASender;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetServer(
  const AServer: String): TSendDataTemplateBuilder;
begin
  FServer := AServer;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetSubject(
  const ASubject: String): TSendDataTemplateBuilder;
begin
  FSubject := ASubject;
  Result := Self;
end;

function TSendDataTemplateBuilder.SetUseSSL(
  const AUseSSL: Boolean): TSendDataTemplateBuilder;
begin
  FUseSSL := AUseSSL;
  Result := Self;
end;

{ TSenderInputData }

constructor TSendDataTemplate.Create(const AFrom: string; const ASender: string;
  const AServer: string; const APort: Integer; const AUseAuth: Boolean;
  const aUser: string; const APassword: string; const AUseSSL: Boolean;
  const AnHtml: string; const AText: string; const ASubject: string;
  const ARecipTo: string; const aRecipCc: string;
  const ARecipBcc: string; const Attachments: TObjectList<TAttachment>; const AToken: String);
var
  anAttachment: TAttachment;
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
  FToken := AToken;
  /// create a copy. Don't forget to free it!
  FAttach := TObjectList<TAttachment>.Create();
  for anAttachment in Attachments do
    FAttach.Add(TAttachment.Create(anAttachment.Name, anAttachment.Content));

end;

constructor TSendDataTemplate.Create;
begin
  FAttach := TObjectList<TAttachment>.Create;
end;

destructor TSendDataTemplate.Destroy;
begin
  FAttach.Clear;
  FAttach.DisposeOf;
  inherited;
end;

function TSendDataTemplate.ToJson: TJsonObject;
begin
  Result := TJsonObject.Create();
  // Result.AddPair(TJsonPair.Create(TOKEN_HTML, FHtml));
  // Result.AddPair(TJsonPair.Create(TOKEN_TEXT, FText));
  { TODO: to finish }
end;

{ TReceptionRequests }

constructor TReceptionRequests.Create;
begin
  FItems := TObjectList<TSendDataTemplate>.Create();
end;

destructor TReceptionRequests.Destroy;
begin
  FItems.Clear;
  inherited;
end;

procedure TReceptionRequests.SetItems(Items: TObjectList<TSendDataTemplate>);
begin
  FItems.Clear;
  FItems := Items;
end;

end.
