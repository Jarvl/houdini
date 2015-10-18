
#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate<NSObject>
-(void)loginViewControllerDidSuccessfullyLogin:(LoginViewController*)loginViewController;
@end

@interface LoginViewController : UIViewController
@property (nonatomic, readonly) UITextField* usernameField;
@property (nonatomic, readonly) UITextField* passwordField;
@property (nonatomic, readonly) UIButton* loginButton;
@property (nonatomic, readonly) UIButton* registerButton;
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@end
