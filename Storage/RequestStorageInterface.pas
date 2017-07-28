unit RequestStorageInterface;

interface

uses
  System.JSON;

type
  IRequestStorage = interface(IInvokable)
    ['{71A75CE0-EA76-458E-BD6C-B50F921FAB24}']
    function Save(const Obj: TJsonObject): String;
    /// <summary>Delete a previously saved object by its id.
    /// Return true if the the object exists and gets deleted, false if it does not exist.
    /// Throw an exception if the it fails to delete existing object.</summary>
    function Delete(const Id: String): Boolean;

    /// <summary>String representation of the storage configuration: name, locations etc</summary>
    function Summary: String;
  end;

implementation

end.
