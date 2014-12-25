#import "KODRegistrationViewController.h"
#import "Jockey.h"
#import "KODContext.h"

SPEC_BEGIN(KODRegistrationViewControllerSpec)

describe(@"KODRegistrationViewControllerSpec", ^{
  __block id kiaRegistrationDelegate;
  __block KODRegistrationViewController *kiaRegistrationController;
  
  beforeEach(^{
    kiaRegistrationDelegate = [KWMock nullMockForProtocol:@protocol(KODRegistrationViewControllerDelegate)];
    kiaRegistrationController = [[KODRegistrationViewController alloc] initWithDelegate:kiaRegistrationDelegate];
    [KODContext stub:@selector(getApiKey) andReturn:@"test_skadoo"];
  });
  
  it(@"should call delegate's .klarnaRegistrationController:finishedWithUserToken on .handleUserReadyEvent when a token was received", ^{
    [[kiaRegistrationDelegate should] receive:@selector(klarnaRegistrationController:finishedWithUserToken:) withArguments:kiaRegistrationController, [[KODToken alloc] initWithToken:@"my_token"]];
    
    [kiaRegistrationController handleUserReadyEventWithPayload:@{@"userToken":@"my_token"}];
  });
  
  it(@"should call the delegate's .klarnaRegistrationFailed method when the web view fails to load", ^{
    [[[kiaRegistrationDelegate should] receive] klarnaRegistrationFailed:kiaRegistrationController];

    [kiaRegistrationController webView:nil didFailLoadWithError:[NSError errorWithDomain:@"Domain" code:1234 userInfo:nil]];
  });
    
  it(@"does not call the delegate's .klarnaRegistrationFailed when the web view fails with NSURLErrorCancelled", ^{
    [[[kiaRegistrationDelegate shouldNot] receive] klarnaRegistrationFailed:kiaRegistrationController];

    [kiaRegistrationController webView:nil didFailLoadWithError:[NSError errorWithDomain:@"Domain" code:NSURLErrorCancelled userInfo:nil]];
  });

  it(@"should call the delegate's .klarnaRegistrationCancelled when the dismiss button is pressed", ^{
      [[[kiaRegistrationDelegate should] receive] klarnaRegistrationCancelled:kiaRegistrationController];

      [kiaRegistrationController dismissButtonPressed];
    });
});

SPEC_END