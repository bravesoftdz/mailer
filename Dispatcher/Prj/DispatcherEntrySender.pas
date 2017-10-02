unit DispatcherEntrySender;

interface

uses
  RequestStorageInterface, DispatcherEntry, AQAPIClient, System.Classes;

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

    /// retreives items in the repository that should be sent and send them.
    /// This method should be launched in a separate thread in order not to block the main thread.
    procedure Send();
  public
    constructor Create(const Repository: IRequestStorage<TDispatcherEntry>; const BackEndServer: IAQAPIClient);
    destructor Destroy(); override;

    property IsRunning: Boolean read FIsRunning;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

{ TDispatcherEntrySender }

constructor TDispatcherEntrySender.Create(
  const Repository: IRequestStorage<TDispatcherEntry>;
  const BackEndServer: IAQAPIClient);
begin
  FIsAlive := True;
  FSender := TThread.CreateAnonymousThread(Send);
  FSender.Start;
end;

destructor TDispatcherEntrySender.Destroy;
begin
  FIsAlive := False;
  inherited;
end;

procedure TDispatcherEntrySender.Send;
begin
  while FIsAlive do
  begin
    Writeln('I''m on...' + MilliSecondsBetween(Now, 0).ToString);
  end;
end;

end.
