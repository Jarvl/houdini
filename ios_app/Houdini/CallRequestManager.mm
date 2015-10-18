
#import "CallRequestManager.h"
#include "HoudiniAPI.h"

@interface CallRequestInstance()
{
	CallMonitor* _callMonitor;
	BOOL _responsedWithAccept;
}
@end

@implementation CallRequestInstance

@synthesize sessionId = _sessionId;
@synthesize phoneNumber = _phoneNumber;
@synthesize asked = _asked;

-(id)initWithSessionID:(NSString *)sessionId
{
	if(self = [super init])
	{
		_responsedWithAccept = NO;
		_asked = NO;
		_sessionId = sessionId;
		_phoneNumber = nil;
		_callMonitor = nil;
	}
	return self;
}

-(void)ask
{
	_asked = YES;
	if(_responsedWithAccept)
	{
		return;
	}
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Call Request"
													message:@"You have a pending call request"
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:@"Accept", @"Decline", nil];
	[alert show];
}

-(void)acceptWithUsername:(NSString*)username
{
	_responsedWithAccept = YES;
	HoudiniAPI::acceptCallRequest([username UTF8String], [_sessionId UTF8String], [self](bool accepted, const std::string& phone_number, NSError* error){
		if(accepted)
		{
			_phoneNumber = [NSString stringWithUTF8String:phone_number.c_str()];
			_callMonitor = [[CallMonitor alloc] init];
			[_callMonitor setDelegate:self];
			[_callMonitor call:[NSString stringWithUTF8String:phone_number.c_str()]];
		}
		else
		{
			if(error!=nil)
			{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
																message:[error localizedDescription]
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
				[alert show];
			}
			else
			{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Too Late"
																message:@"Call has already been claimed"
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
				[alert show];
				[self finish];
			}
		}
	});
}

-(void)alertView:(UIAlertView*)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSString* title = alertView.title;
	if([title isEqualToString:@"Call Request"])
	{
		NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
		if([buttonTitle isEqualToString:@"Accept"])
		{
			NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
			NSString* username = [userDefaults objectForKey:@"username"];
			[self acceptWithUsername:username];
		}
		else if([buttonTitle isEqualToString:@"Decline"])
		{
			if(!_responsedWithAccept)
			{
				NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
				NSString* cmp_sessionId = [userDefaults objectForKey:@"request_call_session_id"];
				if(cmp_sessionId!=nil && [_sessionId isEqualToString:cmp_sessionId])
				{
					[userDefaults removeObjectForKey:@"request_call_session_id"];
					[userDefaults synchronize];
				}
			}
		}
	}
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
	HoudiniAPI::endPhoneCall([_sessionId UTF8String], (unsigned long)seconds, [self](bool paid, const std::string& charged, NSError* error){
		if(paid)
		{
			NSMutableString* message = [NSMutableString stringWithString:@"You have been charged $"];
			[message appendString:[NSString stringWithUTF8String:charged.c_str()]];
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Call Finished"
															message:message
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
		}
		else
		{
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Hey!"
															message:@"You got a free call, due to the fact that I didn't have time to actually program a way around this"
														   delegate:nil
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
		}
		[self finish];
	});
}

-(void)check
{
	HoudiniAPI::checkCallSession([_sessionId UTF8String], [self](bool valid, NSError* error){
		if(valid)
		{
			NSLog(@"pending call request");
			if(_callMonitor!=nil || _phoneNumber!=nil)
			{
				return;
			}
			[self ask];
		}
		else
		{
			NSLog(@"dead call request");
			[self finish];
		}
	});
}

-(void)finish
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* cmp_sessionId = [userDefaults objectForKey:@"request_call_session_id"];
	if(cmp_sessionId!=nil && [_sessionId isEqualToString:cmp_sessionId])
	{
		[userDefaults removeObjectForKey:@"request_call_session_id"];
		[userDefaults synchronize];
	}
	[CallRequestManager removeCallRequest:_sessionId];
}

@end

@implementation CallRequestManager

NSMutableArray* callRequests = [[NSMutableArray alloc] init];

+(void)handleCallRequest:(NSString*)sessionId
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:sessionId forKey:@"request_call_session_id"];
	[userDefaults synchronize];
	
	for(NSUInteger i=0; i<[callRequests count]; i++)
	{
		if([[[callRequests objectAtIndex:i] sessionId] isEqualToString:sessionId])
		{
			[[callRequests objectAtIndex:i] check];
			return;
		}
	}
	CallRequestInstance* callRequest = [[CallRequestInstance alloc] initWithSessionID:sessionId];
	[callRequests addObject:callRequest];
	[callRequest check];
}

+(void)checkForRequests
{
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* sessionId = [userDefaults objectForKey:@"request_call_session_id"];
	if(sessionId!=nil)
	{
		[self handleCallRequest:sessionId];
	}
}

+(void)removeCallRequest:(NSString*)sessionId
{
	for(NSUInteger i=0; i<[callRequests count]; i++)
	{
		if([[[callRequests objectAtIndex:i] sessionId] isEqualToString:sessionId])
		{
			[callRequests removeObjectAtIndex:i];
			return;
		}
	}
}

@end
