
#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "LoginViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface MainViewController : UINavigationController<LoginViewControllerDelegate, WCSessionDelegate>

-(CNMutableContact*)contactAddFirstName:(NSString*)firstName lastName:(NSString*)lastName number:(NSString*)number;
-(void)contactRemove:(CNMutableContact*)contact;

@end

