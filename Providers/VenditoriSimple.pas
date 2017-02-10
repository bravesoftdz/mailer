unit VenditoriSimple;

interface

uses
  Provider, Action, SenderInputData;

type
  { Perform the operations related to the site "venditori.com".
    The class contains the following actions:
    1. Send
    2. Contact
  }
  TVenditoriSimple = class(TProvider)
  private
    const
    PATH = 'venditori';
  public
    constructor Create;
  end;

implementation

uses
  System.Generics.Collections, System.Classes, Credentials;

{ TVenditoriOrder }

constructor TVenditoriSimple.Create;
var
  Actions: TObjectList<TAction>;
  ActionSend, ActionOrder: TAction;
  builder: TSenderInputDataBuilder;
begin
  Actions := TObjectList<TAction>.Create();
  ActionSend := TActionSend.Create;
  builder := TSenderInputDataBuilder.Create();
  builder.SetFrom(TVenditoriCredentials.From())
    .SetSender(TVenditoriCredentials.Name())
    .SetBody('ciao')
    .SetRecipTo(TStringList.Create(['']));

  ActionSend.SetData(builder.build);
  ActionOrder := TActionOrder.Create;

  Actions.AddRange([ActionSend, ActionOrder]);
  inherited Create(PATH, Actions);
end;

end.
