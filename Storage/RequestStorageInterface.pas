unit RequestStorageInterface;

interface

uses
  System.JSON, System.Generics.Collections;

type
  IRequestStorage<T: Class, constructor> = interface(IInvokable)
    ['{71A75CE0-EA76-458E-BD6C-B50F921FAB24}']

    /// <summary>Save the object and return an id by which it can be accessed later.</summary>
    function Save(const Obj: T): String;

    /// <summary>Delete a previously saved object by its id.
    /// Return true if the the object exists and gets deleted, false if it does not exist.
    /// Throw an exception if the it fails to delete existing object.</summary>
    function Delete(const Id: String): Boolean;

    /// <summary>Storage parameters in the form of a list of pairs consisting of a key name and its value.
    /// The values are cast to strings.
    /// I've choosen a list type and not a map (dictionary) in order to have an ordered structure: when
    /// printing out these parameters, the order migth be important (some parameters are more important,
    /// so let's print them uot first). </summary>
    function GetParams: TArray<TPair<String, String>>;

    /// <summary>Get requests that should be elaborated.
    /// The keys are the ids under which the requests have been saved in the repository.
    /// </summary>
    function GetPendingRequests(): TDictionary<String, T>;
  end;

implementation

end.
