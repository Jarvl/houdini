//
//  ViewController.h
//  Houdini
//
//  Created by Apple on 10/16/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Contacts/Contacts.h>
#import "CallMonitor.h"
#import "LoginViewController.h"
#import <WatchConnectivity/WatchConnectivity.h>

@interface MainViewController : UINavigationController<CallMonitorDelegate, LoginViewControllerDelegate, WCSessionDelegate>

-(CNMutableContact*)contactAddFirstName:(NSString*)firstName lastName:(NSString*)lastName number:(NSString*)number;
-(void)contactRemove:(CNMutableContact*)contact;

-(BOOL)beginTrackingCallToNumber:(NSString*)number;

-(BOOL)loginRequired;

@end

