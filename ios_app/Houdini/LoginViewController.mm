
#import "LoginViewController.h"
#include "Utils.h"
#include "Globals.h"

@interface LoginViewController()
-(void)_loginAction;
@property (nonatomic, readonly) UIActivityIndicatorView* loadingView;
@end

@implementation LoginViewController

@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize loginButton = _loginButton;
@synthesize loadingView = _loadingView;

#define FIELD_WIDTH 200
#define FIELD_HEIGHT 40
#define LOGIN_WIDTH 100
#define LOGIN_HEIGHT 40

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
		
		_passwordField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 100, FIELD_WIDTH, FIELD_HEIGHT)];
		[_passwordField setBorderStyle:UITextBorderStyleLine];
		[_passwordField setPlaceholder:@"Password"];
		[_passwordField setSecureTextEntry:YES];
		
		_loginButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LOGIN_WIDTH/2), 150, LOGIN_WIDTH, LOGIN_HEIGHT)];
		[_loginButton setBackgroundColor:[UIColor grayColor]];
		[_loginButton setTitle:@"Login" forState:UIControlStateNormal];
		[_loginButton addTarget:self action:@selector(_loginAction) forControlEvents:UIControlEventTouchUpInside];
		
		_loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width/2)-(SPINNER_SIZE/2), 210, SPINNER_SIZE, SPINNER_SIZE)];
		[_loadingView setHidden:YES];
		[_loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		
		[self.view addSubview:_usernameField];
		[self.view addSubview:_passwordField];
		[self.view addSubview:_loginButton];
		[self.view addSubview:_loadingView];
	}
	return self;
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	CGRect frame = self.view.frame;
	
	[_usernameField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 50, FIELD_WIDTH, FIELD_HEIGHT)];
	[_passwordField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 100, FIELD_WIDTH, FIELD_HEIGHT)];
	[_loginButton setFrame:CGRectMake((frame.size.width/2)-(LOGIN_WIDTH/2), 150, LOGIN_WIDTH, LOGIN_HEIGHT)];
	[_loadingView setFrame:CGRectMake((frame.size.width/2)-(SPINNER_SIZE/2), 210, SPINNER_SIZE, SPINNER_SIZE)];
}

-(void)_loginAction
{
	NSString* username = _usernameField.text;
	NSString* password = _passwordField.text;
	NSMutableDictionary* json_dict = [NSMutableDictionary dictionary];
	[json_dict setObject:username forKey:@"username"];
	[json_dict setObject:password forKey:@"password"];
	NSData* json_data = utils::json_serialize(json_dict);
	
	std::string login_url_str = HOUDINI_API_HOST "/login";
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithUTF8String:login_url_str.c_str()]]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Accepts"];
	[request setHTTPBody:json_data];
	
	[_usernameField setEnabled:NO];
	[_passwordField setEnabled:NO];
	[_loginButton setEnabled:NO];
	[_loadingView setHidden:NO];
	[_loadingView startAnimating];
	utils::send_http_request(request, [self](NSURLResponse* response, NSData* data, NSError* error){
		[_usernameField setEnabled:YES];
		[_passwordField setEnabled:YES];
		[_loginButton setEnabled:YES];
		[_loadingView setHidden:YES];
		[_loadingView stopAnimating];
		
		if(data!=nil)
		{
			NSString* data_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			if([data_str isEqualToString:@"true"])
			{
				NSLog(@"login successful");
				if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidSuccessfullyLogin:)])
				{
					[self.delegate loginViewControllerDidSuccessfullyLogin:self];
				}
			}
			else
			{
				NSLog(@"login failed");
			}
		}
		else
		{
			NSLog(@"error sending login request");
		}
	});
}

@end

