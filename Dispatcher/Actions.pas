unit Actions;

interface

uses
  Responce, FrontEndRequest, SendDataTemplate, ActiveQueueSettings, Attachment,
  ClientFullRequest, DispatcherEntry, System.Generics.Collections, ActiveQueueEntry;

// type
// TActionCategories = (email = 'email', Diamonds, Clubs, Spades);

type
  TAction = class(TObject)
  private
    function GetCategory: String;
  protected
    FCategory: String;
  public
    /// <summary>Category to which this action belons. Many actions may belong to the same
    /// category. </summary>
    property Category: String read GetCategory;

    /// <summary> Constructor. The argument is a category of the action. Many action may have the same
    /// category. It means that various actions can correspond to a given request. </summary>
    /// <param name="Category">Category to which the action belongs.</param>
    constructor Create(const Category: String);

    /// <summary>A virtual method that is supposed to be overwritten in classes
    /// that inherit from this one.</summary>
    /// <returns>return an instance for further elaboration by the ActiveQueue server</returns>
    function MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry; virtual; abstract;

    /// <summary>Create a clone of this instance. It is supposed to be implemented in classes
    /// that inherit from this one. In the implementation, the return type must be of the
    /// inheriting class and not of the parent one.</summary>
    function Clone(): TAction; virtual; abstract;
  end;

type
  TActionSend = class(TAction)
  public
    constructor Create();
    function MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry; override;
    function Clone(): TAction; override;
  end;

type
  TActionContact = class(TAction)
  public
    constructor Create();
    function MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry; override;
    function Clone(): TAction; override;
  end;

type
  TActionOrder = class(TAction)
  public
    constructor Create();
    function MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry; override;
    function Clone(): TAction; override;
  end;

type
  TOMNSendToClient = class(TAction)
  public
    constructor Create();
    function MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry; override;
    function Clone(): TAction; override;
  end;

type
  TOMNSendToCodicione = class(TAction)
  public
    constructor Create();
    function MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry; override;
    function Clone(): TAction; override;
  end;

implementation

uses
  SenderCredentials, System.JSON, MVCFramework.RESTAdapter, ActiveQueueResponce, System.SysUtils;

{ TMailerAction }

constructor TAction.Create(const Category: String);
begin
  FCategory := Category;
end;

function TAction.GetCategory: String;
begin
  Result := FCategory;
end;

function TActionSend.Clone: TAction;
begin
  Result := TActionSend.Create();
end;

constructor TActionSend.Create;
begin
  inherited Create('send')
end;

function TActionSend.MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry;
var
  builder: TSendDataTemplateBuilder;
  // adapter: TRestAdapter<ISendServerProxy>;
  // server: ISendServerProxy;
  Responce: TActiveQueueResponce;
  Request: TSendDataTemplate;
begin
  // Writeln('ActionSend starts...');
  // builder := TSenderDataTemplateBuilder.Create();
  // builder.SetFrom(TVenditoriCredentials.From())
  // .SetSender(TVenditoriCredentials.Name())
  // .SetSubject(TVenditoriCredentials.Subject())
  // .SetPort(TVenditoriCredentials.Port)
  // .setServer(TVenditoriCredentials.Server())
  // .SetRecipTo(TVenditoriCredentials.Recipients)
  // .addAttachments(Entry.Attachments);
  //
  // if (Data <> nil) then
  // begin
  // builder.SetText(Data.Text);
  // builder.SetHtml(Data.Html);
  // end;
  //
  // Request := builder.build;
  // Builder.DisposeOf;
  // Adapter := TRestAdapter<ISendServerProxy>.Create();
  // Server := Adapter.Build(Settings.Url, Settings.Port);
  // if (Server = nil) then
  // begin
  // Result := TResponce.Create(False, 'Backend server is not running');
  // end
  // else
  // begin
  // try
  // Responce := server.PostItem(Request);
  // Result := TResponce.Create(Responce.status, Responce.Msg);
  // except
  // on E: Exception do
  // begin
  // Result := TResponce.Create(False, E.Message);
  // end;
  // end;
  // end;
  // Server := nil;
  // Adapter := nil;
end;

{ TActionContact }

function TActionContact.Clone: TAction;
begin
  Result := TActionContact.Create();
end;

constructor TActionContact.Create;
begin
  inherited Create('contact');
end;

function TActionContact.MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry;
begin

end;

{ TActionOrder }

function TActionOrder.Clone: TAction;
begin
  Result := TActionOrder.Create();
end;

constructor TActionOrder.Create;
begin
  inherited Create('order');
end;

function TActionOrder.MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry;
begin
  Result := TActiveQueueEntry.Create();
end;

{ TOMNSendToClient }

function TOMNSendToClient.Clone: TAction;
begin
  Result := TOMNSendToClient.Create();
end;

constructor TOMNSendToClient.Create;
begin
  inherited Create('register');
end;

function TOMNSendToClient.MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry;
const
  EMAIL_TOKEN = 'email';
var
  jo1, jo2: TJsonObject;
  v: TJsonValue;
  builder: TSendDataTemplateBuilder;
  data: TSendDataTemplate;
  Emails: String;

begin
  try
    jo2 := TJSONObject.ParseJSONValue(Content) as TJsonObject;
  except
    on E: Exception do
    begin
      raise Exception.Create('A valid stringy version of json is expected.');
    end;
  end;
  v := jo2.GetValue(EMAIL_TOKEN);
  if v = nil then
  begin
    jo2.DisposeOf;
    raise Exception.Create('No key "' + EMAIL_TOKEN + '" is found.');
  end;
  Emails := v.Value;
  if Trim(Emails) = '' then
  begin
    jo2.DisposeOf;
    raise Exception.Create('Key "' + EMAIL_TOKEN + '" is blank or empty.');
  end;

  builder := TSendDataTemplateBuilder.Create();
  builder.SetFrom(TONMCredentials.From)
    .SetSender(TONMCredentials.Name)
    .SetSubject(TONMCredentials.Subject)
    .SetPort(TONMCredentials.Port)
    .setServer(TONMCredentials.Server)
    .SetRecipTo(Emails)
    .addAttachments(Attachments);
  Data := builder.Build;
  jo1 := data.ToJson;
  Result := TActiveQueueEntry.Create('omn-register', 'email', jo1.ToString, Token, Attachments);
  jo1.DisposeOf;
  Data.DisposeOf;
  Builder.DisposeOf;

end;

{ TOMNSendToCodicione }

function TOMNSendToCodicione.Clone: TAction;
begin
  Result := TOMNSendToCodicione.Create();
end;

constructor TOMNSendToCodicione.Create;
begin
  inherited Create('register');
end;

function TOMNSendToCodicione.MapToBackEndEntry(const Content: String; const Attachments: TObjectList<TAttachment>; const Token: String): TActiveQueueEntry;
begin
  // Writeln('ActionSend starts...');
  // builder := TSenderDataTemplateBuilder.Create();
  // builder.SetFrom(TVenditoriCredentials.From())
  // .SetSender(TVenditoriCredentials.Name())
  // .SetSubject(TVenditoriCredentials.Subject())
  // .SetPort(TVenditoriCredentials.Port)
  // .setServer(TVenditoriCredentials.Server())
  // .SetRecipTo(TVenditoriCredentials.Recipients)
  // .addAttachments(Entry.Attachments);
  //
  // if (Data <> nil) then
  // begin
  // builder.SetText(Data.Text);
  // builder.SetHtml(Data.Html);
  // end;
  //
  // Request := builder.build;
  // Builder.DisposeOf;
  // Adapter := TRestAdapter<ISendServerProxy>.Create();
  // Server := Adapter.Build(Settings.Url, Settings.Port);
  // if (Server = nil) then
  // begin
  // Result := TResponce.Create(False, 'Backend server is not running');
  // end
  // else
  // begin
  // try
  // Responce := server.PostItem(Request);
  // Result := TResponce.Create(Responce.status, Responce.Msg);
  // except
  // on E: Exception do
  // begin
  // Result := TResponce.Create(False, E.Message);
  // end;
  // end;
  // end;
  // Server := nil;
  // Adapter := nil;

end;

end.
