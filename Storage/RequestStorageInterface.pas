unit RequestStorageInterface;

interface

uses
  System.JSON;

type
  IRequestStorage = interface(IInvokable)
    ['{71A75CE0-EA76-458E-BD6C-B50F921FAB24}']
    function Save(const Obj: TJsonObject): String;
    function Delete(const Id: String): Boolean;
  end;

implementation

end.
