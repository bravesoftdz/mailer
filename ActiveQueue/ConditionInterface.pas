unit ConditionInterface;

interface

uses
  ReceptionRequest;

type
  /// <summary>An interface for determining whether a TReceptionRequest instance satisfies a condition.
  /// The scope of the interface is to be able to filter out TReceptionRequest instances satisfying
  /// certain conditions (i.e., in order to cancel specific TReceptionRequest instances)</summary>
  ///  For the moment, ICondition is one of: TMarkerCondition
  ICondition = interface(IInvokable)
    ['{24170427-A19C-45E0-A8AD-98493764512B}']

    function Satisfy(const Obj: TReceptionRequest): Boolean;
  end;

implementation

end.
