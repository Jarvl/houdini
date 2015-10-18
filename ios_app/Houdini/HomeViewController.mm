
#import "HomeViewController.h"
#import "MainViewController.h"
#include "HoudiniAPI.h"

@interface HomeViewController()
{
	CallMonitor* _callMonitor;
	NSString* _pendingSessionId;
}
-(void)_saveAction;
-(void)_onAvailabilityChange;
@property (nonatomic, readonly) UILabel* availabilityLabel;
@property (nonatomic, readonly) UILabel* phoneNumberLabel;
@end

@implementation HomeViewController

@synthesize availabilitySwitch = _availabilitySwitch;
@synthesize availabilityLabel = _availabilityLabel;

@synthesize phoneNumberField = _phoneNumberField;
@synthesize phoneNumberLabel = _phoneNumberLabel;

@synthesize saveButton = _saveButton;

#define LINE_WIDTH 240
#define LINE_HEIGHT 40

#define SAVEBUTTON_WIDTH 100
#define SAVEBUTTON_HEIGHT 40

-(id)init
{
	if(self = [super init])
	{
		CGRect frame = self.view.frame;
		
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		_callMonitor = nil;
		_pendingSessionId = nil;
		
		_availabilitySwitch = [[UISwitch alloc] init];
		[_availabilitySwitch setOn:NO animated:NO];
		CGSize switchSize = _availabilitySwitch.frame.size;
		[_availabilitySwitch addTarget:self action:@selector(_onAvailabilityChange) forControlEvents:UIControlEventValueChanged];
		
		_availabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 40, LINE_WIDTH-switchSize.width, LINE_HEIGHT)];
		[_availabilityLabel setText:@"Availability"];
		
		[_availabilitySwitch setCenter:CGPointMake((frame.size.width/2)+(LINE_WIDTH/2)-(switchSize.width/2), 40+(LINE_HEIGHT/2))];
		
		_phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)+4, 100, (LINE_WIDTH/2)-4, LINE_HEIGHT)];
		[_phoneNumberField setBorderStyle:UITextBorderStyleLine];
		[_phoneNumberField setPlaceholder:@"555-555-5555"];
		[_phoneNumberField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_phoneNumberField setAutocorrectionType:UITextAutocorrectionTypeNo];
		
		NSString* phone_number = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"];
		if(phone_number!=nil)
		{
			[_phoneNumberField setText:phone_number];
		}
		
		_phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 100, (LINE_WIDTH/2)-4, LINE_HEIGHT)];
		[_phoneNumberLabel setText:@"Phone Number"];
		
		_saveButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2)-(SAVEBUTTON_WIDTH/2), 150, SAVEBUTTON_WIDTH, SAVEBUTTON_HEIGHT)];
		[_saveButton setTitle:@"Save" forState:UIControlStateNormal];
		[_saveButton setBackgroundColor:[UIColor grayColor]];
		[_saveButton addTarget:self action:@selector(_saveAction) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:_availabilitySwitch];
		[self.view addSubview:_availabilityLabel];
		
		[self.view addSubview:_phoneNumberField];
		[self.view addSubview:_phoneNumberLabel];
		
		[self.view addSubview:_saveButton];
		
		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		NSString* request_call_session_id = [userDefaults objectForKey:@"request_call_session_id"];
		if(request_call_session_id!=nil)
		{
			NSLog(@"potential call request");
			_pendingSessionId = request_call_session_id;
			HoudiniAPI::checkCallSession([request_call_session_id UTF8String], [self](bool valid, NSError* error){
				if(valid)
				{
					NSLog(@"pending call request");
					UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Call Request"
																	message:@"You have a pending call request"
																   delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:@"Accept", @"Decline", nil];
					[alert show];
				}
				else
				{
					NSLog(@"dead call request");
					_pendingSessionId = nil;
					NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
					[userDefaults removeObjectForKey:@"request_call_session_id"];
					[userDefaults synchronize];
				}
			});
		}
	}
	return self;
}

-(void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	
	CGRect frame = self.view.frame;
	CGSize switchSize = _availabilitySwitch.frame.size;
	
	[_availabilityLabel setFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 40, LINE_WIDTH-switchSize.width, LINE_HEIGHT)];
	[_availabilitySwitch setCenter:CGPointMake((frame.size.width/2)+(LINE_WIDTH/2)-(switchSize.width/2), 40+(LINE_HEIGHT/2))];
	
	[_phoneNumberLabel setFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 140, (LINE_WIDTH/2)-4, LINE_HEIGHT)];
	[_phoneNumberField setFrame:CGRectMake((frame.size.width/2)+4, 140, (LINE_WIDTH/2)-4, LINE_HEIGHT)];
	
	[_saveButton setFrame:CGRectMake((frame.size.width/2)-(SAVEBUTTON_WIDTH/2), 190, SAVEBUTTON_WIDTH, SAVEBUTTON_HEIGHT)];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	HoudiniAPI::isAvailable([self](bool available, NSError* error){
		[_availabilitySwitch setOn:(BOOL)available animated:YES];
	});
}

-(void)_saveAction
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setObject:_phoneNumberField.text forKey:@"phone_number"];
	[userDefaults synchronize];
}

-(void)_onAvailabilityChange
{
	bool available = (bool)_availabilitySwitch.on;
	HoudiniAPI::setAvailable(available, [self](NSError* error){
		if(error!=nil)
		{
			bool available = (bool)_availabilitySwitch.on;
			HoudiniAPI::setAvailable(available, [self](NSError* error){
				if(error!=nil)
				{
					bool available = (bool)_availabilitySwitch.on;
					HoudiniAPI::setAvailable(available, [self](NSError* error){
						if(error!=nil)
						{
							// oh well.
							UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
																			message:@"Unable to update availability"
																		   delegate:nil
																  cancelButtonTitle:nil
																  otherButtonTitles:@"OK", nil];
							[alert show];
						}
					});
				}
			});
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
			_pendingSessionId = nil;
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
