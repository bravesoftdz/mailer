unit SendServerProxy.interfaces;

interface

uses
  MVCFramework.RESTAdapter, MVCFramework.Commons, System.Classes,
  ReceptionRequest, System.JSON,
  ActiveQueueResponce, System.Generics.Collections;

type
  /// a proxy for the Active Queue Server
  ISendServerProxy = interface(IInvokable)
    ['{D5EF34A5-4E93-4446-951A-A7F6BADAF2B3}']

    [RESTResource(TMVCHTTPMethodType.httpGET, '/')]
    function index(): string;

    [RESTResource(TMVCHTTPMethodType.httpPOST, '/items/post')]
    function PostItems([Body] input: TObjectList<TReceptionRequest>): TActiveQueueResponce;
  end;

implementation

end.
