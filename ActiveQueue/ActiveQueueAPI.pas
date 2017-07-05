unit ActiveQueueAPI;

interface

uses SubscriptionData, ActiveQueueResponce, SendDataTemplate, ActiveQueueEntry,
  System.Generics.Collections, MVCFramework.RESTAdapter, MVCFramework.Commons, MVCFramework, ObjectsMappers;

type
  IActiveQueueAPI = interface(IInvokable)
    ['{55AC9696-1A87-48F5-A01A-584FB4EBB738}']

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/subscribe')]
    function Subscribe([Body] Data: TSubscriptionData): TActiveQueueResponce;

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/unsubscribe/{token}')]
    function Unsubscribe([Param('token')] Token: String): TActiveQueueResponce;

    [RESTResource(TMVCHTTPMethodType.httpGET, '/items/get/{token}/{quantity}')]
    function GetItems([Param('token')] Token: String; [Param('quantity')] N: Integer): TReceptionRequests;

    [RESTResource(TMVCHTTPMethodType.httpPOST, '/items/post')]
    function PutItems([Body(False)] Items: TActiveQueueEntries): Boolean;

  end;

implementation

end.
