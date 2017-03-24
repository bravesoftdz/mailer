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
    [Test]
    procedure TestFirstSubscription;

    /// Cover
    /// 1. already subscribed: true
    /// 2. previously unsubscribed: false
    [Test]
    procedure TestSecondSubscription;

    /// Cover
    /// 1. already subscribed: false
    /// 2. previously unsubscribed: true
    [Test]
    procedure TestReactivateSubscription;
  end;

implementation

uses ActiveQueueModel, SubscriptionData, ActiveQueueResponce;

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
