
#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#include "HoudiniAPI.h"

@interface AppDelegate()
{
	NSString* _pendingSessionId;
	CallMonitor* _callMonitor;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	UIUserNotificationType types = UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
	[application registerUserNotificationSettings:settings];
	[application registerForRemoteNotifications];
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	LoginViewController* loginViewController = [[LoginViewController alloc] init];
	MainViewController* mainViewController = [[MainViewController alloc] initWithRootViewController:loginViewController];
	loginViewController.delegate = mainViewController;
	[self.window setRootViewController:mainViewController];
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
	NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
	NSString *deviceTokenStr = [[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""];
	deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString: @">" withString: @""] ;
	deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString: @" " withString: @""];
	HoudiniAPI::setDeviceToken([deviceTokenStr UTF8String]);
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
	NSLog(@"Did Fail to Register for Remote Notifications");
	NSLog(@"%@, %@", error, error.localizedDescription);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)notification
{
	NSLog(@"recieved notification");
	NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
	NSString* notificationType = [notification objectForKey:@"notificationType"];
	if(notificationType==nil)
	{
		return;
	}
	else if([notificationType isEqualToString:@"callRequest"])
	{
		NSLog(@"recieved callRequest");
		NSString* sessionId = [notification objectForKey:@"sessionId"];
		[userDefaults setObject:sessionId forKey:@"request_call_session_id"];
		[userDefaults synchronize];
		_pendingSessionId = sessionId;
		
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Call Request"
														message:@"You have a pending call request"
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"Accept", @"Decline", nil];
		[alert show];
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
			NSString* sessionId = _pendingSessionId;
			HoudiniAPI::acceptCallRequest([username UTF8String], [sessionId UTF8String], [self](bool accepted, const std::string& phone_number, NSError* error){
				if(accepted)
				{
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
					}
				}
			});
		}
		else if([buttonTitle isEqualToString:@"Decline"])
		{
			//_pendingSessionId = nil;
			NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults removeObjectForKey:@"request_call_session_id"];
			[userDefaults synchronize];
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
	NSString* sessionId = _pendingSessionId;
	_pendingSessionId = nil;
	HoudiniAPI::endPhoneCall([sessionId UTF8String], (unsigned long)seconds, [self](bool paid, const std::string& charged, NSError* error){
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
	});
}

@end
