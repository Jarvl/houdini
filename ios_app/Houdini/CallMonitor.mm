
#import "CallMonitor.h"
#import <CoreTelephony/CTCallCenter.h>
#import <UIKit/UIKit.h>
#include <thread>

@interface CallMonitor()
{
	CTCall* _mainCall;
	BOOL _calling;
	CTCallCenter* _callCenter;
	void(^_eventHandler)(CTCall*);
	BOOL _callConnected;
	std::chrono::system_clock::time_point _callStartTime;
}
@end

@implementation CallMonitor

-(id)init
{
	if(self = [super init])
	{
		_mainCall = nil;
		_callCenter = [[CTCallCenter alloc] init];
		CallMonitor* _self = self;
		_callConnected = NO;
		_callStartTime = std::chrono::system_clock::time_point();
		_eventHandler = ^(CTCall *call){
			if(call.callState==CTCallStateDialing)
			{
				if(_self->_calling && _self->_mainCall==nil)
				{
					_self->_mainCall = call;
					if(_self.delegate!=nil && [_self.delegate respondsToSelector:@selector(callMonitor:didBeginDialingCall:)])
					{
						[_self.delegate callMonitor:_self didBeginDialingCall:call];
					}
				}
			}
			else if(call.callState==CTCallStateConnected)
			{
				if(_self->_mainCall!=nil && [call.callID isEqualToString:_mainCall.callID])
				{
					_self->_mainCall = call;
					_self->_callConnected = YES;
					_self->_callStartTime = std::chrono::system_clock::now();
					if(_self.delegate!=nil && [_self.delegate respondsToSelector:@selector(callMonitor:didConnectCall:)])
					{
						[_self.delegate callMonitor:_self didConnectCall:call];
					}
				}
			}
			else if(call.callState==CTCallStateDisconnected)
			{
				if(_self->_mainCall!=nil && [call.callID isEqualToString:_mainCall.callID])
				{
					double elapsedCallTime = 0;
					if(_self->_callConnected)
					{
						elapsedCallTime = std::chrono::duration_cast<std::chrono::seconds>(std::chrono::system_clock::now()-_self->_callStartTime).count();
					}
					_self->_calling = NO;
					_self->_mainCall = nil;
					[_self->_callCenter setCallEventHandler:nil];
					if(_self.delegate!=nil && [_self.delegate respondsToSelector:@selector(callMonitor:didDisconnectCall:withTotalCallTime:)])
					{
						[_self.delegate callMonitor:_self didDisconnectCall:call withTotalCallTime:elapsedCallTime];
					}
				}
			}
		};
	}
	return self;
}

-(BOOL)call:(NSString*)phoneNumber
{
	if(_calling)
	{
		@throw [NSException exceptionWithName:@"IllegalStateException" reason:@"CallMonitor is already calling" userInfo:nil];
	}
	_calling = YES;
	NSMutableString* url_str = [NSMutableString stringWithString:@"tel://"];
	[url_str appendString:phoneNumber];
	NSURL* url = [NSURL URLWithString:url_str];
	if(url!=nil && [[UIApplication sharedApplication] canOpenURL:url])
	{
		[_callCenter setCallEventHandler:_eventHandler];
		[[UIApplication sharedApplication] openURL:url];
		return YES;
	}
	_calling = NO;
	return NO;
}

@end
