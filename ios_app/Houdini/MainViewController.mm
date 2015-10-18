
#import "MainViewController.h"
#import "HomeViewController.h"
#import "InitialLoadView.h"
#include "HoudiniAPI.h"

@interface MainViewController()
{
	CallMonitor* _callMonitor;
	InitialLoadView* _loadingOverlayView;
}
@end

@implementation MainViewController

-(id)initWithRootViewController:(UIViewController*)rootViewController
{
	if(self = [super initWithRootViewController:rootViewController])
	{
		_callMonitor = [[CallMonitor alloc] init];
		_callMonitor.delegate = self;
		[self setNavigationBarHidden:YES];
		
		if([WCSession isSupported])
		{
			WCSession* session = [WCSession defaultSession];
			[session setDelegate:self];
			[session activateSession];
		}
		
		CGRect frame = self.view.frame;
		
		_loadingOverlayView = [[InitialLoadView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self.view addSubview:_loadingOverlayView];
		HoudiniAPI::isLoggedIn([self](bool logged_in, NSError* error){
			if(logged_in)
			{
				HomeViewController* homeViewController = [[HomeViewController alloc] init];
				[self pushViewController:homeViewController animated:NO];
			}
			[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
				[_loadingOverlayView setAlpha:0.0];
			} completion:^(BOOL finished){
				[_loadingOverlayView removeFromSuperview];
				[_loadingOverlayView setAlpha:1.0];
			}];
		});
	}
	return self;
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
	HomeViewController* homeViewController = [[HomeViewController alloc] init];
	[self pushViewController:homeViewController animated:YES];
}

-(void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id>*)message
{
	NSString* action = [message objectForKey:@"action"];
	if([action isEqualToString:@"requestcall"])
	{
		NSLog(@"requesting phone call");
		NSString* phone_number = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"];
		HoudiniAPI::requestPhoneCall([phone_number UTF8String], [](bool call_placed, NSError* error){
			//
		});
	}
}

@end
