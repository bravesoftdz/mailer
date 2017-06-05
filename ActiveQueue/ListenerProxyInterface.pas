unit ListenerProxyInterface;

interface

uses
  MVCFramework.RESTAdapter, MVCFramework.Commons,
  ReceptionRequest, System.JSON, ConditionInterface;

type
  /// <summary>an interface defining API of the listener. </summary>
  IListenerProxy = interface(IInvokable)
    ['{CD6E015B-9C4D-4DCD-BDFB-7E01CFB9F060}']
    [RESTResource(TMVCHTTPMethodType.httpPOST, '/notify')]
    procedure Notify();

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/cancel')]
    procedure Cancel(const Condition: ICondition);
  end;

implementation

end.
