unit ReceptionConfig;

interface

uses
  System.Generics.Collections, Client, ObjectsMappers;

type

  [MapperJSONNaming(JSONNameLowerCase)]
  TReceptionConfig = class(TObject)
  strict private
    FPort: Integer;
    FBackEndPort: Integer;
    FBackEndUrl: String;
    FClients: TObjectList<TClient>;

  public
    /// <summary> Port at which the program accepts the connections.</summary>
    [MapperJSONSer('port')]
    property Port: Integer read FPort write FPort;

    /// <summary> Url of the backend service accepts the connections.</summary>
    [MapperJSONSer('backend-url')]
    property BackEndUrl: String read FBackEndUrl write FBackEndUrl;

    /// <summary> Port at which the backend service accepts the connections.</summary>
    [MapperJSONSer('backend-port')]
    property BackEndPort: Integer read FBackEndPort write FBackEndPort;

    /// <summary>List of clients from which the requests are accepted.</summary>
    [MapperJSONSer('clients')]
    [MapperListOf(TClient)]
    property Clients: TObjectList<TClient> read FClients write FClients;

    constructor Create(); overload;
    destructor Destroy(); override;
  end;

implementation

{ TReceptionConfig }

constructor TReceptionConfig.Create;
begin
  FClients := TObjectList<TClient>.Create();
end;

destructor TReceptionConfig.Destroy;
begin
  FClients.Clear;
  FClients.DisposeOf;
end;

end.
