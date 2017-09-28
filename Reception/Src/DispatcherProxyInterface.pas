unit DispatcherProxyInterface;

interface

uses
  MVCFramework.RESTAdapter, MVCFramework.Commons, DispatcherEntry, DispatcherResponce;

type
  IDispatcherProxy = interface(IInvokable)
    ['{7A30B2C3-B314-4D52-A62F-7714C206E8A8}']

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/request')]
    function PutEntry([Body(False)] input: TDispatcherEntry): TDispatcherResponce;

  end;

implementation

end.
