unit ReceptionModel;

interface

uses
  Responce, ProviderFactory, FrontEndRequest, ActiveQueueSettings,
  Web.HTTPApp, Client, ClientFullRequest, Authentication,
  ReceptionConfig, System.Classes, DispatcherEntry, System.JSON, Attachment,
  System.Generics.Collections, DispatcherResponce;

type
  TReceptionModel = class(TObject)

  const
    /// name of the key that contains a token in a json
    TOKEN_KEY = 'token';
  strict private
    FFactory: TProviderFactory;
    FClients: TArray<TClient>;
    FSettings: TActiveQueueSettings;
    FAuthentication: TAuthentication;
    /// port number at which this server works
    FPort: Integer;

    /// <summary>client setter. Perform the defencieve copying.</summary>
    procedure SetClients(const clients: TObjectList<TClient>);
    /// <summary>return a copy of clients.</summary>
    function GetClients(): TObjectList<TClient>;

    /// <summary> Return true if the list of clients contains a one with given IP and token.
    /// Otherwise, return false.
    /// </summary>
    function isAuthenticated(const IP, Token: String): Boolean;
    procedure SetSettings(const Value: TActiveQueueSettings);

    procedure SetConfig(const Value: TReceptionConfig);
    function GetBackEndUrl: String;
    function GetBackEndPort: Integer;

    /// <summary>Return a first element from the array that has given content type and key name.
    /// If nothing is found, an empty string is returned.
    /// Example of the array elements (this is just a one element, it spans many lines):
    /// Content-Disposition: form-data; name="data"
    /// Content-Type: application/json
    /// { "html":"html version of the mail", "text":"text version of the mail", "token":"abcdef" }
    /// </summary>
    function PickMultipartItem(const Items: TArray<String>; const ContentType: String; const KeyName: String): String;

    /// <summary> Returns a copy of original list in which the elements at specified postions are skipped</summary>
    function SkipElements(const Items: TStringList; const positions: TList<Integer>): TStringList;

  public
    /// <summary>
    /// Elaborate an action from a client.</summary>
    /// <param name="Requestor">client name</param>
    /// <param name="anAction">an action name that the client requests to perform</param>
    /// <param name="IP">client IP</param>
    /// <param name="Request">request obtained from the client</param>
    function Elaborate(const Requestor: string; const anAction: string; const IP: String; const Token: String; const Request: TClientFullRequest): TResponce;

    /// <summary>Extract a value corresponding to a key in a set of key-value pairs. The pairs
    /// are separated by semicolon, while the key and value are separated by equality sign. A key is
    /// optional in the key-value pairs. Example:
    /// 'multipart/form-data;charset=UTF-8;boundary=--dsds'
    function GetParamValue(const Query: String; const Param: String): String;

    /// <summary>Extract body from a multipart request body</summary
    function ExtractBody(const Boundary, RawBody, ContentType, KeyName: String): String;

    function BuildBackEndEntry(const Origin: String; const Action: String; const data: TJSonObject; const Attachments: TObjectList<TAttachment>): TDispatcherEntry;

    /// <summary>Transforms a dispatcher responce into a reception one.<summary>
    function ConvertToOwnResponce(const BackEndResponce: TDispatcherResponce): TResponce;

    property clients: TObjectList<TClient> read GetClients write SetClients;

    property Config: TReceptionConfig write SetConfig;

    property BackEndUrl: String read GetBackEndUrl;

    property BackEndPort: Integer read GetBackEndPort;

    property Port: Integer read FPort;

    constructor Create();

    destructor Destroy(); override;
  end;

implementation

uses
  Provider, Action,
  VenditoriSimple, SoluzioneAgenti, System.SysUtils,
  ObjectsMappers, ClientRequest;

{ TMailerModel }

function TReceptionModel.BuildBackEndEntry(const Origin, Action: String; const data: TJSonObject;
  const Attachments: TObjectList<TAttachment>): TDispatcherEntry;
begin
  /// stub
  Result := TDispatcherEntry.Create();
end;

function TReceptionModel.ConvertToOwnResponce(
  const BackEndResponce: TDispatcherResponce): TResponce;
begin
  if (BackEndResponce = nil) then
    Result := TResponce.Create(False, 'No responce from the backend server.')
  else
    Result := TResponce.Create(BackEndResponce.Status, BackEndResponce.Msg);
end;

constructor TReceptionModel.Create;
var
  Providers: TObjectList<TProvider>;
begin
  Writeln('Model create');
  Providers := TObjectList<TProvider>.Create;
  Providers.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create]);
  FFactory := TProviderFactory.Create(Providers);
  FClients := TArray<TClient>.Create();
  Providers.Clear;
  Providers.DisposeOf;
end;

destructor TReceptionModel.Destroy;
var
  I, S: Integer;
begin
  Writeln('Model destroy');
  S := Length(FClients);
  for I := 0 to S - 1 do
    FClients[I].DisposeOf();
  SetLength(FClients, 0);
  FFactory.DisposeOf;
  FSettings.DisposeOf;
  if FAuthentication <> nil then
    FAuthentication.DisposeOf;

end;

function TReceptionModel.Elaborate(const Requestor, anAction, IP, Token: String;
  const Request: TClientFullRequest): TResponce;
var
  Provider: TProvider;
  Action: TAction;
  Responce: TResponce;
begin
  if isAuthenticated(IP, Token) then
  begin
    Provider := FFactory.FindByName(Requestor);
    if (Provider <> nil) then
    begin
      Action := Provider.FindByName(anAction);
    end;
    if (Action <> nil) then
    begin
      Responce := Action.Elaborate(Request, FSettings);
    end
    else
    begin
      Responce := TResponce.Create(False, 'Action not allowed.');

    end;
  end
  else
  begin
    Responce := TResponce.Create(False, 'Access denied');
  end;
  Result := Responce;

end;

function TReceptionModel.ExtractBody(const Boundary, RawBody, ContentType, KeyName: String): String;
var
  items, BodyParts: TArray<string>;
  separator: String;
begin
  if not ContentType.IsEmpty then
  begin
    items := ContentType.Split([';']);
    if not Boundary.IsEmpty then
    begin
      /// See section 5.1.1 "Common Syntax" (http://www.ietf.org/rfc/rfc2046.txt):
      /// The Content-Type field for multipart entities requires one parameter,
      // "boundary". The boundary delimiter line is then defined as a line
      // consisting entirely of two hyphen characters ("-", decimal value 45)
      // followed by the boundary parameter value from the Content-Type header
      // field, optional linear whitespace, and a terminating CRLF.
      Separator := '--' + boundary;
      BodyParts := RawBody.Split([Separator]);
      Result := PickMultipartItem(BodyParts, ContentType, KeyName);

    end;
    BodyParts := nil;
    Items := nil;
  end;

end;

function TReceptionModel.GetBackEndPort: Integer;
begin
  Result := FSettings.Port;
end;

function TReceptionModel.GetBackEndUrl: String;
begin
  Result := FSettings.Url;
end;

function TReceptionModel.GetClients: TObjectList<TClient>;
begin
  if FAuthentication = nil then
    Result := TObjectList<TClient>.Create
  else
    Result := FAuthentication.GetClients;
end;

function TReceptionModel.GetParamValue(const Query, Param: String): String;
var
  items, keyvalue: TArray<string>;
  pair: String;
begin
  if not Query.IsEmpty then
  begin
    items := Query.Split([';']);
    for pair in items do
    begin
      keyvalue := pair.trim().split(['=']);
      if Length(keyvalue) = 2 then
      begin
        if Param.Equals(keyvalue[0].trim()) then
        begin
          Result := keyvalue[1];
          Exit();
        end;
      end
    end
  end;
end;

procedure TReceptionModel.SetClients(const clients: TObjectList<TClient>);
begin
  if FAuthentication <> nil then
    raise Exception.Create('Reception model can instantiate authentication class only once!');
  FAuthentication := TAuthentication.Create(clients);
end;

procedure TReceptionModel.SetConfig(const Value: TReceptionConfig);
var
  BackEndSettings: TActiveQueueSettings;
begin
  SetClients(Value.Clients);
  FPort := Value.Port;
  BackEndSettings := TActiveQueueSettings.Create(Value.BackEndUrl, Value.BackEndPort);
  SetSettings(BackEndSettings);
  BackEndSettings.DisposeOf;
end;

function TReceptionModel.isAuthenticated(const IP, Token: String): Boolean;
var
  aClient: TClient;
begin
  if (FAuthentication = nil) then
  begin
    Result := False;
  end
  else
  begin
    aClient := TClient.Create(IP, Token);
    Result := FAuthentication.isAuthenticated(aClient);
    aClient.DisposeOf;
  end;
end;

function TReceptionModel.PickMultipartItem(const Items: TArray<String>; const ContentType,
  KeyName: String): String;
var
  Elem, Needle1, Needle2: String;
  Parts: TStringList;
  positions: TList<Integer>;

begin
  Needle1 := 'Content-Disposition: form-data; name="' + KeyName + '"';
  Needle2 := 'Content-Type: ' + ContentType;
  Parts := TStringList.Create;
  for Elem in Items do
  begin
    Parts.Text := Elem.Trim();
    if Parts.Count > 2 then
    begin
      if (Parts[0] = Needle1) AND (Parts[1] = Needle2) then
      begin
        Positions := TList<Integer>.Create;
        Positions.Add(0);
        Positions.Add(1);
        Result := SkipElements(Parts, Positions).Text.trim();
        Exit();
      end;
    end;
  end;
end;

procedure TReceptionModel.SetSettings(const Value: TActiveQueueSettings);
begin
  FSettings := TActiveQueueSettings.Create(Value.Url, Value.Port);
end;

function TReceptionModel.SkipElements(const Items: TStringList;
  const positions: TList<Integer>): TStringList;
var
  I, L: Integer;
begin
  Result := TStringList.Create;
  L := Items.Count;
  for I := 0 to L - 1 do
    if not(Positions.Contains(I)) then
    begin
      Result.Add(Items[I]);
    end;
end;

end.
