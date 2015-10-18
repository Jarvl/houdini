
#import "AppDelegate.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#include "HoudiniAPI.h"

@interface AppDelegate()
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
	if(![mainViewController loginRequired])
	{
		HomeViewController* homeViewController = [[HomeViewController alloc] init];
		[mainViewController pushViewController:homeViewController animated:NO];
	}
	[self.window setRootViewController:mainViewController];
	[self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken{
	NSLog(@"Did Register for Remote Notifications with Device Token (%@)", deviceToken);
	NSString * token = [NSString stringWithFormat:@"%@", deviceToken];
	//Format token as you need:
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
	token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"apnsToken"];
	
	HoudiniAPI::setDeviceToken(std::string([token UTF8String], [token length]));
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error{
	NSLog(@"Did Fail to Register for Remote Notifications");
	NSLog(@"%@, %@", error, error.localizedDescription);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)notification
{
	NSLog(@"got eem");
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

@end