unit DispatcherModel;

interface

uses
  DispatcherConfig, DispatcherResponce, DispatcherEntry,
  ProviderFactory, System.Generics.Collections, ActiveQueueEntry, Attachment,
  ServerConfig, IpTokenAuthentication;

type
  TModel = class(TObject)

  strict private
  var
    FConfig: TServerConfigImmutable;
    FAuthentication: TIpTokenAuthentication;
    FFactory: TProviderFactory;

    function GetConfig(): TServerConfigImmutable;
    procedure SetConfig(const Config: TServerConfigImmutable);

  public
    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP, Token: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;
    /// <summary>Split the entry into a set of single actions and pass them to the back end server.</summary>
    function CreateBackEndEntries(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;

    property Config: TServerConfigImmutable read GetConfig write SetConfig;
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  Provider, VenditoriSimple, SoluzioneAgenti, Actions, OfferteNuoviMandati,
  System.SysUtils, Client, System.Classes;

{ TModel }

constructor TModel.Create;
var
  ListOfProviders: TObjectList<TProvider>;
begin
  ListOfProviders := TObjectList<TProvider>.Create;
  ListOfProviders.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create, TOfferteNuoviMandati.Create]);
  FFactory := TProviderFactory.Create(ListOfProviders);
  ListOfProviders.Clear;
  ListOfProviders.DisposeOf;
end;

function TModel.CreateBackEndEntries(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;
var
  Actions: TObjectList<TAction>;
  Action: TAction;
  Token: String;
  Attachments: TObjectList<TAttachment>;
  BackEndEntry: TActiveQueueEntry;
begin
  Actions := FFactory.FindActions(Entry.Origin, Entry.Action);
  Result := TObjectList<TActiveQueueEntry>.Create();
  Token := FConfig.Token;
  try
    for Action in Actions do
    begin
      Attachments := Entry.Attachments;
      try
        BackEndEntry := Action.MapToBackEndEntry(Entry.Content, Attachments, Token);
        Result.Add(BackEndEntry);
      except
        on E: Exception do
        begin
          // Attachments.Clear;
          // Attachments.DisposeOf;
          // Actions.Clear;
          Actions.DisposeOf();
          raise Exception.Create('Failed to create back-end entries: ' + e.Message);
        end;
      end;
      // Attachments.Clear;
      // Attachments.DisposeOf;
      // Attachments := nil;
    end;
  finally
    Actions.Clear;
    Actions.DisposeOf();
    if Attachments <> nil then
    begin
      Attachments.Clear;
      Attachments.DisposeOf;
    end;
  end;

end;

destructor TModel.Destroy;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  if FAuthentication <> nil then
    FAuthentication.DisposeOf;
  FFactory.DisposeOf;
  inherited;
end;

function TModel.GetBackEndIp: String;
begin
  Result := FConfig.BackEndIp
end;

function TModel.GetBackEndPort: Integer;
begin
  Result := FConfig.BackEndPort
end;

function TModel.GetClientIps: TArray<String>;
begin
  Result := FAuthentication.GetIps();
end;

function TModel.GetConfig: TServerConfigImmutable;
begin
  Result := TServerConfigImmutable.Create(FConfig.Port, FConfig.Clients, FConfig.BackEndIP, FConfig.BackEndPort, FConfig.Token);
end;

function TModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port;
end;

function TModel.isAuthorised(const IP, Token: String): Boolean;
begin
  Result := (FAuthentication <> nil) AND FAuthentication.isAuthorised(IP, Token);
end;

procedure TModel.SetConfig(const Config: TServerConfigImmutable);
var
  IPs, Tokens: TArray<String>;
  Clients: TObjectList<TClient>;
  L, I: Integer;
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;

  FConfig := Config.Clone;
  IPs := TArray<String>.Create();
  Tokens := TArray<String>.Create();
  Clients := Config.Clients;
  L := Clients.Count;
  SetLength(IPs, L);
  SetLength(Tokens, L);
  for I := 0 to L - 1 do
  begin
    IPs[I] := Clients[I].IP;
    Tokens[I] := Clients[I].Token;
  end;
  FAuthentication := TIpTokenAuthentication.Create(IPs, Tokens);
  SetLength(IPs, 0);
  SetLength(Tokens, 0);
  Clients.Clear;
  Clients.DisposeOf();

end;

end.
