
#import <UIKit/UIKit.h>
#import "CallMonitor.h"

@interface HomeViewController : UIViewController<UIAlertViewDelegate>
@property (nonatomic, readonly) UISwitch* availabilitySwitch;
@property (nonatomic, readonly) UITextField* phoneNumberField;
@property (nonatomic, readonly) UIButton* saveButton;
@end
