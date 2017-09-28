unit JsonableInterface;

interface

uses
  System.JSON;

type
  Jsonable = interface(IInvokable)
    ['{6F790799-05A0-43D4-B0C1-CEF7ACF649C5}']

    function toJson(): TJsonObject;

  end;

implementation

end.
