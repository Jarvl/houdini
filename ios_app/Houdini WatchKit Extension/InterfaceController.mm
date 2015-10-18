//
//  InterfaceController.m
//  Houdini WatchKit Extension
//
//  Created by Apple on 10/16/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import "InterfaceController.h"


@interface InterfaceController()
{
	NSTimer* clickTimer;
	NSUInteger clickCount;
}
-(void)_timerClickEvent;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
	[super awakeWithContext:context];
	
	// Configure interface objects here.
	clickTimer = nil;
	clickCount = 0;
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
	
	if(clickTimer!=nil)
	{
		[clickTimer invalidate];
	}
	clickTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(_timerClickEvent) userInfo:nil repeats:NO];
	clickCount++;
	
	if(clickCount==3)
	{
		clickCount = 0;
		[clickTimer invalidate];
		
		NSMutableDictionary* dict = [NSMutableDictionary dictionary];
		[dict setObject:@"requestcall" forKey:@"action"];
		WCSession* session = [WCSession defaultSession];
		
		[session sendMessage:dict replyHandler:nil errorHandler:nil];
		NSLog(@"sending message");
	}
}

-(void)_timerClickEvent
{
	clickCount = 0;
}
@end



