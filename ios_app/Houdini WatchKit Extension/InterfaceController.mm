//
//  InterfaceController.m
//  Houdini WatchKit Extension
//
//  Created by Apple on 10/16/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import "InterfaceController.h"
#include "Globals.h"
#include "Utils.h"


@interface InterfaceController()

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
	[super awakeWithContext:context];
	
	// Configure interface objects here.
	if([WCSession isSupported])
	{
		WCSession* session = [WCSession defaultSession];
		[session setDelegate:self];
		[session activateSession];
	}
	else
	{
		NSLog(@"Error WCSession is unsupported");
	}
}

- (void)willActivate {
	// This method is called when watch view controller is about to be visible to user
	[super willActivate];
}

- (void)didDeactivate {
	// This method is called when watch view controller is no longer visible
	[super didDeactivate];
}

- (IBAction)onButtonPress {
	NSLog(@"button has been pressed");
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:@"requestcall" forKey:@"action"];
	WCSession* session = [WCSession defaultSession];
	[session sendMessage:dict replyHandler:nil errorHandler:nil];
}
@end



