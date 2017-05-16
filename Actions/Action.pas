unit Action;

interface

uses
  ReceptionResponce, FrontEndRequest, ReceptionRequest, ActiveQueueSettings;

type
  TAction = class
  private
    function GetName: String;
  protected
    FName: String;
  public
    /// <summary>A virtual method that i ssupposed to be overwritten in classes
    /// that inherit from this one.</summary>
    /// <returns>a responce as a TSimpleMailerResponce instance</returns>
    function Elaborate(const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce; virtual; abstract;
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
    function Elaborate(const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce; override;
    constructor Create();
  end;

type
  TActionContact = class(TAction)
  public
    function Elaborate(const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce; override;
    constructor Create();
  end;

type
  TActionOrder = class(TAction)
  public
    function Elaborate(const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce; override;
    constructor Create();
  end;

implementation

uses
  Credentials, System.JSON, MVCFramework.RESTAdapter, ActiveQueueResponce,
  SendServerProxy.interfaces, System.SysUtils, Attachment;

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

function TActionSend.Elaborate(
  const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce;
var
  builder: TReceptionRequestBuilder;
  adapter: TRestAdapter<ISendServerProxy>;
  server: ISendServerProxy;
  Responce: TActiveQueueResponce;
  Request: TReceptionRequest;
begin
  Result := TReceptionResponce.Create;
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
    builder.SetText(Data.Data.Text);
    builder.SetHtml(Data.Data.Html);
  end;

  Request := builder.build;
  adapter := TRestAdapter<ISendServerProxy>.Create();
  server := adapter.Build(Settings.Url, Settings.Port);
  if (Server = nil) then
  begin
    Result.msg := 'Backend server is not running';
  end
  else
  begin
    try
      Responce := server.send(Request);
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

end;

{ TActionContact }

constructor TActionContact.Create;
begin
  inherited Create('contact');
end;

function TActionContact.Elaborate(const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce;
begin
  /// stub
  Result := TReceptionResponce.Create;
  Result.msg := 'contact action: not implemented yet';

end;

{ TActionOrder }

constructor TActionOrder.Create;
begin
  inherited Create('order');
end;

function TActionOrder.Elaborate(const Data: TFrontEndRequest; const Settings: TActiveQueueSettings): TReceptionResponce;
begin
  /// stub
  Result := TReceptionResponce.Create;
  Result.msg := 'contact action: not implemented yet';
end;

end.
