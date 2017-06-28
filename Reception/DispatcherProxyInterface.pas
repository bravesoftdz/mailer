unit DispatcherProxyInterface;

interface

uses
  DispatcherEntry, DispatcherResponce;

type
  IDispatcherProxy = interface(IInvokable)
    ['{7A30B2C3-B314-4D52-A62F-7714C206E8A8}']

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/request')]
    function PutEntry([Body] input: TDispatcherEntry): TDispatcherResponce;

  end;

implementation

end.
