unit ActiveQueueAPI;

interface

uses SubscriptionData, ActiveQueueResponce, ReceptionRequest,
  System.Generics.Collections, MVCFramework.RESTAdapter, MVCFramework.Commons;

type
  IActiveQueueAPI = interface(IInvokable)
    ['{55AC9696-1A87-48F5-A01A-584FB4EBB738}']

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/subscribe')]
    function Subscribe([Body] Data: TSubscriptionData): TActiveQueueResponce;

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/unsubscribe/{token}')]
    function Unsubscribe([Param('token')] Token: String): TActiveQueueResponce;

    [RESTResource(TMVCHTTPMethodType.httpGET, '/items/get/{quantity}')]
    function GetItems([Param('quantity')] N: Integer): TObjectList<TReceptionRequest>;

    [RESTResource(TMVCHTTPMethodType.httpPOST, '/items/post')]
    function PutItems([Body] Items: TObjectList<TReceptionRequest>): Boolean;

  end;

implementation

end.
