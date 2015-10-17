//
//  ViewController.m
//  Houdini
//
//  Created by Apple on 10/16/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import "ViewController.h"
#import <CoreTelephony/CTCallCenter.h>
#include <thread>
#import <objc/runtime.h>

@interface ViewController()
{
	CallMonitor* _callMonitor;
}
@end

@implementation ViewController

-(void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	_callMonitor = [[CallMonitor alloc] init];
	_callMonitor.delegate = self;
}

-(void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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

@end
