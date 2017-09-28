unit TokenBasedCondition;

interface

uses
  ConditionInterface, ActiveQueueEntry;

type
  /// <summary>Condition class that checks whether a TReceptionRequest instance has
  /// a token satisfying a condition</summary>
  TTokenBasedCondition = class(TInterfacedObject, ICondition)
    /// an ammutable ADT whose state is defined just by a single value: FValue.

  strict private
    /// token value is to be compared with this string
    FValue: String;

  public
    function Satisfy(const Obj: TActiveQueueEntry): Boolean;
    /// <summary>Constructor</summary>
    /// <param name="Value">a value with which the token is to be compared. </param>
    constructor Create(const Value: String);
  end;

implementation

uses
  System.SysUtils;

{ TMarkerCondition }

constructor TTokenBasedCondition.Create(const Value: String);
begin
  FValue := Value;
end;

function TTokenBasedCondition.Satisfy(const Obj: TActiveQueueEntry): Boolean;
begin
  Result := Obj.Token = FValue;
end;

end.
