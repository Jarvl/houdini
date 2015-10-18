
#import "LoginViewController.h"
#import "RegisterViewController.h"
#include "HoudiniAPI.h"

@interface LoginViewController()
-(void)_loginAction;
-(void)_registerAction;
@property (nonatomic, readonly) UIActivityIndicatorView* loadingView;
@end

@implementation LoginViewController

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;
@synthesize registerButton = _registerButton;
@synthesize loadingView = _loadingView;

#define FIELD_WIDTH 200
#define FIELD_HEIGHT 30
#define BUTTON_WIDTH 100
#define BUTTON_HEIGHT 40
#define SPINNER_SIZE 40

-(id)init
{
	if(self = [super init])
	{
		CGRect frame = self.view.frame;
		
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		_usernameField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 50, FIELD_WIDTH, FIELD_HEIGHT)];
		[_usernameField setBorderStyle:UITextBorderStyleLine];
		[_usernameField setPlaceholder:@"Username"];
		
		_passwordField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 90, FIELD_WIDTH, FIELD_HEIGHT)];
		[_passwordField setBorderStyle:UITextBorderStyleLine];
		[_passwordField setPlaceholder:@"Password"];
		[_passwordField setSecureTextEntry:YES];
		
		_loginButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2)-BUTTON_WIDTH-10, 130, BUTTON_WIDTH, BUTTON_HEIGHT)];
		[_loginButton setBackgroundColor:[UIColor grayColor]];
		[_loginButton setTitle:@"Login" forState:UIControlStateNormal];
		[_loginButton addTarget:self action:@selector(_loginAction) forControlEvents:UIControlEventTouchUpInside];
		
		_registerButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2)+10, 130, BUTTON_WIDTH, BUTTON_HEIGHT)];
		[_registerButton setBackgroundColor:[UIColor grayColor]];
		[_registerButton setTitle:@"Register" forState:UIControlStateNormal];
		[_registerButton addTarget:self action:@selector(_registerAction) forControlEvents:UIControlEventTouchUpInside];
		
		_loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width/2)-(SPINNER_SIZE/2), 165, SPINNER_SIZE, SPINNER_SIZE)];
		[_loadingView setHidden:YES];
		[_loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		
		[self.view addSubview:_usernameField];
		[self.view addSubview:_passwordField];
		[self.view addSubview:_loginButton];
		[self.view addSubview:_registerButton];
		[self.view addSubview:_loadingView];
	}
	return self;
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	CGRect frame = self.view.frame;
	
	[_usernameField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 50, FIELD_WIDTH, FIELD_HEIGHT)];
	[_passwordField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 90, FIELD_WIDTH, FIELD_HEIGHT)];
	[_loginButton setFrame:CGRectMake((frame.size.width/2)-BUTTON_WIDTH-10, 130, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[_registerButton setFrame:CGRectMake((frame.size.width/2)+10, 130, BUTTON_WIDTH, BUTTON_HEIGHT)];
	[_loadingView setFrame:CGRectMake((frame.size.width/2)-(SPINNER_SIZE/2), 165, SPINNER_SIZE, SPINNER_SIZE)];
}

-(void)_loginAction
{
	NSString* username = _usernameField.text;
	NSString* password = _passwordField.text;
	
	[_usernameField setEnabled:NO];
	[_passwordField setEnabled:NO];
	[_loginButton setEnabled:NO];
	[_registerButton setEnabled:NO];
	[_loadingView setHidden:NO];
	[_loadingView startAnimating];
	
	HoudiniAPI::login([username UTF8String], [password UTF8String], [self, username](bool success, const std::string& passwordHash, NSError* error){
		[_usernameField setEnabled:YES];
		[_passwordField setEnabled:YES];
		[_loginButton setEnabled:YES];
		[_registerButton setEnabled:YES];
		[_loadingView setHidden:YES];
		[_loadingView stopAnimating];
		
		if(success)
		{
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:username forKey:@"username"];
			[userDefaults setObject:[NSString stringWithUTF8String:passwordHash.c_str()] forKey:@"passwordHash"];
			[userDefaults synchronize];
			
			if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidSuccessfullyLogin:)])
			{
				[self.delegate loginViewControllerDidSuccessfullyLogin:self];
			}
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
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
																message:@"Invalid Username or Password"
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
				[alert show];
			}
		}
	});
}

-(void)_registerAction
{
	RegisterViewController* registerViewController = [[RegisterViewController alloc] init];
	UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:registerViewController];
	[self.navigationController presentViewController:navigationController animated:YES completion:NULL];
}

@end

