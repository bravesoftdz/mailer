unit MailerAction;

interface

uses
  SimpleMailerResponce, SimpleInputData;

type
  TMailerAction = class
  public
    function Elaborate(const Data: TSimpleInputData): TSimpleMailerResponce; virtual; abstract;
  end;

implementation

{ TMailerAction }

end.
