unit TokenBasedConditionTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TTokenBasedConditionTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    /// Test suit for the satisfy method
    /// Partition the input as follows:
    /// 1. token length: 0, 1, > 1
    /// 2. sought string length: 0, 1, > 1
    /// 3. token == sought string: true, false

    [Test]
    /// Cover:
    /// 1. token length: 0
    /// 2. sought string length: 0
    /// 3. token == sought string: true
    [TestCase('Compare two empty strings', ',,True')]

    /// Cover:
    /// 1. token length: 0
    /// 2. sought string length: 1
    /// 3. token == sought string: false
    [TestCase('Compare empty string with single char one', ',x,False')]

    /// Cover:
    /// 1. token length: 0
    /// 2. sought string length: > 1
    /// 3. token == sought string: false
    [TestCase('Compare empty string with five char one', ',qwert,False')]

    [Test]
    /// Cover:
    /// 1. token length: 1
    /// 2. sought string length: 0
    /// 3. token == sought string: false
    [TestCase('Compare a single char string with an empty one', 'r,,False')]

    /// Cover:
    /// 1. token length: 1
    /// 2. sought string length: 1
    /// 3. token == sought string: true
    [TestCase('Compare two single char strings', 'p,p,True')]

    /// Cover:
    /// 1. token length: 1
    /// 2. sought string length: 1
    /// 3. token == sought string: false
    [TestCase('Compare two single char strings', 'x,X,False')]

    /// Cover:
    /// 1. token length: 1
    /// 2. sought string length: > 1
    /// 3. token == sought string: false
    [TestCase('Compare a single char string with a five char one', 'r,qwert,False')]

    [Test]
    /// Cover:
    /// 1. token length: > 1
    /// 2. sought string length: 0
    /// 3. token == sought string: false
    [TestCase('Compare a three char string with an empty one', 'fTp,,False')]

    /// Cover:
    /// 1. token length: > 1
    /// 2. sought string length: 1
    /// 3. token == sought string: false
    [TestCase('Compare 5 char string with a single char one ', 'ABCDE,A,False')]

    /// Cover:
    /// 1. token length: > 1
    /// 2. sought string length: > 1
    /// 3. token == sought string: true
    [TestCase('Compare two equal 10 char strings', 'ABCDEFGHJKL,ABCDEFGHJKL,True')]

    /// Cover:
    /// 1. token length: > 1
    /// 2. sought string length: > 1
    /// 3. token == sought string: false
    [TestCase('Compare two different 5 char strings', 'mnbvc,bvcmn,False')]
    procedure Test(const Token, Sought: String; const Outcome: Boolean);

  end;

implementation

uses
  ReceptionRequest, TokenBasedCondition;

procedure TTokenBasedConditionTest.Setup;
begin
end;

procedure TTokenBasedConditionTest.TearDown;
begin
end;

procedure TTokenBasedConditionTest.Test(const Token, Sought: String; const Outcome: Boolean);
var
  Request: TReceptionRequest;
  Condition: TTokenBasedCondition;
begin
  Condition := TTokenBasedCondition.Create(Sought);
  Request := TReceptionRequestBuilder.Create.SetFrom('from').setToken(Token).Build;
  Assert.AreEqual(Outcome, Condition.Satisfy(request));
end;


initialization

TDUnitX.RegisterTestFixture(TTokenBasedConditionTest);

end.
