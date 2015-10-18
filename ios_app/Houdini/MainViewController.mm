
#import "MainViewController.h"
#import "HomeViewController.h"
#import "InitialLoadView.h"
#include "HoudiniAPI.h"
#include <thread>

@interface MainViewController()
{
	InitialLoadView* _loadingOverlayView;
}
-(void)hideLoadingOverlayAnimated;
@end

@implementation MainViewController

-(id)initWithRootViewController:(UIViewController*)rootViewController
{
	if(self = [super initWithRootViewController:rootViewController])
	{
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
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		NSString* username = [userDefaults objectForKey:@"username"];
		NSString* passwordHash = [userDefaults objectForKey:@"passwordHash"];
		if(username==nil || passwordHash==nil)
		{
			std::thread([self]{
				std::this_thread::sleep_for(std::chrono::seconds(1));
				[self performSelectorOnMainThread:@selector(hideLoadingOverlayAnimated) withObject:nil waitUntilDone:NO];
			}).detach();
		}
		else
		{
			HoudiniAPI::login([username UTF8String], [passwordHash UTF8String], [self](bool success, const std::string& passwordHash, NSError* error){
				if(success)
				{
					HomeViewController* homeViewController = [[HomeViewController alloc] init];
					[self pushViewController:homeViewController animated:NO];
				}
				[self hideLoadingOverlayAnimated];
			});
		}
	}
	return self;
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	CGRect frame = self.view.frame;
	[_loadingOverlayView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
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

-(void)hideLoadingOverlayAnimated
{
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(){
		[_loadingOverlayView setAlpha:0.0];
	} completion:^(BOOL finished){
		[_loadingOverlayView removeFromSuperview];
		[_loadingOverlayView setAlpha:1.0];
	}];
}

-(void)loginViewControllerDidSuccessfullyLogin:(LoginViewController*)loginViewController
{
	HomeViewController* homeViewController = [[HomeViewController alloc] init];
	[self pushViewController:homeViewController animated:YES];
}

-(void)session:(WCSession*)session didReceiveMessage:(NSDictionary<NSString *,id>*)message
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
