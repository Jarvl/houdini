//
//  ViewController.m
//  Houdini
//
//  Created by Apple on 10/16/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import "MainViewController.h"
#import "HomeViewController.h"

@interface MainViewController()
{
	CallMonitor* _callMonitor;
	BOOL firstTime;
}
@end

@implementation MainViewController

-(id)initWithRootViewController:(UIViewController*)rootViewController
{
	if(self = [super initWithRootViewController:rootViewController])
	{
		firstTime = YES;
		_callMonitor = [[CallMonitor alloc] init];
		_callMonitor.delegate = self;
		[self setNavigationBarHidden:YES];
	}
	return self;
}

-(void)viewDidAppear:(BOOL)animated
{
	if(firstTime)
	{
		if([WCSession isSupported])
		{
			WCSession* session = [WCSession defaultSession];
			[session setDelegate:self];
			[session activateSession];
		}
		firstTime = NO;
	}
}

-(CNMutableContact*)contactAddFirstName:(NSString*)firstName lastName:(NSString*)lastName number:(NSString*)number
{
	CNMutableContact* contact = [[CNMutableContact alloc] init];
	contact.givenName = firstName;
	contact.familyName = lastName;
	
	CNPhoneNumber* phoneNumber = [[CNPhoneNumber alloc] initWithStringValue:number];
	contact.phoneNumbers = [NSArray arrayWithObject:[[CNLabeledValue alloc] initWithLabel:CNLabelPhoneNumberMain value:phoneNumber]];
	
	CNContactStore* contactStore = [[CNContactStore alloc] init];
	CNSaveRequest* saveRequest = [[CNSaveRequest alloc] init];
	[saveRequest addContact:contact toContainerWithIdentifier:nil];
	
	NSError* error = nil;
	BOOL stored = [contactStore executeSaveRequest:saveRequest error:&error];
	if(!stored)
	{
		return nil;
	}
	return contact;
}

-(void)contactRemove:(CNMutableContact*)contact
{
	if(contact==nil)
	{
		return;
	}
	CNContactStore* contactStore = [[CNContactStore alloc] init];
	CNSaveRequest* saveRequest = [[CNSaveRequest alloc] init];
	[saveRequest deleteContact:contact];
	NSError* error = nil;
	[contactStore executeSaveRequest:saveRequest error:&error];
}

-(BOOL)beginTrackingCallToNumber:(NSString *)number
{
	return [_callMonitor call:number];
}

-(BOOL)loginRequired
{
	//TODO check if logging in is necessary
	return NO;
}


-(void)callMonitor:(CallMonitor*)callMonitor didBeginDialingCall:(CTCall*)call
{
	NSLog(@"dialing");
}

-(void)callMonitor:(CallMonitor*)callMonitor didConnectCall:(CTCall*)call
{
	NSLog(@"connected");
}

-(void)callMonitor:(CallMonitor*)callMonitor didDisconnectCall:(CTCall *)call withTotalCallTime:(double)seconds
{
	NSLog(@"call lasted %f seconds", seconds);
}

-(void)loginViewControllerDidSuccessfullyLogin:(LoginViewController*)loginViewController
{
	HomeViewController* homeViewController = [[HomeViewController alloc] init];
	[self pushViewController:homeViewController animated:YES];
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id>*)message
{
	NSString* action = [message objectForKey:@"action"];
	if([action isEqualToString:@"requestcall"])
	{
		//TODO send request to call
	}
}

@end
