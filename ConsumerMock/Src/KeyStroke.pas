unit KeyStroke;

interface

uses
  ConsumerController, System.Generics.Collections;

const
  KEEP_ON = 1;
  STOP = 0;
  DEFAULT_COLOR = 7;
  WARNING_COLOR = 12;

type
  IKeyStrokeAction = interface(IInvokable)
    ['{771C36F5-7A57-4F1F-BC1F-21E7B08A4584}']
    /// <summary>Execute an action. If returns 0, no further action should be executed.</summary>
    function Elaborate(): Integer;
    /// <summary>return the ascii code of a symbol that triggers this action.</sumamry>
    function GetTriggerKeyStroke(): Integer;
    /// <summary>A description of what this action does.</summary>
    function GetDescription(): String;
  end;

type
  /// <summary>A class that wraps many keystroke actions.</summary>
  TKeyStroke = class(TObject)
  strict private
  var
    FIndex: TDictionary<Integer, IKeyStrokeAction>;
  public
    constructor Create(const EventHandlers: TArray<IKeyStrokeAction>);
    destructor Destroy(); override;
    /// <summary>Find a keystroke action associated with given keystroke code and execute it.
    /// Return the result of that action. </summary>
    function ElaborateKeyStroke(const KeyCode: Integer): Integer;
    function Description(): String;
  end;

type
  TExitAction = class(TInterfacedObject, IKeyStrokeAction)
  public
    function Elaborate(): Integer;
    function GetTriggerKeyStroke(): Integer;
    function GetDescription(): String;
  end;

type
  TConsumerSubscribeAction = class(TInterfacedObject, IKeyStrokeAction)
  public
    function Elaborate(): Integer;
    function GetTriggerKeyStroke(): Integer;
    function GetDescription(): String;
  end;

type
  TConsumerUnSubscribeAction = class(TInterfacedObject, IKeyStrokeAction)
  public
    function Elaborate(): Integer;
    function GetTriggerKeyStroke(): Integer;
    function GetDescription(): String;
  end;

implementation

uses
  System.SysUtils, Winapi.Windows;
{ TConsumerKeyStroke }

constructor TKeyStroke.Create(const EventHandlers: TArray<IKeyStrokeAction>);
var
  Action: IKeyStrokeAction;
  Code: Integer;
begin
  FIndex := TDictionary<Integer, IKeyStrokeAction>.Create();
  if EventHandlers <> nil then
  begin
    for Action in EventHandlers do
    begin
      Code := Action.GetTriggerKeyStroke;
      if FIndex.ContainsKey(Code) then
        raise Exception.Create('Dublicate trigger code ' + Code.toString());
      FIndex.Add(Action.GetTriggerKeyStroke, Action);
    end;
  end;
end;

function TKeyStroke.Description: String;
var
  Builder: TStringBuilder;
  Action: IKeyStrokeAction;
  Code: Integer;
begin
  Builder := TStringBuilder.Create();
  for Action in FIndex.Values do
  begin
    Code := Action.GetTriggerKeyStroke;
    if (Code > 31) AND (Code < 128) then
      Builder.AppendLine(Format('key code: %d (symbol "%s"): %s', [Code, Char(Code), Action.GetDescription()]))
    else
      Builder.AppendLine(Format('key code: %d: %s', [Code, Action.GetDescription()]));
  end;
  Result := Builder.ToString;
  Builder.DisposeOf;

end;

destructor TKeyStroke.Destroy;
begin
  FIndex.DisposeOf;
  inherited;
end;

function TKeyStroke.ElaborateKeyStroke(const KeyCode: Integer): Integer;
begin
  if FIndex.ContainsKey(KeyCode) then
  begin
    try
      Result := FIndex[KeyCode].Elaborate;
    except
      on E: Exception do
      begin
        Write('Action "' + FIndex[KeyCode].GetDescription + '" failed: ');
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), WARNING_COLOR);
        Writeln(E.Message);
        SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), DEFAULT_COLOR);
        Result := KEEP_ON;
      end;
    end;
  end
  else
    Result := KEEP_ON;
end;

{ TConsumerSubscribeAction }

function TConsumerSubscribeAction.Elaborate: Integer;
begin
  TConsumerController.Subscribe();
  Result := KEEP_ON;
end;

function TConsumerSubscribeAction.GetDescription: String;
begin
  Result := 'Make request to subscribe.';
end;

function TConsumerSubscribeAction.GetTriggerKeyStroke: Integer;
begin
  Result := 48; // button '1'
end;

{ TConsumerUnSubscribeAction }

function TConsumerUnSubscribeAction.Elaborate: Integer;
begin
  TConsumerController.UnSubscribe();
  Result := KEEP_ON;
end;

function TConsumerUnSubscribeAction.GetDescription: String;
begin
  Result := 'Make request to unsubscribe.';
end;

function TConsumerUnSubscribeAction.GetTriggerKeyStroke: Integer;
begin
  Result := 49; // button '0'
end;

{ TExitAction }

function TExitAction.Elaborate: Integer;
begin
  Result := STOP;
end;

function TExitAction.GetDescription: String;
begin
  Result := 'Stop the program and exit.';
end;

function TExitAction.GetTriggerKeyStroke: Integer;
begin
  Result := VK_ESCAPE;
end;

end.
