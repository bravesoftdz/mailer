unit Model;

interface

uses
  DispatcherConfig, IpAuthentication, DispatcherResponce, DispatcherEntry,
  ProviderFactory, System.Generics.Collections, ActiveQueueEntry, Attachment;

type
  TModel = class(TObject)

  strict private
  var
    FConfig: TDispatcherConfig;
    FAuthentication: IAuthentication;
    FFactory: TProviderFactory;

    function GetConfig(): TDispatcherConfig;
    procedure SetConfig(const Config: TDispatcherConfig);

  public
    function GetPort(): Integer;
    function GetClientIps(): TArray<String>;
    function isAuthorised(const IP: String): Boolean;
    function GetBackEndIp(): String;
    function GetBackEndPort(): Integer;
    /// <summary>Split the entry into a set of single actions and pass them to the back end server.</summary>
    function CreateBackEndEntries(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;

    property Config: TDispatcherConfig read GetConfig write SetConfig;
    constructor Create();
    destructor Destroy(); override;
  end;

implementation

uses
  Provider, VenditoriSimple, SoluzioneAgenti, Actions, OfferteNuoviMandati,
  System.SysUtils;

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
          Attachments.Clear;
          Attachments.DisposeOf;
          Actions.Clear;
          Actions.DisposeOf();
          raise Exception.Create('Failed to create back-end entries: ' + e.Message);
        end;
      end;
      Attachments.Clear;
      Attachments.DisposeOf;
      Attachments := nil;
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
  FAuthentication := nil;
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

function TModel.GetConfig: TDispatcherConfig;
begin
  Result := TDispatcherConfig.Create(FConfig.Port, FConfig.ClientIPs, FConfig.BackEndIp, FConfig.BackEndPort, FConfig.Token);
end;

function TModel.GetPort: Integer;
begin
  if FConfig <> nil then
    Result := FConfig.Port;
end;

function TModel.isAuthorised(const IP: String): Boolean;
begin
  Result := (FAuthentication <> nil) AND FAuthentication.isAuthorised(IP);
end;

procedure TModel.SetConfig(const Config: TDispatcherConfig);
begin
  if FConfig <> nil then
  begin
    FConfig.DisposeOf();
  end;
  FConfig := TDispatcherConfig.Create(Config.Port, Config.ClientIPs, Config.BackEndIp, Config.BackEndPort, Config.Token);
  FAuthentication := TIpAuthentication.Create(Config.ClientIPs);

end;

end.
