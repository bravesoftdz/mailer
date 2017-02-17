unit SendServerProxy.interfaces;

interface

uses
  MVCFramework.RESTAdapter, MVCFramework.Commons, System.Classes,
  SimpleInputData, OutputData, SimpleMailerResponce, System.JSON,
  BackEndResponce;

type
  ISendServerProxy = interface(IInvokable)
    ['{D5EF34A5-4E93-4446-951A-A7F6BADAF2B3}']

    [RESTResource(TMVCHTTPMethodType.httpGET, '/')]
    function index(): string;

    [RESTResource(TMVCHTTPMethodType.httpPOST, '/send')]
    function Send([Body] input: TBackEndRequest): TBackEndResponce;
  end;

implementation

end.
