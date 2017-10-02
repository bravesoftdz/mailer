unit DispatcherEntrySender;

interface

uses
  RequestStorageInterface, DispatcherEntry, AQAPIClient, System.Classes,
  DispatcherResponce, ActiveQueueEntry, AQResponce, ProviderFactory, Attachment,
  System.Generics.Collections;

type
  /// <summary>This class takes care of sending dispatcher entries to the active queue server.
  /// It is supposed to constantly monitor the repository and send the items to the active queue server. </summary>
  TDispatcherEntrySender = class(TObject)
  strict private
  var
    /// a status of the sender: true means that the thread keeps monitoring the repository, false - that
    /// it does not monitor the repository.
    FIsRunning: Boolean;

    /// a marker that is used in order to inform the thread that it should finish.
    FIsAlive: Boolean;

    FSender: TThread;

    FRepository: IRequestStorage<TDispatcherEntry>;

    FBackEndServer: IAQAPIClient;

    FFactory: TProviderFactory;

    /// authentication token that should be comunicated to the back end server
    FToken: String;

    /// retrieves items in the repository that should be sent and send them.
    /// This method should be launched in a separate thread in order not to block the main thread.
    procedure Loop();

    /// <summary> Elaborate a single request that has been already:
    /// 1. dispatch the request
    /// 2. convert it to a back-end server compatible format
    /// 3. send to the back-end server
    /// 4. delete the requests that were successefuly passed to the back-end server
    /// </summary>
    function ElaborateSinglePersistedRequest(const Id: String; const Request: TDispatcherEntry): TDispatcherResponce;

    /// <summary>Dispatch the input request and transform it in a form that the back end server can accept.
    /// <summary>
    /// <param name="Entry">a dispatcher entry to be elaborated</param>

    function DispatchConvert(const Entry: TDispatcherEntry): TActiveQueueEntries;

    function SendToBackEnd(const Requests: TActiveQueueEntries): TAQResponce;

    /// <summary>Delete persisted object by its id.
    /// This method serves just for clean up. If it fails, nothing serious happens.
    /// Return true in case of success, false otherwise. </summary>
    function Delete(const Id: String): Boolean;

    /// <summary>Split the entry into a set of single actions and pass them to the back end server.</summary>
    function Dispatch(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;

    procedure ElaboratePendingRequests();
  public
    constructor Create(const Repository: IRequestStorage<TDispatcherEntry>; const BackEndServer: IAQAPIClient; const Token: String);
    destructor Destroy(); override;

    property IsRunning: Boolean read FIsRunning;
  end;

implementation

uses
  System.SysUtils, System.DateUtils,
  Provider, VenditoriSimple, SoluzioneAgenti, Actions, OfferteNuoviMandati;

{ TDispatcherEntrySender }

constructor TDispatcherEntrySender.Create(
  const Repository: IRequestStorage<TDispatcherEntry>;
  const BackEndServer: IAQAPIClient; const Token: String);
var
  ListOfProviders: TObjectList<TProvider>;
begin
  FRepository := Repository;
  FBackEndServer := BackEndServer;
  FToken := Token;
  ListOfProviders := TObjectList<TProvider>.Create;
  ListOfProviders.addRange([TVenditoriSimple.Create, TSoluzioneAgenti.Create, TOfferteNuoviMandati.Create]);
  FFactory := TProviderFactory.Create(ListOfProviders);
  ListOfProviders.Clear;
  ListOfProviders.DisposeOf;

  FIsAlive := True;
  FSender := TThread.CreateAnonymousThread(Loop);
  FSender.Start;
end;

destructor TDispatcherEntrySender.Destroy;
begin
  FIsAlive := False;
  FFactory.DisposeOf;
  inherited;
end;

procedure TDispatcherEntrySender.ElaboratePendingRequests;
var
  PendingRequests: TDictionary<String, TDispatcherEntry>;
  RequestId: String;
  ResponceLocal: TDispatcherResponce;

begin
  PendingRequests := FRepository.GetPendingRequests();

  if (PendingRequests.Count > 0) then
  begin
    for RequestId in PendingRequests.Keys do
    begin
      ResponceLocal := ElaborateSinglePersistedRequest(RequestId, PendingRequests[RequestId]);
      if ResponceLocal <> nil then
      begin
        ResponceLocal.DisposeOf;
        PendingRequests[RequestId].DisposeOf;
      end
      else
        Writeln('No responce received from the back end server.');
    end;
  end;
  PendingRequests.Clear;
  PendingRequests.DisposeOf;

end;

function TDispatcherEntrySender.ElaborateSinglePersistedRequest(const Id: String; const Request: TDispatcherEntry): TDispatcherResponce;
var
  SavedAndConverted: TActiveQueueEntries;
  Outcome: TAQResponce;
  Status: Boolean;
  Msg: String;
begin
  SavedAndConverted := DispatchConvert(Request);
  try
    Outcome := SendToBackEnd(SavedAndConverted);
  except
    on E: Exception do
    begin
      Result := TDispatcherResponce.Create(True, Format(TDispatcherResponceMessages.EXCEPTION_REPORT, [Id, E.Message]));
      Outcome := nil;
    end;
  end;
  SavedAndConverted.DisposeOf;
  if Outcome <> nil then
  begin
    // extract the values that will be used later in order to be able to destroy the object
    Status := Outcome.status;
    Msg := Outcome.Msg;
    Outcome.DisposeOf;
    if Status then
    begin
      try
        Delete(Id);
        Result := TDispatcherResponce.Create(True, TDispatcherResponceMessages.SUCCESS);
      except
        on E: Exception do
        begin
          Result := TDispatcherResponce.Create(True, Format(TDispatcherResponceMessages.FAILED_TO_DELETE, [Id, E.Message]));
        end;
      end;
    end
    else
    begin
      Result := TDispatcherResponce.Create(False, Format(TDispatcherResponceMessages.FAILURE_REPORT, [Id, Msg]));
    end;

  end;
  Writeln('Finish TModel.ElaborateSinglePersistedRequest');
end;

function TDispatcherEntrySender.DispatchConvert(const Entry: TDispatcherEntry): TActiveQueueEntries;
var
  Items: TObjectList<TActiveQueueEntry>;
  ErrorMessages: TStringList;
  ErrorSummary: String;
begin
  ErrorMessages := TStringList.Create;
  try
    Items := Dispatch(Entry);
  except
    on E: Exception do
    begin
      ErrorMessages.Add(E.Message);
    end;
  end;

  if (Items <> nil) then
  begin
    Result := TActiveQueueEntries.Create(FToken, Items);
  end;
  if Items <> nil then
  begin
    Items.Clear;
    Items.DisposeOf;
  end;

  if ErrorMessages.Count > 0 then
  begin
    ErrorSummary := ErrorMessages.Text;
    ErrorMessages.DisposeOf;
    raise Exception.Create('Dispatcher has encountered the following error: ' + ErrorSummary);
  end
  else
  begin
    ErrorMessages.DisposeOf;
  end;

end;

procedure TDispatcherEntrySender.Loop;
begin
  Writeln('The background service has started in thread ' + TThread.CurrentThread.ThreadID.ToString);
  while FIsAlive do
  begin
    ElaboratePendingRequests();
  end;
  Writeln('The background service has finished in thread ' + TThread.CurrentThread.ThreadID.ToString);
end;

function TDispatcherEntrySender.SendToBackEnd(const Requests: TActiveQueueEntries): TAQResponce;
begin
  Writeln('Start: TModel.SendToBackEnd');
  Result := FBackEndServer.PostItems(Requests);
  Writeln('End: TModel.SendToBackEnd');
end;

function TDispatcherEntrySender.Delete(const Id: String): Boolean;
begin
  Result := FRepository.Delete(Id);
end;

function TDispatcherEntrySender.Dispatch(const Entry: TDispatcherEntry): TObjectList<TActiveQueueEntry>;
var
  Actions: TObjectList<TAction>;
  Action: TAction;
  Token: String;
  Attachments: TObjectList<TAttachment>;
  BackEndEntry: TActiveQueueEntry;
  AQTmp: TActiveQueueEntry;
begin
  Actions := FFactory.FindActions(Entry.Origin, Entry.Action);
  Result := TObjectList<TActiveQueueEntry>.Create();
  try
    for Action in Actions do
    begin
      Attachments := Entry.Attachments;
      try
        BackEndEntry := Action.MapToBackEndEntry(Entry.Content, Attachments, FToken);
        Result.Add(BackEndEntry);
      except
        on E: Exception do
        begin
          Actions.Clear;
          Actions.DisposeOf();
          raise Exception.Create('Failed to create back-end entries: ' + e.Message);
        end;
      end;
    end;
  finally
    Actions.Clear;
    Actions.DisposeOf();
  end;
end;

end.
