#import "KIAUrl.h"
#import "Jockey.h"
#import "KIAContext.h"
#import "KIALocalization.h"
#import "KIAWebViewController+Protected.h"
#define JOCKEY_USER_READY @"userReady"
#define JOCKEY_USER_ERROR @"userError"

@implementation KIAWebViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  [self addWebView];
  
  [self registerJockeyEvents];
  
  [self addHUD];
  
  [self addDismissButtonIfNeeded];
}

-(void)viewDidAppear:(BOOL)animated {
  NSURLRequest *request = [NSURLRequest requestWithURL:[self url]
                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                       timeoutInterval:60.0f];
  [_webView loadRequest:request];
}

- (void)addDismissButtonIfNeeded {
  if(self.navigationController.viewControllers.count == 1)
  {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[KIALocalization localizedStringForKey:[self dismissButtonLabelKey]]
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(dismissButtonPressed)];
  }
}

- (void)addWebView {
  _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  _webView.delegate = self;
  [self.view addSubview:_webView];
}

- (void)addHUD {
  _HUDView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
  _HUDView.center = self.view.center;
  _HUDView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
  _HUDView.layer.cornerRadius = 5;
  
  UIActivityIndicatorView *activityView= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  activityView.center = CGPointMake(_HUDView.frame.size.width / 2.0, 35);
  [activityView startAnimating];
  [_HUDView addSubview:activityView];
  
  UILabel* lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 48, 80, 30)];
  lblLoading.text = [KIALocalization localizedStringForKey:@"LOADING_SPINNER"];
  lblLoading.textColor = [UIColor whiteColor];
  lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
  lblLoading.textAlignment = NSTextAlignmentCenter;
  [_HUDView addSubview:lblLoading];
  
  [self.view addSubview:_HUDView];
}

- (void)removeHUDIfExists {
  [_HUDView removeFromSuperview];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  return [Jockey webView:webView withUrl:[request URL]];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  [self removeHUDIfExists];
  
  NSLog(@"Klarna web view failed with the following error: %@", [error description]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  [self removeHUDIfExists];
}

- (void)registerJockeyEvents {
  [Jockey on:JOCKEY_USER_READY perform:^(NSDictionary *payload) {
    [self handleUserReadyEventWithPayload: payload];
  }];
  
  [Jockey on:JOCKEY_USER_ERROR perform:^(NSDictionary *payload) {
    [self handleUserErrorEvent];
  }];
}

- (void)viewDidDisappear:(BOOL)animated {
  [self unregisterJockeyCallbacks];
}

- (void)unregisterJockeyCallbacks {
  [Jockey off:JOCKEY_USER_READY];
  [Jockey off:JOCKEY_USER_ERROR];
}


@end
