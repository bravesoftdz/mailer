unit Action;

interface

uses
  SimpleMailerResponce, SimpleInputData, OutputData, REST.JSON;

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
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; virtual; abstract;
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
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
  end;

type
  TActionContact = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
  end;

type
  TActionOrder = class(TAction)
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; override;
    constructor Create();
  end;

implementation

uses
  Credentials, System.JSON, MVCFramework.RESTAdapter,
  SendServerProxy.interfaces;

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
  const Data: TSimpleInputData): TSimpleMailerResponce;
var
  builder: TOutputDataBuilder;
  adapter: TRestAdapter<ISendServerProxy>;
  server: ISendServerProxy;
  dataTmp: TJSONObject;
  output: TJSONObject;
begin
  Result := TSimpleMailerResponce.Create;
  builder := TOutputDataBuilder.Create();
  // builder.SetFrom(TVenditoriCredentials.From())
  // .SetSender(TVenditoriCredentials.Name())
  // .SetBody(Data.Data.GetValue('text').Value)
  // .SetRecipTo(TVenditoriCredentials.Recipients);

  adapter := TRestAdapter<ISendServerProxy>.Create();
  server := adapter.Build('http://192.168.5.226', 8080);
  dataTmp := TJSonObject.Create;
  output := server.send(nil);
  Result.message := 'result ' + output.ToString;
end;

{ TActionContact }

constructor TActionContact.Create;
begin
  inherited Create('contact');
end;

function TActionContact.Elaborate(
  const
  Data:
  TSimpleInputData): TSimpleMailerResponce;
begin
  /// stub
  Result := TSimpleMailerResponce.Create;
  Result.message := 'contact action: not implemented yet';

end;

{ TActionOrder }

constructor TActionOrder.Create;
begin
  inherited Create('order');
end;

function TActionOrder.Elaborate(
  const
  Data:
  TSimpleInputData): TSimpleMailerResponce;
begin
  /// stub
  Result := TSimpleMailerResponce.Create;
  Result.message := 'contact action: not implemented yet';
end;

end.
