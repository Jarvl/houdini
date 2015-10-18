//
//  InterfaceController.h
//  Houdini WatchKit Extension
//
//  Created by Apple on 10/16/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface InterfaceController : WKInterfaceController<WCSessionDelegate>
- (IBAction)onButtonPress;
@end
