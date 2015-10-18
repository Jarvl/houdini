
#import "InitialLoadView.h"

@implementation InitialLoadView

@synthesize activityView = _activityView;

-(id)initWithFrame:(CGRect)frame
{
	if(self = [super initWithFrame:frame])
	{
		[self setBackgroundColor:[UIColor whiteColor]];
		
		_activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[_activityView setCenter:CGPointMake(frame.size.width/2, (3*frame.size.height/4))];
		
		[self addSubview:_activityView];
	}
	return self;
}

-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[_activityView setCenter:CGPointMake(frame.size.width/2, (3*frame.size.height/4))];
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect frame = self.frame;
	
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
