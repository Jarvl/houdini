
#import "RegisterViewController.h"
#import "StripeViewController.h"
#include "HoudiniAPI.h"

@interface RegisterViewController()
-(void)_signupAction;
-(void)_cancelAction;
-(void)keyboardWillShow:(NSNotification*)notification;
-(void)keyboardWillHide:(NSNotification*)notification;
-(void)keyboardWillChangeFrame:(NSNotification*)notification;
-(void)resetLayoutInFrame:(CGRect)frame;
@property (nonatomic, readonly) UIActivityIndicatorView* loadingView;
@property (nonatomic, readonly) BOOL keyboardShown;
@property (nonatomic, readonly) CGSize keyboardSize;
@end

@implementation RegisterViewController

@synthesize scrollView = _scrollView;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize confirmPasswordField = _confirmPasswordField;
@synthesize firstNameField = _firstNameField;
@synthesize signupButton = _signupButton;
@synthesize loadingView = _loadingView;
@synthesize keyboardShown = _keyboardShown;
@synthesize keyboardSize = _keyboardSize;

#define FIELD_WIDTH 200
#define FIELD_HEIGHT 30
#define NAMEFIELD_WIDTH 140
#define SIGNUP_WIDTH 100
#define SIGNUP_HEIGHT 30
#define SPINNER_SIZE 40

-(id)init
{
	if(self = [super init])
	{
		CGRect frame = self.view.frame;
		
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		_scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		
		_usernameField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 40, FIELD_WIDTH, FIELD_HEIGHT)];
		[_usernameField setBorderStyle:UITextBorderStyleLine];
		[_usernameField setPlaceholder:@"Username"];
		
		_passwordField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 80, FIELD_WIDTH, FIELD_HEIGHT)];
		[_passwordField setBorderStyle:UITextBorderStyleLine];
		[_passwordField setPlaceholder:@"Password"];
		[_passwordField setSecureTextEntry:YES];
		
		_confirmPasswordField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 120, FIELD_WIDTH, FIELD_HEIGHT)];
		[_confirmPasswordField setBorderStyle:UITextBorderStyleLine];
		[_confirmPasswordField setPlaceholder:@"Confirm Password"];
		[_confirmPasswordField setSecureTextEntry:YES];
		
		_firstNameField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/4)-(NAMEFIELD_WIDTH/2), 160, NAMEFIELD_WIDTH, FIELD_HEIGHT)];
		[_firstNameField setBorderStyle:UITextBorderStyleLine];
		[_firstNameField setPlaceholder:@"First Name"];
		
		_lastNameField = [[UITextField alloc] initWithFrame:CGRectMake((3*frame.size.width/4)-(NAMEFIELD_WIDTH/2), 160, NAMEFIELD_WIDTH, FIELD_HEIGHT)];
		[_lastNameField setBorderStyle:UITextBorderStyleLine];
		[_lastNameField setPlaceholder:@"Last Name"];
		
		_signupButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2)-(SIGNUP_WIDTH/2), 200, SIGNUP_WIDTH, SIGNUP_HEIGHT)];
		[_signupButton setBackgroundColor:[UIColor grayColor]];
		[_signupButton setTitle:@"Sign Up" forState:UIControlStateNormal];
		[_signupButton addTarget:self action:@selector(_signupAction) forControlEvents:UIControlEventTouchUpInside];
		
		_loadingView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width/2)-(SPINNER_SIZE/2), 250, SPINNER_SIZE, SPINNER_SIZE)];
		[_loadingView setHidden:YES];
		[_loadingView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
		
		[_scrollView addSubview:_usernameField];
		[_scrollView addSubview:_passwordField];
		[_scrollView addSubview:_confirmPasswordField];
		[_scrollView addSubview:_firstNameField];
		[_scrollView addSubview:_lastNameField];
		[_scrollView addSubview:_signupButton];
		[_scrollView addSubview:_loadingView];
		[self.view addSubview:_scrollView];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
		
		UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(_cancelAction)];
		self.navigationItem.leftBarButtonItem = cancelButton;
	}
	return self;
}

-(void)resetLayoutInFrame:(CGRect)frame
{
	if(_keyboardShown)
	{
		[_scrollView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-_keyboardSize.height)];
	}
	else
	{
		[_scrollView setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
	}
	[_usernameField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 40, FIELD_WIDTH, FIELD_HEIGHT)];
	[_passwordField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 80, FIELD_WIDTH, FIELD_HEIGHT)];
	[_confirmPasswordField setFrame:CGRectMake((frame.size.width/2)-(FIELD_WIDTH/2), 120, FIELD_WIDTH, FIELD_HEIGHT)];
	[_firstNameField setFrame:CGRectMake((frame.size.width/4)-(NAMEFIELD_WIDTH/2), 160, NAMEFIELD_WIDTH, FIELD_HEIGHT)];
	[_lastNameField setFrame:CGRectMake((3*frame.size.width/4)-(NAMEFIELD_WIDTH/2), 160, NAMEFIELD_WIDTH, FIELD_HEIGHT)];
	[_signupButton setFrame:CGRectMake((frame.size.width/2)-(SIGNUP_WIDTH/2), 200, SIGNUP_WIDTH, SIGNUP_HEIGHT)];
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	CGRect frame = self.view.frame;
	[self resetLayoutInFrame:frame];
}

-(void)keyboardWillShow:(NSNotification*)notification
{
	_keyboardShown = YES;
	
	NSTimeInterval duration = (NSTimeInterval)[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	UIViewAnimationOptions options = (UIViewAnimationOptions)[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
	[UIView animateWithDuration:duration delay:0 options:options animations:^(){
		[self resetLayoutInFrame:self.view.frame];
	} completion:NULL];
}

-(void)keyboardWillHide:(NSNotification*)notification
{
	_keyboardShown = NO;
	
	NSTimeInterval duration = (NSTimeInterval)[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	UIViewAnimationOptions options = (UIViewAnimationOptions)[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
	[UIView animateWithDuration:duration delay:0 options:options animations:^(){
		[self resetLayoutInFrame:self.view.frame];
	} completion:NULL];
}

-(void)keyboardWillChangeFrame:(NSNotification*)notification
{
	_keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
	
	NSTimeInterval duration = (NSTimeInterval)[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
	UIViewAnimationOptions options = (UIViewAnimationOptions)[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
	[UIView animateWithDuration:duration delay:0 options:options animations:^(){
		[self resetLayoutInFrame:self.view.frame];
	} completion:NULL];
}

-(void)_signupAction
{
	NSString* username = _usernameField.text;
	NSString* password = _passwordField.text;
	NSString* confirmPassword = _confirmPasswordField.text;
	NSString* firstName = _firstNameField.text;
	NSString* lastName = _lastNameField.text;
	
	if(![password isEqualToString:confirmPassword])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
														message:@"Passwords do not match"
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		return;
	}
	
	[_usernameField setEnabled:NO];
	[_passwordField setEnabled:NO];
	[_confirmPasswordField setEnabled:NO];
	[_firstNameField setEnabled:NO];
	[_lastNameField setEnabled:NO];
	[_signupButton setEnabled:NO];
	[_loadingView setHidden:NO];
	[_loadingView startAnimating];
	HoudiniAPI::signup([username UTF8String], [password UTF8String], [firstName UTF8String], [lastName UTF8String], [self, username](bool success, const std::string& url, const std::string& passwordHash, const std::string& error_desc, NSError* error){
		[_usernameField setEnabled:YES];
		[_passwordField setEnabled:YES];
		[_confirmPasswordField setEnabled:YES];
		[_firstNameField setEnabled:YES];
		[_lastNameField setEnabled:YES];
		[_signupButton setEnabled:YES];
		[_loadingView setHidden:YES];
		[_loadingView stopAnimating];
		
		if(success)
		{
			NSLog(@"signup successful");
			
			NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
			[userDefaults setObject:username forKey:@"username"];
			[userDefaults setObject:[NSString stringWithUTF8String:passwordHash.c_str()] forKey:@"passwordHash"];
			[userDefaults synchronize];
			
			StripeViewController* stripeViewController = [[StripeViewController alloc] initWithURL:[NSString stringWithUTF8String:url.c_str()]];
			[self.navigationController pushViewController:stripeViewController animated:YES];
		}
		else
		{
			if(error!=nil)
			{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
																message:[NSString stringWithUTF8String:error_desc.c_str()]
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
				[alert show];
			}
			else
			{
				UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
																message:[error localizedDescription]
															   delegate:nil
													  cancelButtonTitle:nil
													  otherButtonTitles:@"OK", nil];
				[alert show];
			}
		}
	});
}

-(void)_cancelAction
{
	[self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
