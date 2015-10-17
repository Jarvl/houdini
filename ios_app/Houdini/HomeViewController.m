//
//  HomeViewController.m
//  Houdini
//
//  Created by Apple on 10/17/15.
//  Copyright © 2015 lufinkey. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()
@end

@implementation HomeViewController

@synthesize availabilitySwitch = _availabilitySwitch;

-(id)init
{
	if(self = [super init])
	{
		_availabilitySwitch = [[UISwitch alloc] init];
		[_availabilitySwitch setCenter:CGPointMake(100, 100)];
		[self.view addSubview:_availabilitySwitch];
	}
	return self;
}

@end
