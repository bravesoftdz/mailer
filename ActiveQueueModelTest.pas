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
    /// Test suit for checking the subscription
    /// Partition the input as follows:
    /// 1. already subscribed: true, false
    /// 2. previously unsubscribed: true, false

    /// Cover
    /// 1. already subscribed: false
    /// 2. previously unsubscribed: false
    // [Test]
    procedure TestFirstSubscription;

    /// Cover
    /// 1. already subscribed: true
    /// 2. previously unsubscribed: false
    // [Test]
    procedure TestSecondSubscription;

    /// Cover
    /// 1. already subscribed: false
    /// 2. previously unsubscribed: true
    // [Test]
    procedure TestReactivateSubscription;

    /// Test suit for the number of subscriptions
    /// Partition the input as follows
    /// 1. # subscribe requests: 0, 1, > 1
    /// 2. subscribe requests: all unique, repeated
    /// 3. # unsubscribe requests: 0, 1, > 1
    /// 4. unsubscribe requests: all unique, repeated
    /// 5. overlapping: 0, 1, > 1

    /// Cover
    /// 1. # subscribe requests: 0
    /// 3. # unsubscribe requests: 0
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionEmpty;

    /// Cover
    /// 1. # subscribe requests: 1
    /// 3. # unsubscribe requests: 0
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionOneSub;

    /// Cover
    /// 1. # subscribe requests: 1
    /// 3. # unsubscribe requests: 1
    /// 5. overlapping: 0
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionOneSubOneUnsub;

    /// Cover
    /// 1. # subscribe requests: 1
    /// 3. # unsubscribe requests: 1
    /// 5. overlapping: 1
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionOneSubThenUnsub;

    /// Cover
    /// 1. # subscribe requests: > 1
    /// 2. subscribe requests: repeated
    /// 3. # unsubscribe requests: 0
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionThreeSubAllSame;

    /// Cover
    /// 1. # subscribe requests: > 1
    /// 2. subscribe requests: all unique
    /// 3. # unsubscribe requests: 0
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionTwoSubAllUnique;

    /// Cover
    /// 1. # subscribe requests: > 1
    /// 2. subscribe requests: all unique
    /// 3. # unsubscribe requests: > 1
    /// 4. unsubscribe requests: all unique
    /// 5. overlapping: > 1
    [Test]
    [Ignore]
    procedure TestNumOfSubscriptionMixed;

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

uses Model, SubscriptionData, ActiveQueueResponce, System.SysUtils;

procedure TActiveQueueModelTest.Setup;
begin
end;

procedure TActiveQueueModelTest.TearDown;
begin
end;

procedure TActiveQueueModelTest.TestFirstSubscription;
var
  model: TActiveQueueModel;
  data: TSubscriptionData;
  responce: TActiveQueueResponce;
begin
  model := TActiveQueueModel.Create;
  data := TSubscriptionData.Create('an url', 2345, 'news/');
  responce := model.AddSubscription('my ip', data);
  Assert.IsTrue(responce.status);
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
  model.SetIPs(ips);
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
  model.SetIPs(ips);
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
  model.SetIPs(ips);
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
  model.SetIPs(ips);
  Assert.IsFalse(Model.IsSubscribable('16.7.2.9'));
end;

procedure TActiveQueueModelTest.TestIsSubsInit;
var
  model: TActiveQueueModel;
begin
  model := TActiveQueueModel.Create;
  model.SetIPs(TArray<String>.Create());
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
  model.SetIPs(ips);
  Assert.IsTrue(Model.IsSubscribable('127.0.0.7'));
end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionEmpty;
begin

end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionMixed;
begin
  raise Exception.Create('Not implemented');
end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionOneSub;
begin
  raise Exception.Create('Not implemented');
end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionOneSubOneUnsub;
begin
  raise Exception.Create('Not implemented');
end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionOneSubThenUnsub;
begin
  raise Exception.Create('Not implemented');
end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionThreeSubAllSame;
begin
  raise Exception.Create('Not implemented');
end;

procedure TActiveQueueModelTest.TestNumOfSubscriptionTwoSubAllUnique;
begin
  raise Exception.Create('Not implemented');
end;

procedure TActiveQueueModelTest.TestReactivateSubscription;
var
  model: TActiveQueueModel;
  data1, data2: TSubscriptionData;
  responce: TActiveQueueResponce;
begin
  model := TActiveQueueModel.Create;
  data1 := TSubscriptionData.Create('url 1', 2345, 'news/');
  data2 := TSubscriptionData.Create('url 2', 567, 'archive/to/old');
  model.AddSubscription('ip', data1);
  model.CancelSubscription('ip');
  responce := model.AddSubscription('ip', data2);
  Assert.IsTrue(responce.status);
end;

procedure TActiveQueueModelTest.TestSecondSubscription;
var
  model: TActiveQueueModel;
  data1, data2: TSubscriptionData;
  responce: TActiveQueueResponce;
begin
  model := TActiveQueueModel.Create;
  data1 := TSubscriptionData.Create('url 1', 2345, 'news/');
  data2 := TSubscriptionData.Create('url 2', 567, 'archive/to/old');
  model.AddSubscription('ip', data1);
  responce := model.AddSubscription('ip', data2);
  Assert.IsFalse(responce.status);
end;

initialization

TDUnitX.RegisterTestFixture(TActiveQueueModelTest);

end.
