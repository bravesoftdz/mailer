unit ListenerProxyInterface;

interface

uses
  ReceptionRequest, System.JSON;

type
  IListenerProxy = interface(IInvokable)
    ['{CD6E015B-9C4D-4DCD-BDFB-7E01CFB9F060}']
    [RESTResource(TMVCHTTPMethodType.httpPOST, '/send')]
    function Send([Body] input: TReceptionRequest): TJsonObject;
  end;

implementation

end.
