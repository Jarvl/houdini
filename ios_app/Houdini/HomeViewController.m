//
//  HomeViewController.m
//  Houdini
//
//  Created by Apple on 10/17/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@property (nonatomic, strong) UILabel* availabilityLabel;
@end

@implementation HomeViewController

@synthesize availabilitySwitch = _availabilitySwitch;
@synthesize availabilityLabel = _availabilityLabel;

#define LINE_WIDTH 200
#define LINE_HEIGHT 40

-(id)init
{
	if(self = [super init])
	{
		CGRect frame = self.view.frame;
		
		[self.view setBackgroundColor:[UIColor whiteColor]];
		
		_availabilitySwitch = [[UISwitch alloc] init];
		[_availabilitySwitch setOn:NO animated:NO];
		CGSize switchSize = _availabilitySwitch.frame.size;
		
		_availabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LINE_WIDTH/2), 40, LINE_WIDTH-switchSize.width, LINE_HEIGHT)];
		[_availabilityLabel setText:@"Availability"];
		
		[_availabilitySwitch setCenter:CGPointMake((frame.size.width/2)+(LINE_WIDTH/2)-(switchSize.width/2), 40+(LINE_HEIGHT/2))];
		
		[self.view addSubview:_availabilitySwitch];
		[self.view addSubview:_availabilityLabel];
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
}

@end
