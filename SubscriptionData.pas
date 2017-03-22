unit SubscriptionData;

interface

// <summary>Data class that contains information necessary for
// perform the subscription.</summary>
type
  TSubscriptionData = class
  strict private
    FUrl: String;
    FPort: Integer;
    FPath: String;
  public
    property Url: String read FUrl;
    property Port: Integer read FPort;
    property Path: String read FPath;
  end;

implementation

end.
