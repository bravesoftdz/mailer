unit ListenerProxyInterface;

interface

uses
  MVCFramework.RESTAdapter, MVCFramework.Commons,
  ActiveQueueEntry, System.JSON, ConditionInterface;

type
  /// <summary>an interface defining API of the consumer of the Active Queue service.</summary>
  IConsumerProxy = interface(IInvokable)
    ['{CD6E015B-9C4D-4DCD-BDFB-7E01CFB9F060}']
    [RESTResource(TMVCHTTPMethodType.httpPOST, '/notify')]
    procedure Notify();

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/cancel')]
    procedure Cancel(const Condition: ICondition);
  end;

implementation

end.
