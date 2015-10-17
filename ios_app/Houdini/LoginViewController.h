//
//  LoginViewController.h
//  Houdini
//
//  Created by Apple on 10/17/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate<NSObject>
-(void)loginViewControllerDidSuccessfullyLogin:(LoginViewController*)loginViewController;
@end

@interface LoginViewController : UIViewController
@property (nonatomic, readonly) UITextField* usernameField;
@property (nonatomic, readonly) UITextField* passwordField;
@property (nonatomic, readonly) UIButton* loginButton;
@property (nonatomic, weak) id<LoginViewControllerDelegate> delegate;
@end
