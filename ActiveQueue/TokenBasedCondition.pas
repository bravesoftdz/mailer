unit TokenBasedCondition;

interface

uses
  ConditionInterface, ReceptionRequest;

type
  /// <summary>Condition class that checks whether a TReceptionRequest instance has
  /// a token satisfying a condition</summary>
  TTokenBasedCondition = class(TInterfacedObject, ICondition)
    /// an ammutable ADT whose state is defined just by a single value: FValue.
    /// representation invariants: FValue must be a non-empty string.

  strict private
    /// token value is to be compared with this string
    FValue: String;

    procedure CheckRep();
  public
    function Satisfy(const Obj: TReceptionRequest): Boolean;
    /// <summary>Constructor</summary>
    /// <param name="Value">a value with which the token is to be compared. </param>
    constructor Create(const Value: String);
  end;

implementation

uses
  System.SysUtils;

{ TMarkerCondition }

procedure TTokenBasedCondition.CheckRep;
begin
  raise Exception.Create('Not implemented');

end;

constructor TTokenBasedCondition.Create(const Value: String);
begin
  FValue := Value;
  CheckRep();
end;

function TTokenBasedCondition.Satisfy(const Obj: TReceptionRequest): Boolean;
begin
  Result := False;
end;

end.
