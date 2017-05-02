unit ListenerProxyInterface;

interface

uses
  ReceptionRequest, System.JSON, ConditionInterface;

type
  /// <summary>an interface defining API of the listener. The only url that
  /// is supposed to be called is "servername:port/notify". </summary>
  IListenerProxy = interface(IInvokable)
    ['{CD6E015B-9C4D-4DCD-BDFB-7E01CFB9F060}']
    [RESTResource(TMVCHTTPMethodType.httpPOST, '/notify')]
    procedure Notify();

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/cancel')]
    procedure Cancel(const Condition: ICondition);
  end;

implementation

end.
