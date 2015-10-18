
#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController
@property (nonatomic, readonly) UIScrollView* scrollView;
@property (nonatomic, readonly) UITextField* usernameField;
@property (nonatomic, readonly) UITextField* passwordField;
@property (nonatomic, readonly) UITextField* confirmPasswordField;
@property (nonatomic, readonly) UITextField* firstNameField;
@property (nonatomic, readonly) UITextField* lastNameField;
@property (nonatomic, readonly) UIButton* signupButton;
@end
