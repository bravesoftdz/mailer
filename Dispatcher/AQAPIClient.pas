unit AQAPIClient;

interface

uses ActiveQueueResponce, ActiveQueueEntry,
  System.Generics.Collections, MVCFramework.RESTAdapter, MVCFramework.Commons, MVCFramework, ObjectsMappers;

type
  /// <summary>Active Queue API for clients. These are methods that clients (dispatchers) can
  /// access to.</summary>
  IAQAPIClient = interface(IInvokable)
    ['{55AC9696-1A87-48F5-A01A-584FB4EBB738}']

    [RESTResource(TMVCHTTPMethodType.httpPOST, '/items/post')]
    function PostItems([Body(False)] Items: TActiveQueueEntries): TActiveQueueResponce;

  end;

implementation

end.