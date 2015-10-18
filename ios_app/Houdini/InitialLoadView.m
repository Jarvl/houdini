
#import "InitialLoadView.h"

@implementation InitialLoadView

@synthesize activityView = _activityView;
@synthesize logoView = _logoView;

#define LOGO_SIZE 200

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:[UIColor whiteColor]];
		
		_logoView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width/2)-(LOGO_SIZE/2), (frame.size.height/2)-(LOGO_SIZE/2), LOGO_SIZE, LOGO_SIZE)];
		UIImage* image = [UIImage imageNamed:@"logo.png"];
		[_logoView setImage:image];
		
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[_activityView setCenter:CGPointMake(frame.size.width/2, (3*frame.size.height/4))];
		
		[self addSubview:_logoView];
		[self addSubview:_activityView];
	}
	return self;
}

-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[_logoView setFrame:CGRectMake((frame.size.width/2)-(LOGO_SIZE/2), (frame.size.height/2)-(LOGO_SIZE/2), LOGO_SIZE, LOGO_SIZE)];
	[_activityView setCenter:CGPointMake(frame.size.width/2, (3*frame.size.height/4))];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect frame = self.frame;
	
	[_logoView setFrame:CGRectMake((frame.size.width/2)-(LOGO_SIZE/2), (frame.size.height/2)-(LOGO_SIZE/2), LOGO_SIZE, LOGO_SIZE)];
	[_activityView setCenter:CGPointMake(frame.size.width/2, (3*frame.size.height/4))];
}

-(void)willMoveToSuperview:(UIView*)newSuperview
{
	[_activityView startAnimating];
}

-(void)removeFromSuperview
{
	[super removeFromSuperview];
	[_activityView stopAnimating];
}

@end
