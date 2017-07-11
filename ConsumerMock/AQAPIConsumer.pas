unit AQAPIConsumer;

interface

uses ActiveQueueResponce, ActiveQueueEntry, SubscriptionData,
  System.Generics.Collections, MVCFramework.RESTAdapter, MVCFramework.Commons, MVCFramework, ObjectsMappers;

type
  IAQAPIConsumer = interface(IInvokable)
    ['{485A42C7-B598-428A-83E3-F524B115604C}']
    [RESTResource(TMVCHTTPMethodType.httpPUT, '/subscribe')]
    function Subscribe([Body] Data: TSubscriptionData): TActiveQueueResponce;

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/unsubscribe/{token}')]
    function Unsubscribe([Param('token')] Token: String): TActiveQueueResponce;

    [RESTResource(TMVCHTTPMethodType.httpGET, '/items/get/{token}/{quantity}')]
    function GetItems([Param('token')] Token: String; [Param('quantity')] N: Integer): TActiveQueueEntries;
  end;

implementation


end.
