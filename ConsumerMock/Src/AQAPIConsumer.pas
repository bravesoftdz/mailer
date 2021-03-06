unit AQAPIConsumer;

interface

uses AQSubscriptionResponce, ActiveQueueEntry,  System.Generics.Collections, MVCFramework.RESTAdapter, MVCFramework.Commons, MVCFramework, ObjectsMappers,
  AQSubscriptionEntry;

type
  IAQAPIConsumer = interface(IInvokable)
    ['{485A42C7-B598-428A-83E3-F524B115604C}']
    [RESTResource(TMVCHTTPMethodType.httpPUT, '/subscribe')]
    function Subscribe([Body] Data: TAQSubscriptionEntry): TAQSubscriptionResponce;

    [RESTResource(TMVCHTTPMethodType.httpPUT, '/unsubscribe/{token}')]
    function Unsubscribe([Param('token')] Token: String): TAQSubscriptionResponce;

    [RESTResource(TMVCHTTPMethodType.httpGET, '/items/get/{token}/{quantity}')]
    function GetItems([Param('token')] Token: String; [Param('quantity')] N: Integer): TActiveQueueEntries;
  end;

implementation


end.
