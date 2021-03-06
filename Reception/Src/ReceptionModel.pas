unit ReceptionModel;

interface

uses
  ReceptionResponce, ActiveQueueSettings, Web.HTTPApp, Client,
  Authentication, System.Classes, DispatcherEntry, System.JSON, Attachment,
  System.Generics.Collections, DispatcherResponce, ServerConfig;

type
  TReceptionModel = class(TObject)

  const
    /// name of the key that contains a token in a json
    TOKEN_KEY = 'token';
  strict private
    // FFactory: TProviderFactory;
    FClients: TArray<TClient>;
    FSettings: TActiveQueueSettings;
    FAuthentication: TAuthentication;
    /// port number at which this server works
    FPort: Integer;
    /// <summary>Authorisation token (to be given to the back end server).</summary>
    FToken: String;

    /// <summary>client setter. Perform the defencieve copying.</summary>
    procedure SetClients(const clients: TObjectList<TClient>);
    /// <summary>return a copy of clients.</summary>
    function GetClients(): TObjectList<TClient>;

    procedure SetSettings(const Value: TActiveQueueSettings);

    procedure SetConfig(const Value: TServerConfig);
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

    /// <summary> Return true if the list of clients contains a one with given IP and token.
    /// Otherwise, return false.
    /// </summary>
    function isAuthenticated(const IP, Token: String): Boolean;

    /// <summary>Extract a value corresponding to a key in a set of key-value pairs. The pairs
    /// are separated by semicolon, while the key and value are separated by equality sign. A key is
    /// optional in the key-value pairs. Example:
    /// 'multipart/form-data;charset=UTF-8;boundary=--dsds'
    /// If no param is found, an empty string is returned.
    function GetParamValue(const Query: String; const Param: String): String;

    /// <summary>Extract body from a multipart request body</summary
    function ExtractBody(const Boundary, RawBody, ContentType, KeyName: String): String;

    function BuildBackEndEntry(const Origin: String; const Action: String; const Data: String;
      const Attachments: TObjectList<TAttachment>): TDispatcherEntry;

    /// <summary>Transforms a dispatcher responce into a reception one.<summary>
    function ConvertToOwnResponce(const BackEndResponce: TDispatcherResponce): TReceptionResponce;

    property clients: TObjectList<TClient> read GetClients write SetClients;

    property Config: TServerConfig write SetConfig;

    property BackEndUrl: String read GetBackEndUrl;

    property BackEndPort: Integer read GetBackEndPort;

    property Port: Integer read FPort;

    constructor Create();

    destructor Destroy(); override;
  end;

implementation

uses
  System.SysUtils, ObjectsMappers, ClientRequest;

{ TMailerModel }

function TReceptionModel.BuildBackEndEntry(const Origin, Action: String; const data: String;
  const Attachments: TObjectList<TAttachment>): TDispatcherEntry;
begin
  Result := TDispatcherEntry.Create(Origin, Action, Data, Attachments, FToken);
end;

function TReceptionModel.ConvertToOwnResponce(
  const BackEndResponce: TDispatcherResponce): TReceptionResponce;
begin
  if (BackEndResponce = nil) then
    Result := TReceptionResponce.Create(False, 'No responce from the backend server.')
  else
    Result := TReceptionResponce.Create(BackEndResponce.Status, BackEndResponce.Msg);
end;

constructor TReceptionModel.Create;
begin
  Writeln('Model create');
  FClients := TArray<TClient>.Create();
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
  FSettings.DisposeOf;
  if FAuthentication <> nil then
    FAuthentication.DisposeOf;

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
  if Query.IsEmpty then
    Result := ''
  else
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
          Break;
        end
      end;
      keyvalue := nil;
    end;
    keyvalue := nil;
    items := nil;
  end;
end;

procedure TReceptionModel.SetClients(const clients: TObjectList<TClient>);
begin
  if FAuthentication <> nil then
    raise Exception.Create('Reception model can instantiate authentication class only once!');
  FAuthentication := TAuthentication.Create(clients);
end;

procedure TReceptionModel.SetConfig(const Value: TServerConfig);
var
  BackEndSettings: TActiveQueueSettings;
begin
  SetClients(Value.Clients);
  FPort := Value.Port;
  FToken := Value.Token;
  BackEndSettings := TActiveQueueSettings.Create(Value.BackEndIP, Value.BackEndPort);
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
  Tail: TStringList;
begin
  Needle1 := 'Content-Disposition: form-data; name="' + KeyName + '"';
  Needle2 := 'Content-Type: ' + ContentType;
  Parts := TStringList.Create;
  Positions := TList<Integer>.Create;
  try
    for Elem in Items do
    begin
      Parts.Text := Elem.Trim();
      if Parts.Count > 2 then
      begin
        if (Parts[0] = Needle1) AND (Parts[1] = Needle2) then
        begin
          Positions.Add(0);
          Positions.Add(1);
          Tail := SkipElements(Parts, Positions);
          Result := Tail.Text.trim();
          Tail.DisposeOf;
          Break;
        end;
      end;
    end;
  finally
    Parts.DisposeOf;
    Positions.DisposeOf;
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
