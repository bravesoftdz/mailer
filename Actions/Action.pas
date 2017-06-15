unit Action;

interface

uses
  Responce, FrontEndRequest, ReceptionRequest, ActiveQueueSettings,
  ClientFullRequest;

type
  TAction = class
  private
    function GetName: String;
  protected
    FName: String;
  public
    /// <summary>A virtual method that is supposed to be overwritten in classes
    /// that inherit from this one.</summary>
    /// <returns>a responce as a TSimpleMailerResponce instance</returns>
    function Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce; virtual; abstract;
    /// <summary>A name of the operation that this action performs.
    /// The operation name is used in order to find an action that is able
    /// to do a requested operation.
    /// </summary>
    property Name: String read GetName;
    /// <summary> Constructor.</summary>
    /// <param name="Name">a name to be given to the operation</param>
    constructor Create(const Name: String);
  end;

type
  TActionSend = class(TAction)
  public
    function Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce; override;
    constructor Create();
  end;

type
  TActionContact = class(TAction)
  public
    function Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce; override;
    constructor Create();
  end;

type
  TActionOrder = class(TAction)
  public
    function Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce; override;
    constructor Create();
  end;

implementation

uses
  Credentials, System.JSON, MVCFramework.RESTAdapter, ActiveQueueResponce,
  SendServerProxy.interfaces, System.SysUtils, Attachment,
  System.Generics.Collections;

{ TMailerAction }

constructor TAction.Create(const Name: String);
begin
  FName := Name;
end;

function TAction.GetName: String;
begin
  Result := FName;
end;

constructor TActionSend.Create;
begin
  inherited Create('send')
end;

function TActionSend.Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce;

var
  builder: TReceptionRequestBuilder;
  adapter: TRestAdapter<ISendServerProxy>;
  server: ISendServerProxy;
  Responce: TActiveQueueResponce;
  Request: TReceptionRequest;
  Items: TObjectList<TReceptionRequest>;
begin
  Writeln('ActionSend starts...');
  Result := TResponce.Create;
  builder := TReceptionRequestBuilder.Create();
  builder.SetFrom(TVenditoriCredentials.From())
    .SetSender(TVenditoriCredentials.Name())
    .SetSubject(TVenditoriCredentials.Subject())
    .SetPort(TVenditoriCredentials.Port)
    .setServer(TVenditoriCredentials.Server())
    .SetRecipTo(TVenditoriCredentials.Recipients)
    .addAttachments(Data.Attachments);

  if (Data <> nil) then
  begin
    builder.SetText(Data.Text);
    builder.SetHtml(Data.Html);
  end;

  Request := builder.build;
  Adapter := TRestAdapter<ISendServerProxy>.Create();
  Server := Adapter.Build(Settings.Url, Settings.Port);
  if (Server = nil) then
  begin
    Result.msg := 'Backend server is not running';
  end
  else
  begin
    try
      Responce := server.PostItem(Request);
      if Responce.status then
        Result.msg := 'OK'
      else
        Result.msg := Responce.Msg;
    except
      on E: Exception do
      begin
        Result.msg := E.Message;
      end;
    end;
  end;
  Server := nil;
  Adapter := nil;
end;

{ TActionContact }

constructor TActionContact.Create;
begin
  inherited Create('contact');
end;

function TActionContact.Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce;
begin
  /// stub
  Result := TResponce.Create;
  Result.msg := 'contact action: not implemented yet';

end;

{ TActionOrder }

constructor TActionOrder.Create;
begin
  inherited Create('order');
end;

function TActionOrder.Elaborate(const Data: TClientFullRequest; const Settings: TActiveQueueSettings): TResponce;
begin
  /// stub
  Result := TResponce.Create;
  Result.msg := 'contact action: not implemented yet';
end;

end.
