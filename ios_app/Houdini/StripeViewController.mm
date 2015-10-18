
#import "StripeViewController.h"
#import "HomeViewController.h"
#include "HoudiniAPI.h"

@implementation StripeViewController

@synthesize webView = _webView;

-(id)initWithURL:(NSString*)url
{
	if(self = [super init])
	{
		CGRect frame = self.view.frame;
		
		_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		_webView.delegate = self;
		NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
		[_webView loadRequest:request];
		[self.view addSubview:_webView];
	}
	return self;
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	CGRect frame = self.view.frame;
	[_webView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
	std::string finishedURL = HoudiniAPI::getSiteURL()+"/stripeconfirmation";
	NSString* finishedURL_str = [NSString stringWithUTF8String:finishedURL.c_str()];
	if([webView.request.URL.absoluteString isEqualToString:finishedURL_str])
	{
		HomeViewController* homeViewController = [[HomeViewController alloc] init];
		[((UINavigationController*)self.navigationController.presentingViewController) pushViewController:homeViewController animated:NO];
		[self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
	}
}

@end
