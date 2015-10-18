
#import <UIKit/UIKit.h>

@interface StripeViewController : UIViewController<UIWebViewDelegate>
-(id)initWithURL:(NSString*)url;
@property (nonatomic, readonly) UIWebView* webView;
@end
