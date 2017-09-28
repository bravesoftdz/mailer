unit SubscriptionOutcomeData;

interface

uses
  ObjectsMappers;

type

  /// An ADT for subscription outcome data
  [MapperJSONNaming(JSONNameLowerCase)]
  TSubscriptionOutcomeData = class
  strict private
    FToken: String;
  public
    /// a subscription token to be used for further comunications
    property token: String read FToken write FToken;
  end;

implementation

end.
