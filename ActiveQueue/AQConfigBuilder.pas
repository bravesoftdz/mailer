unit AQConfigBuilder;

interface

uses
  AQConfig, System.Generics.Collections, Consumer;

type
  /// <summary>A builder for a previous version of TAQConfig. It is moved into a separate file
  /// as a candidate for removal or transforming into something else.</summary>
  TAQConfigBuilder = class
  strict private
    FPort: Integer;
    FListenerIPs: String;
    FProviderIPs: String;
    FListeners: TObjectList<TConsumer>;
    function Join(const Items: TArray<String>; const Separator: String): String;
  public
    function SetPort(const Port: Integer): TAQConfigBuilder;
    function SetListenerIPs(const IPs: String): TAQConfigBuilder; overload;
    function SetListenerIPs(const IPs: TArray<String>): TAQConfigBuilder; overload;
    function SetProviderIPs(const IPs: String): TAQConfigBuilder; overload;
    function SetProviderIPs(const IPs: TArray<String>): TAQConfigBuilder; overload;
    function SetListeners(const Listeners: TObjectList<TConsumer>): TAQConfigBuilder;
    function Build(): TAQConfig;
    constructor Create();

  end;

implementation

uses
  System.SysUtils;

function TAQConfigBuilder.Build: TAQConfig;
begin
  // Result := TAQConfig.Create(FPort, FListenerIPs, FProviderIPs, FListeners);
  raise Exception.Create('TAQConfigBuilder.Build is depricated');
end;

constructor TAQConfigBuilder.Create;
begin
  FPort := 0;
  FListenerIPs := '';
  FProviderIPs := '';
  FListeners := TObjectList<TConsumer>.Create();
end;

function TAQConfigBuilder.Join(const Items: TArray<String>; const Separator: String): String;
var
  I, L: Integer;
begin
  Result := '';
  L := Length(Items);
  for I := 0 to L - 2 do
    Result := Result + Items[I] + Separator;
  if L > 0 then
    Result := Result + Items[L - 1];

end;

function TAQConfigBuilder.SetListenerIPs(const IPs: String): TAQConfigBuilder;
begin
  FListenerIPs := IPs;
  Result := Self;
end;

function TAQConfigBuilder.SetListenerIPs(const IPs: TArray<String>): TAQConfigBuilder;
begin
  FListenerIPs := Join(IPs, ',');
  Result := Self;
end;

function TAQConfigBuilder.SetListeners(
  const Listeners: TObjectList<TConsumer>): TAQConfigBuilder;
var
  ListenerInfo: TConsumer;
begin
  FListeners.Clear;
  for ListenerInfo in Listeners do
  begin
    FListeners.Add(ListenerInfo);
  end;
  Result := Self;

end;

function TAQConfigBuilder.SetPort(const Port: Integer): TAQConfigBuilder;
begin
  FPort := Port;
  Result := Self;
end;

function TAQConfigBuilder.SetProviderIPs(const IPs: TArray<String>): TAQConfigBuilder;
begin
  FProviderIPs := Join(IPs, ',');
  Result := Self;
end;

function TAQConfigBuilder.SetProviderIPs(const IPs: String): TAQConfigBuilder;
begin
  FProviderIPs := IPs;
  Result := Self;
end;

end.
