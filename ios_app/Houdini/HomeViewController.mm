
#import "HomeViewController.h"
#include "HoudiniAPI.h"
#include <thread>

@interface HomeViewController()
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
		
		_availabilitySwitch = [[UISwitch alloc] init];
		[_availabilitySwitch setOn:NO animated:NO];
		CGSize switchSize = _availabilitySwitch.frame.size;
		[_availabilitySwitch addTarget:self action:@selector(_onAvailabilityChange) forControlEvents:UIControlEventValueChanged];
		
		_availabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 40, LINE_WIDTH-switchSize.width, LINE_HEIGHT)];
		[_availabilityLabel setText:@"Availability"];
		
		[_availabilitySwitch setCenter:CGPointMake((frame.size.width/2)+(LINE_WIDTH/2)-(switchSize.width/2), 40+(LINE_HEIGHT/2))];
		
		_phoneNumberField = [[UITextField alloc] initWithFrame:CGRectMake((frame.size.width/2)+4, 140, (LINE_WIDTH/2)-4, LINE_HEIGHT)];
		[_phoneNumberField setBorderStyle:UITextBorderStyleLine];
		[_phoneNumberField setPlaceholder:@"555-555-5555"];
		
		NSString* phone_number = [[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"];
		if(phone_number!=nil)
		{
			[_phoneNumberField setText:phone_number];
		}
		
		_phoneNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 140, (LINE_WIDTH/2)-4, LINE_HEIGHT)];
		
		_saveButton = [[UIButton alloc] initWithFrame:CGRectMake((frame.size.width/2)-(SAVEBUTTON_WIDTH/2), 190, SAVEBUTTON_WIDTH, SAVEBUTTON_HEIGHT)];
		[_saveButton setTitle:@"Save" forState:UIControlStateNormal];
		[_saveButton addTarget:self action:@selector(_saveAction) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:_availabilitySwitch];
		[self.view addSubview:_availabilityLabel];
		
		[self.view addSubview:_phoneNumberField];
		[self.view addSubview:_phoneNumberLabel];
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
	HoudiniAPI::isAvailable([](bool available, NSError* error){
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

@end
