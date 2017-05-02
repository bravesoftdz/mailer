unit ActiveQueueModelTest;

interface

uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TActiveQueueModelTest = class(TObject)
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    /// Test suit for adding a subscription
    /// Partition the input as follows:
    /// 1. already subscribed: true, false
    /// 2. # present subscriptions: 0, 1, > 2
    /// 3. request is from allowed ip: true, false

    /// Cover
    /// 1. already subscribed: false
    /// 2. ip is allowed: true
    /// 3. # already present subscriptions: 0
    [Test]
    procedure TestFirstSubscriptionAllowed;

    /// Cover
    /// 1. already subscribed: false
    /// 2. ip is allowed: false
    /// 3. # already present subscriptions: 0
    [Test]
    procedure TestFirstSubscriptionNonAllowed;

    /// Cover
    /// 1. already subscribed: false
    /// 2. ip is allowed: true
    /// 3. # already present subscriptions: > 0
    [Test]
    procedure TestAddAllowedSubscriptionToThree;

    /// Cover
    /// 1. already subscribed: false
    /// 2. ip is allowed: false
    /// 3. # already present subscriptions: > 0
    [Test]
    procedure TestAddNonAllowedSubscriptionToThree;

    /// Cover
    /// 1. already subscribed: true
    /// 2. ip is allowed: true
    /// 3. # already present subscriptions: > 0
    [Test]
    procedure TestAddAlreadySubscribedToTwo;

    /// Test the uniqueness of the subscription tokens
    /// Partition the input as follows:
    /// 1. # subscriptions: 1000
    /// 2. all IPs are different: true, false
    /// 3. all ports are different: true, false
    /// 4. all urls are different: true, false

    /// Cover
    /// 1. # subscriptions: 1000
    /// 2. all IPs are different: true
    /// 3. all ports are different: true
    /// 4. all urls are different: true
    [Test]
    procedure TestIPsPortsUrlsAreUnique();

    /// Cover
    /// 1. # subscriptions: 1000
    /// 2. all IPs are different: true
    /// 3. all ports are different: true
    /// 4. all urls are different: false
    [Test]
    procedure TestIPsPortsAreUniqueUrlsAreEquals();

    /// Cover
    /// 1. # subscriptions: 1000
    /// 2. all IPs are different: true
    /// 3. all ports are different: false
    /// 4. all urls are different: true
    [Test]
    procedure TestIPsUrlsAreUniquePortsAreEquals();

    /// Cover
    /// 1. # subscriptions: 1000
    /// 2. all IPs are different: false
    /// 3. all ports are different: false
    /// 4. all urls are different: false
    [Test]
    procedure TestIPsUrlsPortsAreEquals();

    /// Test suit for cancelling the subscription
    /// Partition the input as follows:
    /// 1. is subscribed: true, false
    /// 2. # of subscriptions: 0, 1, > 1
    /// 3. ip is correct: true, false
    /// 4. token is correct: true, false

    /// Cover:
    /// 1. is subscribed: false
    /// 2. # of subscriptions: 0
    [Test]
    procedure TestCancelNotSubscribedEmpty();

    /// Cover:
    /// 1. is subscribed: false
    /// 2. # of subscriptions: 1
    /// 3. ip is correct: false
    /// 4. token is correct: false
    [Test]
    procedure TestCancelNotSubscribedOne();

    /// Cover:
    /// 1. is subscribed: false
    /// 2. # of subscriptions: > 1
    /// 3. ip is correct: false
    /// 4. token is correct: false
    [Test]
    procedure TestCancelNotSubscribedThree();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: 1
    /// 3. ip is correct: false
    /// 4. token is correct: false
    [Test]
    procedure TestCancelSubscribedOneWrongIpToken();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: 1
    /// 3. ip is correct: true
    /// 4. token is correct: false
    [Test]
    procedure TestCancelSubscribedOneCorrectIpWrongToken();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: 1
    /// 3. ip is correct: false
    /// 4. token is correct: true
    [Test]
    procedure TestCancelSubscribedOneCorrectTokenWrongIp();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: 1
    /// 3. ip is correct: true
    /// 4. token is correct: true
    [Test]
    procedure TestCancelSubscribedOneCorrectTokenIp();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: > 1
    /// 3. ip is correct: true
    /// 4. token is correct: true
    [Test]
    procedure TestCancelSubscribedThreeCorrectIpToken();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: > 1
    /// 3. ip is correct: true
    /// 4. token is correct: false
    [Test]
    procedure TestCancelSubscribedThreeCorrectIpWrongToken();

    /// Cover:
    /// 1. is subscribed: true
    /// 2. # of subscriptions: > 1
    /// 3. ip is correct: false
    /// 4. token is correct: true
    [Test]
    procedure TestCancelSubscribedThreeCorrectTokenWrongIp();

    /// Test suit for the number of subscriptions
    /// Partition the input as follows
    /// 1. # present subscriptions: 0, 1, > 1
    /// 2. allowed: true, false

    /// Cover:
    /// 1. # present subscriptions: 0
    /// 2. allowed: true
    [Test]
    procedure TestNumberAddAllowedSubscriptionToZero;

    /// Cover:
    /// 1. # present subscriptions: 0
    /// 2. allowed: false
    [Test]
    procedure TestNumberAddNonAllowedSubscriptionToZero;

    /// Cover:
    /// 1. # present subscriptions: 1
    /// 2. allowed: true
    [Test]
    procedure TestNumberAddAllowedSubscriptionToOne;

    /// Cover:
    /// 1. # present subscriptions: 1
    /// 2. allowed: false
    [Test]
    procedure TestNumberAddNonAllowedSubscriptionToOne;

    /// Cover:
    /// 1. # present subscriptions: > 1
    /// 2. allowed: true
    [Test]
    procedure TestNumberAddAllowedSubscriptionToThree;

    /// Cover:
    /// 1. # present subscriptions: > 1
    /// 2. allowed: false
    [Test]
    procedure TestNumberAddNonAllowedSubscriptionToThree;

    /// Test suit for IsSubscribable
    /// Partition the input as follows:
    /// 1. list of IPs: not initialized, empty, 1 elem, > 1 elem
    /// 2. sought ip: not present, is at the beginning, in the middle, at the end

    /// Cover
    /// 1. list of IPs: not initialized
    /// 2. sought ip: is not in the list
    [Test]
    procedure TestIsSubsNotInit();

    /// Cover
    /// 1. list of IPs: empty
    /// 2. sought ip: is not in the list
    [Test]
    procedure TestIsSubsInit();

    /// Cover
    /// 1. list of IPs: 1 elem
    /// 2. sought ip: is at the beginning = in the middle = at the end
    [Test]
    procedure TestIsSubsOneIpIsPresnt();

    /// Cover
    /// 1. list of IPs: > 1 elem
    /// 2. sought ip: not present
    [Test]
    procedure TestIsSubs4ElemNotPresent();

    /// Cover
    /// 1. list of IPs: > 1 elem
    /// 2. sought ip: at the start
    [Test]
    procedure TestIsSubs2ElemStart();

    /// Cover
    /// 1. list of IPs: > 1 elem
    /// 2. sought ip: in the middle
    [Test]
    procedure TestIsSubs3ElemMiddle();

    /// Cover
    /// 1. list of IPs: > 1 elem
    /// 2. sought ip: at the end
    [Test]
    procedure TestIsSubs3ElemEnd();




  end;

implementation

uses Model, SubscriptionData, ActiveQueueResponce, System.SysUtils,
  System.Generics.Collections;

procedure TActiveQueueModelTest.Setup;
begin
end;

procedure TActiveQueueModelTest.TearDown;
begin
end;

procedure TActiveQueueModelTest.TestAddAllowedSubscriptionToThree;
var
  data: TSubscriptionData;
  responce: TActiveQueueResponce;
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 4);
  IPs[0] := '1.1.1.1';
  IPs[1] := '1.1.1.2';
  IPs[2] := '1.1.1.3';
  IPs[3] := '1.1.1.4';
  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.1', 'an url 1', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('1.1.1.2', 'an url 2', 1000, 'news/'));
  model.AddSubscription(TSubscriptionData.Create('1.1.1.3', 'an url 3', 555, 'news-2/'));
  responce := model.AddSubscription(TSubscriptionData.Create('1.1.1.4', 'an url 4', 2345, 'news/'));
  Assert.IsTrue(responce.status);
end;

procedure TActiveQueueModelTest.TestAddAlreadySubscribedToTwo;
var
  data: TSubscriptionData;
  responce: TActiveQueueResponce;
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 2);
  IPs[0] := '1.1.1.1';
  IPs[1] := '1.1.1.2';
  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.1', 'an url 1', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('1.1.1.2', 'an url 2', 1000, 'news/'));
  responce := model.AddSubscription(TSubscriptionData.Create('1.1.1.2', 'an url 2', 1000, 'news/'));
  Assert.IsFalse(responce.status);
end;

procedure TActiveQueueModelTest.TestAddNonAllowedSubscriptionToThree;
var
  data: TSubscriptionData;
  responce: TActiveQueueResponce;
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 3);
  IPs[0] := '1.1.1.1';
  IPs[1] := '1.1.1.2';
  IPs[2] := '1.1.1.3';
  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.1', 'an url 1', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('1.1.1.2', 'an url 2', 1000, 'news/'));
  model.AddSubscription(TSubscriptionData.Create('1.1.1.3', 'an url 3', 555, 'news-2/'));
  responce := model.AddSubscription(TSubscriptionData.Create('1.1.1.4', 'an url 4', 2345, 'news/'));
  Assert.IsFalse(responce.status);
end;

procedure TActiveQueueModelTest.TestCancelNotSubscribedEmpty;
var
  Model: TActiveQueueModel;
  responce: TActiveQueueResponce;
begin
  Model := TActiveQueueModel.Create();
  Assert.AreEqual(0, Model.numOfSubscriptions);
  responce := model.CancelSubscription('1.1.1.1', 'token');
  Assert.IsFalse(responce.status);
end;

procedure TActiveQueueModelTest.TestCancelNotSubscribedOne;
var
  Model: TActiveQueueModel;
  responce: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := '1.1.1.1';
  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.1', 'an url 1', 8080, 'call-me/'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  responce := model.CancelSubscription('5.5.5.5', 'token-not-exists');
  Assert.IsFalse(responce.status);
end;

procedure TActiveQueueModelTest.TestCancelNotSubscribedThree;
var
  Model: TActiveQueueModel;
  responce: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 3);
  IPs[0] := '1.1.1.13';
  IPs[1] := '2.1.1.13';
  IPs[2] := '3.1.1.13';
  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.13', 'an url 1', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('2.1.1.13', 'an url 2', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('3.1.1.13', 'an url 3', 8080, 'call-me/'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
  responce := model.CancelSubscription('no-associated-ip', 'no-token');
  Assert.IsFalse(responce.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedOneCorrectIpWrongToken;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := '100.100.001.1';
  Model.SetListenersIps(IPs);
  responce1 := model.AddSubscription(TSubscriptionData.Create('100.100.001.1', 'an url 1', 8080, 'call-me/'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('100.100.001.1', 'make it wrong ' + responce1.Token);
  Assert.IsFalse(responce2.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedOneCorrectTokenIp;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := '100.100.001.1';
  Model.SetListenersIps(IPs);
  responce1 := model.AddSubscription(TSubscriptionData.Create('100.100.001.1', 'an url 1', 8080, 'call-me/'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('100.100.001.1', responce1.Token);
  Assert.IsTrue(responce2.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedOneCorrectTokenWrongIp;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := '100.100.001.1';
  Model.SetListenersIps(IPs);
  responce1 := model.AddSubscription(TSubscriptionData.Create('100.100.001.1', 'an url 1', 8080, 'call-me/'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('WRONG', responce1.Token);
  Assert.IsFalse(responce2.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedOneWrongIpToken;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := '100.100.001.1';
  Model.SetListenersIps(IPs);
  responce1 := model.AddSubscription(TSubscriptionData.Create('100.100.001.1', 'an url 1', 8080, 'call-me/'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('wrong-ip', 'wrong' + responce1.Token);
  Assert.IsFalse(responce2.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedThreeCorrectIpToken;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 3);
  IPs[0] := '1.1.1.13';
  IPs[1] := '2.1.1.13';
  IPs[2] := '3.1.1.13';

  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.13', 'an url 1', 8080, 'call-me/'));
  responce1 := model.AddSubscription(TSubscriptionData.Create('2.1.1.13', 'an url 2', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('3.1.1.13', 'an url 3', 8080, 'call-me/'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('2.1.1.13', responce1.Token);
  Assert.IsTrue(responce2.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedThreeCorrectIpWrongToken;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 3);
  IPs[0] := '1.1.1.13';
  IPs[1] := '2.1.1.13';
  IPs[2] := '3.1.1.13';

  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.13', 'an url 1', 8080, 'call-me/'));
  responce1 := model.AddSubscription(TSubscriptionData.Create('2.1.1.13', 'an url 2', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('3.1.1.13', 'an url 3', 8080, 'call-me/'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('2.1.1.13', 'append-to-make-it-wrong-' + responce1.Token);
  Assert.IsFalse(responce2.status);
end;

procedure TActiveQueueModelTest.TestCancelSubscribedThreeCorrectTokenWrongIp;
var
  Model: TActiveQueueModel;
  responce1, responce2: TActiveQueueResponce;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 3);
  IPs[0] := '1.1.1.13';
  IPs[1] := '2.1.1.13';
  IPs[2] := '3.1.1.13';

  Model.SetListenersIps(IPs);
  model.AddSubscription(TSubscriptionData.Create('1.1.1.13', 'an url 1', 8080, 'call-me/'));
  responce1 := model.AddSubscription(TSubscriptionData.Create('2.1.1.13', 'an url 2', 8080, 'call-me/'));
  model.AddSubscription(TSubscriptionData.Create('3.1.1.13', 'an url 3', 8080, 'call-me/'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
  responce2 := model.CancelSubscription('3.1.1.13', responce1.Token);
  Assert.IsFalse(responce2.status);
end;

procedure TActiveQueueModelTest.TestFirstSubscriptionAllowed;
var
  data: TSubscriptionData;
  responce: TActiveQueueResponce;
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create();
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := '5.5.5.5';
  Model.SetListenersIps(IPs);
  data := TSubscriptionData.Create('5.5.5.5', 'an url', 2345, 'news/');
  responce := model.AddSubscription(data);
  Assert.IsTrue(responce.status);
end;

procedure TActiveQueueModelTest.TestFirstSubscriptionNonAllowed;
var
  data: TSubscriptionData;
  responce: TActiveQueueResponce;
  Model: TActiveQueueModel;
begin
  Model := TActiveQueueModel.Create();
  Model.SetListenersIps(TArray<String>.Create());
  data := TSubscriptionData.Create('no such ip', 'an url', 2345, 'news/');
  responce := model.AddSubscription(data);
  Assert.IsFalse(responce.status);
end;

procedure TActiveQueueModelTest.TestIPsPortsAreUniqueUrlsAreEquals;
const
  N = 1000;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
  I: Integer;
  responce: TActiveQueueResponce;
  Pool: TDictionary<String, Boolean>;
begin
  Model := TActiveQueueModel.Create;
  Pool := TDictionary<String, Boolean>.Create();
  IPs := TArray<String>.Create();
  SetLength(ips, N);
  for I := 0 to N - 1 do
    IPs[I] := inttostr(I);
  model.SetListenersIps(ips);
  for I := 0 to N - 1 do
  begin
    Responce := model.AddSubscription(TSubscriptionData.Create(IPs[I], 'an-url', I, 'news/' + inttostr(I)));
    Pool.Add(Responce.Token, True);
  end;
  Assert.AreEqual(N, Pool.Count);
  Pool.Clear;
  Pool.DisposeOf;

end;

procedure TActiveQueueModelTest.TestIPsPortsUrlsAreUnique;
const
  N = 1000;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
  I: Integer;
  responce: TActiveQueueResponce;
  Pool: TDictionary<String, Boolean>;
begin
  Model := TActiveQueueModel.Create;
  Pool := TDictionary<String, Boolean>.Create();
  IPs := TArray<String>.Create();
  SetLength(ips, N);
  for I := 0 to N - 1 do
    IPs[I] := inttostr(I);
  model.SetListenersIps(ips);
  for I := 0 to N - 1 do
  begin
    Responce := model.AddSubscription(TSubscriptionData.Create(IPs[I], 'an-url-' + inttostr(I), I, 'news/' + inttostr(I)));
    Pool.Add(Responce.Token, True);
  end;
  Assert.AreEqual(N, Pool.Count);
  Pool.Clear;
  Pool.DisposeOf;
end;

procedure TActiveQueueModelTest.TestIPsUrlsAreUniquePortsAreEquals;
const
  N = 1000;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
  I: Integer;
  responce: TActiveQueueResponce;
  Pool: TDictionary<String, Boolean>;
begin
  Model := TActiveQueueModel.Create;
  Pool := TDictionary<String, Boolean>.Create();
  IPs := TArray<String>.Create();
  SetLength(ips, N);
  for I := 0 to N - 1 do
    IPs[I] := inttostr(I);
  model.SetListenersIps(ips);
  for I := 0 to N - 1 do
  begin
    Responce := model.AddSubscription(TSubscriptionData.Create(IPs[I], 'an-url-' + inttostr(I), 3333, 'news/' + inttostr(I)));
    Pool.Add(Responce.Token, True);
  end;
  Assert.AreEqual(N, Pool.Count);
  Pool.Clear;
  Pool.DisposeOf;
end;

procedure TActiveQueueModelTest.TestIPsUrlsPortsAreEquals;
const
  N = 1000;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
  I: Integer;
  Responce: TActiveQueueResponce;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(ips, 1);
  IPs[0] := '1.1.1.1';
  model.SetListenersIps(ips);
  Responce := model.AddSubscription(TSubscriptionData.Create('1.1.1.1', 'an-url', 88, '/'));
  Assert.IsTrue(Responce.status);
  for I := 0 to N - 2 do
  begin
    Responce := model.AddSubscription(TSubscriptionData.Create('1.1.1.1', 'an-url', 88, '/'));
    Assert.IsFalse(Responce.status);
  end;
end;

procedure TActiveQueueModelTest.TestIsSubs2ElemStart;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(ips, 2);
  ips[0] := '127.0.0.7';
  ips[1] := '175.112.32.211';
  model.SetListenersIps(ips);
  Assert.IsTrue(Model.IsSubscribable('127.0.0.7'));
end;

procedure TActiveQueueModelTest.TestIsSubs3ElemEnd;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(ips, 3);
  ips[0] := '175.112.32.211';
  ips[1] := '216.87.22.99';
  ips[2] := '175.112.32.222';
  model.SetListenersIps(ips);
  Assert.IsTrue(Model.IsSubscribable('175.112.32.222'));
end;

procedure TActiveQueueModelTest.TestIsSubs3ElemMiddle;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(ips, 3);
  ips[0] := '175.112.32.211';
  ips[1] := '216.87.22.99';
  ips[2] := '175.112.32.222';
  model.SetListenersIps(ips);
  Assert.IsTrue(Model.IsSubscribable('216.87.22.99'));
end;

procedure TActiveQueueModelTest.TestIsSubs4ElemNotPresent;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(ips, 4);
  ips[0] := '175.112.32.211';
  ips[1] := '216.87.22.99';
  ips[2] := '175.112.32.222';
  ips[3] := '15.12.32.20';
  model.SetListenersIps(ips);
  Assert.IsFalse(Model.IsSubscribable('16.7.2.9'));
end;

procedure TActiveQueueModelTest.TestIsSubsInit;
var
  model: TActiveQueueModel;
begin
  model := TActiveQueueModel.Create;
  model.SetListenersIps(TArray<String>.Create());
  Assert.IsFalse(Model.IsSubscribable('112.112.252.441'));
end;

procedure TActiveQueueModelTest.TestIsSubsNotInit;
var
  model: TActiveQueueModel;
begin
  model := TActiveQueueModel.Create;
  Assert.IsFalse(Model.IsSubscribable('1.1.1.1'));
end;

procedure TActiveQueueModelTest.TestIsSubsOneIpIsPresnt;
var
  model: TActiveQueueModel;
  ips: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  ips := TArray<String>.Create();
  SetLength(ips, 1);
  ips[0] := '127.0.0.7';
  model.SetListenersIps(ips);
  Assert.IsTrue(Model.IsSubscribable('127.0.0.7'));
end;

procedure TActiveQueueModelTest.TestNumberAddAllowedSubscriptionToOne;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(IPs, 2);
  IPs[0] := 'ip 1';
  IPs[1] := 'ip 2';
  Model.SetListenersIps(Ips);
  Assert.AreEqual(0, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('ip 1', 'url 1', 2021, 'path1'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('ip 2', 'url 2', 2022, 'path2'));
  Assert.AreEqual(2, Model.numOfSubscriptions);
end;

procedure TActiveQueueModelTest.TestNumberAddAllowedSubscriptionToThree;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(IPs, 4);
  IPs[0] := 'ip 1';
  IPs[1] := 'ip 2';
  IPs[2] := 'ip 3';
  IPs[3] := 'ip 4';
  Model.SetListenersIps(Ips);
  Assert.AreEqual(0, Model.numOfSubscriptions);

  Model.AddSubscription(TSubscriptionData.Create('ip 1', 'url 1', 2021, 'path1'));
  Model.AddSubscription(TSubscriptionData.Create('ip 2', 'url 2', 2022, 'path2'));
  Model.AddSubscription(TSubscriptionData.Create('ip 3', 'url 3', 2023, 'path3'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('ip 4', 'url 4', 2024, 'path3'));
  Assert.AreEqual(4, Model.numOfSubscriptions);
end;

procedure TActiveQueueModelTest.TestNumberAddAllowedSubscriptionToZero;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(IPs, 1);
  IPs[0] := 'ip 1';
  Model.SetListenersIps(IPs);
  Assert.AreEqual(0, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('ip 1', 'url 1', 2021, 'path1'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
end;

procedure TActiveQueueModelTest.TestNumberAddNonAllowedSubscriptionToOne;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(IPs, 2);
  IPs[0] := 'ip 1';
  IPs[1] := 'ip 2';
  Model.SetListenersIps(IPs);
  Assert.AreEqual(0, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('ip 1', 'url 1', 1, 'a path 1'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('non-allowed-ip', 'url 2', 2, 'a path 2'));
  Assert.AreEqual(1, Model.numOfSubscriptions);
end;

procedure TActiveQueueModelTest.TestNumberAddNonAllowedSubscriptionToThree;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  IPs := TArray<String>.Create();
  SetLength(IPs, 3);
  IPs[0] := 'ip 1';
  IPs[1] := 'ip 2';
  IPs[2] := 'ip 3';

  Model.SetListenersIps(Ips);
  Assert.AreEqual(0, Model.numOfSubscriptions);

  Model.AddSubscription(TSubscriptionData.Create('ip 1', 'url 1', 2021, 'path1'));
  Model.AddSubscription(TSubscriptionData.Create('ip 2', 'url 2', 2022, 'path2'));
  Model.AddSubscription(TSubscriptionData.Create('ip 3', 'url 3', 2023, 'path3'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('non-allowed-ip', 'url 4', 2024, 'path3'));
  Assert.AreEqual(3, Model.numOfSubscriptions);
end;

procedure TActiveQueueModelTest.TestNumberAddNonAllowedSubscriptionToZero;
var
  Model: TActiveQueueModel;
  IPs: TArray<String>;
begin
  Model := TActiveQueueModel.Create;
  Model.SetListenersIps(TArray<String>.Create());
  Assert.AreEqual(0, Model.numOfSubscriptions);
  Model.AddSubscription(TSubscriptionData.Create('some non allowed ip', 'url 1', 2021, 'path1'));
  Assert.AreEqual(0, Model.numOfSubscriptions);
end;

initialization

TDUnitX.RegisterTestFixture(TActiveQueueModelTest);

end.
