unit TestActionDispatcher;

interface

uses
  DUnitX.TestFramework, ProviderFactory, Action,
  System.Generics.Collections;

type

  [TestFixture]
  TTestActionDispatcher = class(TObject)
  private
    action1, action2, action3, action4, defaultAction: TAction;
    actions: TObjectList<TAction>;
    factory: TProviderFactory;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // Test the find action method
    // Partition the input as follows:
    // 1. # actions: 0, 1, 2, > 2
    // 2. position of the sought action: not present, beginning, middle, end

    // Cover:
    // 1. # actions: 0
    // 2. position of the sought action: not present
    [Test]
    procedure FindActionFromEmpty;

    // Cover:
    // 1. # actions: 1
    // 2. position of the sought action: not present
    [Test]
    procedure FindActionFromOneNotPresent;

    // Cover:
    // 1. # actions: > 2
    // 2. position of the sought action: not present
    [Test]
    procedure FindActionFromThreeNotPresent;

    // Cover:
    // 1. # actions: 1
    // 2. position of the sought action: present
    [Test]
    procedure FindActionFromOnePresent;

    // Cover:
    // 1. # actions: 2
    // 2. position of the sought action: beginning
    [Test]
    procedure FindActionFromTwoPresentAtBeginning;

    // Cover:
    // 1. # actions: 2
    // 2. position of the sought action: end
    [Test]
    procedure FindActionFromTwoPresentAtEnd;

    // Cover:
    // 1. # actions: > 2
    // 2. position of the sought action: middle
    [Test]
    procedure FindActionFromThreePresentInMiddle;

  end;

implementation

procedure TTestActionDispatcher.FindActionFromOneNotPresent;
begin

end;

procedure TTestActionDispatcher.FindActionFromOnePresent;
begin
  actions := TObjectList<TAction>.Create();
  actions.add(action1);
  factory := TProviderFactory.Create(actions, action2);
  Assert.AreEqual(action2, factory.FindAction('not', 'exist'));
end;

procedure TTestActionDispatcher.FindActionFromThreeNotPresent;
begin
  actions.addRange([action1, action2, action3]);
  factory := TActionDispatcher.Create(actions, defaultAction);
  Assert.AreEqual(defaultAction, factory.FindAction('not', 'exist'));
end;

procedure TTestActionDispatcher.FindActionFromThreePresentInMiddle;
begin
  actions.addRange([action1, action2, action3]);
  factory := TActionDispatcher.Create(actions, defaultAction);
  Assert.AreEqual(action2, factory.FindAction('name2', 'action2'));
end;

procedure TTestActionDispatcher.FindActionFromTwoPresentAtBeginning;
begin
  actions.addRange([action1, action2, action3]);
  factory := TActionDispatcher.Create(actions, defaultAction);
  Assert.AreEqual(action1, factory.FindAction('name1', 'action1'));
end;

procedure TTestActionDispatcher.FindActionFromTwoPresentAtEnd;
begin
  actions.addRange([action1, action2]);
  factory := TActionDispatcher.Create(actions, action3);
  Assert.AreEqual(action2, factory.FindAction('name2', 'action2'));
end;

procedure TTestActionDispatcher.Setup;
begin
  action1 := TAction.Create('name1', 'action1');
  action2 := TAction.Create('name2', 'action2');
  action3 := TAction.Create('name3', 'action3');
  action4 := TAction.Create('name4', 'action4');
  actions := TObjectList<TAction>.Create();
end;

procedure TTestActionDispatcher.TearDown;
begin

end;

procedure TTestActionDispatcher.FindActionFromEmpty;
begin
  factory := TActionDispatcher.Create(actions, action3);
  Assert.AreEqual(action3, factory.FindAction('whatever name', 'whatever action'));
end;

initialization

TDUnitX.RegisterTestFixture(TTestActionDispatcher);

end.
