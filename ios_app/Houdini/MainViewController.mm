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

-(id)init
{
	if(self = [super init])
	{
		firstTime = YES;
		_callMonitor = [[CallMonitor alloc] init];
		_callMonitor.delegate = self;
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
		if([self loginRequired])
		{
			LoginViewController* loginViewController = [[LoginViewController alloc] init];
			loginViewController.delegate = self;
			[self presentViewController:loginViewController animated:NO completion:NULL];
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
	return YES;
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
	[self dismissViewControllerAnimated:YES completion:^(){
		HomeViewController* homeViewController = [[HomeViewController alloc] init];
		[self presentViewController:homeViewController animated:YES completion:NULL];
	}];
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id>*)message
{
	NSString* action = [message objectForKey:@"action"];
	if([action isEqualToString:@"requestcall"])
	{
		
	}
}

@end
