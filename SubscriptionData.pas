unit SubscriptionData;

interface

uses ObjectsMappers;

// <summary>Data class that contains information necessary for
// perform the subscription.</summary>
type

  [MapperJSONNaming(JSONNameLowerCase)]
  TSubscriptionData = class
  strict private
    FUrl: String;
    FIP: String;
    FPort: Integer;
    FPath: String;
  public
    [MapperJSONSer('url')]
    property Url: String read FUrl write FUrl;
    [MapperJSONSer('ip')]
    property Ip: String read FIp write FIp;
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;
    [MapperJSONSer('path')]
    property Path: String read FPath write FPath;
    constructor Create(const Ip, Url: String; const Port: Integer; const Path: String); overload;
    constructor Create(); overload;
  end;

implementation

{ TSubscriptionData }

constructor TSubscriptionData.Create(const Ip, Url: String; const Port: Integer;
  const Path: String);
begin
  FIP := Ip;
  FUrl := Url;
  FPort := Port;
  FPath := Path;
end;

constructor TSubscriptionData.Create;
begin
  FUrl := '';
  FPort := 0;
  FPath := '';
end;

end.
